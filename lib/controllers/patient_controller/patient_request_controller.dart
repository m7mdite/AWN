import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../models/requests_models/treatment_request_model.dart';
import '../../services/remote/api_result.dart';
import '../../services/remote/public_remotes/request_remote.dart';
import '../../utils/app_constants/app_theme_constants.dart';
import '../../utils/app_constants/colors_constant.dart';
import '../../utils/app_constants/status_request.dart';
import '../../views/patient_views/dialog_request/dialog_update_request.dart';
import '../../views/widgets/botton_controller.dart';
import '../../views/widgets/dialog/submit_dialog.dart';
import '../../views/widgets/requests/show_request.dart';
import '../requests_controllers/fill_request_controller.dart';

abstract class PatientRequestController extends GetxController {
  void refreshData();
  void getPendingRequest();
  void getInProcessingRequest();
  void getRejectedRequest();
  void getCompletedRequest();
  void showRequest(TreatmentRequestModel request);
  void showProcessingRequest(TreatmentRequestModel request);
  void toUpdateMode(TreatmentRequestModel request);
  void toCancelUpdateMode();
  void sendUpdateData();
  void deleteRequest(String id);
  List<dynamic> getListRequest();
  void toPageView(int page);
  void sendRequest();
  void cancelSendRequest();
  void updateRequest(String id);
  void cancelUpdateRequest();
  Future<void> getTreatments();
}

class PatientRequestControllerImp extends PatientRequestController {
  late final FillRequestControllerImp fillRequestController;
  bool isUpdate = false;
  final RxBool isLoading = false.obs;
  late StatusRequest statusRequest;
  final RequestRemote _requestRemote = RequestRemote();
  // final localStorage = Get.find<LocalUserStorage>();
  late TreatmentRequestModel selectedRequest;
  List<TreatmentRequestModel> requestListPending = <TreatmentRequestModel>[];
  List<TreatmentRequestModel> requestListProcessing = <TreatmentRequestModel>[];
  List<TreatmentRequestModel> requestListCompleted = <TreatmentRequestModel>[];
  List<TreatmentRequestModel> requestListRejected = <TreatmentRequestModel>[];
  List<List> requestList = [];

  // List<TreatmentRequestModel> currentListRequest = <TreatmentRequestModel>[];
  // List typeStatus = ['pending', 'processing', 'done', 'rejected'];

  late PageController pageController;
  int currentPageFilter = 0;
  // RequestRemote requestRemote = RequestRemote(Get.find());
  RxList<Map<String, String>> treatments = <Map<String, String>>[].obs;
  // RxList<TreatmentModel> treatments = <TreatmentModel>[].obs;

  @override
  void onInit() {
    fillRequestController = Get.put(FillRequestControllerImp());
    getTreatments();
    pageController = PageController(initialPage: 0);
    getPendingRequest();
    getInProcessingRequest();
    getCompletedRequest();
    getRejectedRequest();
    requestList = [
      requestListPending,
      requestListProcessing,
      requestListCompleted,
      requestListRejected,
    ];
    super.onInit();
  }

  @override
  Future<void> getTreatments() async {
    isLoading.value = true;
    statusRequest = StatusRequest.loading;
    try {
      final result = await _requestRemote.getTreatments();
      switch (result) {
        case ApiSuccess(data: final body):
          statusRequest = StatusRequest.success;
          final list = (body['data'] as List).map<Map<String, String>>((item) {
            return {
              'id': (item['_id'] ?? '').toString(),
              'case_type': (item['case_type'] ?? '').toString(),
            };
          }).toList();
          treatments.assignAll(list);
          debugPrint('✅ treatments loaded: ${treatments.length}');
        case ApiFailure(:final status, :final message, :final statusCode):
          statusRequest = status;
          debugPrint(
            '❌ getTreatments failed: status=$status code=$statusCode msg=$message',
          );
      }
    } catch (e, st) {
      statusRequest = StatusRequest.serverFailure;
      debugPrint('💥 getTreatments exception: $e\n$st');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  sendRequest() async {
    if (!fillRequestController.validateForm()) return;
    // نغلق الحوار ونحدّث القوائم فقط بعد نجاح الإرسال فعليًا
    final ok = await fillRequestController.sendRequest();
    if (ok) {
      refreshData();
      Get.close(1);
    }
    update();
  }

  @override
  cancelSendRequest() {
    fillRequestController.onClose();
    Get.snackbar("إلغاء الإرسال", "تم إلغاء الإرسال بنجاح");
    Get.close(1);
    update();
  }

  @override
  cancelUpdateRequest() {
    fillRequestController.onClose();
    Get.snackbar("إلغاء الإرسال", "تم إلغاء التعديل بنجاح");
    Get.close(1);
    update();
  }

  @override
  updateRequest(String id) async {
    if (!fillRequestController.validateForm()) return;
    final ok = await fillRequestController.updateRequest(id);
    if (ok) {
      refreshData();
      Get.close(1);
    }
    update();
  }

  @override
  refreshData() async {
    getPendingRequest();
    getInProcessingRequest();
    getCompletedRequest();
    getRejectedRequest();
    update();
  }

  @override
  sendUpdateData() async {
    statusRequest = StatusRequest.loading;
    update();
  }

  late int i;
  @override
  showRequest(TreatmentRequestModel request) {
    Get.dialog(
      ShowRequest(
        requestModel: request,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              BottonContainer(
                body: "حذف",
                onTap: () {
                  Get.dialog(
                    SubmitDialog(
                      title: "انتباه! ",
                      question: "هل انت متأكد من رغبتك بحذف هذا الطلب ؟\n لا يمكن التراجع عن هذا الإجراء...",
                      onTapSubmit: () {
                        deleteRequest(request.sId ?? "");
                        Get.close(1);
                      },
                    ),
                  );
                },
              ),
              BottonContainer(
                body: "تعديل",
                onTap: () {
                  Get.snackbar(
                    "تم تفعيل وضع التعديل",
                    "قم بتعديل المعلومات الخاطئة",
                  );
                  Get.close(1);
                  fillRequestController.treatmentRequestModel = request;
                  Get.dialog(
                    DialogUpdateRequest(
                      cancel: () {
                        cancelUpdateRequest();
                      },
                      update: () {
                        Get.dialog(
                          SubmitDialog(
                            title: " انتباه ",
                            question: "هل انت متأكد من صحة البيانات؟ ",
                            onTapSubmit: () async {
                              final ok = await fillRequestController
                                  .updateRequest(request.sId!);
                              if (ok) refreshData();
                              Get.close(1);
                            },
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  toUpdateMode(request) {
    Get.close(1);
    Get.dialog(
      Center(
        child: AnimatedContainer(
          height: Get.height * 0.8,
          width: Get.width * 0.9,
          duration: Duration(milliseconds: 1800),
          curve: Curves.easeIn,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.white, width: 1.5),
            color: const Color.fromARGB(40, 255, 255, 255),
            borderRadius: AppThemeConstants.borderRadius,
          ),
          // child:
          //  DialogSubmitRequest(
          //   // onTapSubmit: () => cntr.updateRequest(r.id!),
          //   // onTapCancel: cntr.cancelRequest,
          // ),
        ),
      ),
    );
    update();
  }

  @override
  toCancelUpdateMode() {
    isUpdate = false;
    Get.close(1);
    Get.snackbar("إلغاء التعديل", "تم إلغاء تعديل البيانات");
    update();
  }

  @override
  deleteRequest(String id) async {
    statusRequest = StatusRequest.loading;
    update();
    final result = await _requestRemote.deleteRequest(id);
    switch (result) {
      case ApiSuccess():
        statusRequest = StatusRequest.success;
        Get.snackbar("تم الحذف", "تم حذف الطلب بنجاح");
        refreshData();
      case ApiFailure(:final status, :final message):
        statusRequest = status;
        Get.snackbar("خطأ", message ?? "تعذر حذف الطلب");
        update();
    }
  }

  @override
  List getListRequest() {
    print("++$treatments");
    if (currentPageFilter == 0) {
      return requestListPending;
    } else if (currentPageFilter == 1) {
      return requestListProcessing;
    } else if (currentPageFilter == 2) {
      return requestListCompleted;
    } else {
      return requestListRejected;
    }
  }

  @override
  toPageView(int page) {
    pageController.animateToPage(
      page,
      duration: Duration(seconds: 1),
      curve: Curves.easeOutSine,
    );
  }

  DateTime? _lastLoadErrorAt;

  /// تحميل قائمة طلبات وتعبئتها في مكانها (نفس كائن القائمة)،
  /// حتى تبقى requestList وأي واجهة تحتفظ بالمرجع محدّثة.
  Future<void> _loadRequests(
    Future<ApiResult> Function() fetch,
    List<TreatmentRequestModel> target,
  ) async {
    statusRequest = StatusRequest.loading;
    update();
    try {
      final result = await fetch();
      switch (result) {
        case ApiSuccess(data: final body):
          statusRequest = StatusRequest.success;
          target
            ..clear()
            ..addAll(
              (body['data'] as List).map(
                (item) => TreatmentRequestModel.fromJson(item),
              ),
            );
        case ApiFailure(:final status, :final message):
          statusRequest = status;
          _showLoadError(message);
      }
    } catch (_) {
      statusRequest = StatusRequest.serverFailure;
      _showLoadError(null);
    }
    update();
  }

  // أربعة طلبات تعمل معًا؛ نعرض رسالة خطأ واحدة فقط بدل أربع
  void _showLoadError(String? message) {
    final now = DateTime.now();
    if (_lastLoadErrorAt != null &&
        now.difference(_lastLoadErrorAt!) < const Duration(seconds: 3)) {
      return;
    }
    _lastLoadErrorAt = now;
    Get.snackbar("خطأ", message ?? "تعذر تحميل الطلبات");
  }

  @override
  getCompletedRequest() =>
      _loadRequests(_requestRemote.getCompletedRequest, requestListCompleted);

  @override
  getInProcessingRequest() =>
      _loadRequests(_requestRemote.getProcessingRequest, requestListProcessing);

  @override
  getPendingRequest() =>
      _loadRequests(_requestRemote.getPendingRequests, requestListPending);

  @override
  getRejectedRequest() => _loadRequests(
    _requestRemote.getRejectedPatientRequest,
    requestListRejected,
  );

  @override
  showProcessingRequest(TreatmentRequestModel request) {
    Get.dialog(ShowRequest(requestModel: request));
  }
}

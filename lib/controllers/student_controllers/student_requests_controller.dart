import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../app_route.dart';
import '../../models/student_models/accept_request_model.dart';
import '../../services/remote/api_result.dart';
import '../../services/remote/public_remotes/request_remote.dart';
import '../../views/widgets/botton_controller.dart';
import '../../views/widgets/requests/show_request.dart';
import '../../views/widgets/requests/student_dunning_request.dart';

import '../../models/requests_models/treatment_request_model.dart';
import '../../utils/app_constants/status_request.dart';
import '../../utils/app_constants/tooth_constants.dart';

abstract class StudentRequestsController extends GetxController {
  void showRequest(TreatmentRequestModel requestModel);
  void getPendingRequests();

  void agreeRequest(String idR, String idO);
  void getProcessingRequest();
  void showMyRequest();
  void getOverSeer(String id);
}

class StudentRequestsControllerImp extends StudentRequestsController {
  RxInt currentPageIndex = 0.obs;
  PageController pageController = PageController(initialPage: 0);
  List completedRequests = <TreatmentRequestModel>[];
  List pendingRequests = <TreatmentRequestModel>[];
  List processingRequests = <TreatmentRequestModel>[];
  late StatusRequest statusRequest;
  List<String> listFilterExpanded = ToothConstants.sortBy;
  RequestRemote requestRemote = RequestRemote();
  List overseersCourse = [];
  String selectOverseer = "";
  AcceptRequestModel acceptRequestModel = AcceptRequestModel();

  @override
  void onInit() {
    getPendingRequests();
    super.onInit();
  }

  /// تحميل قائمة طلبات عامة: يعرض خطأ واحد مفهوم عند الفشل ويرجع القائمة أو null.
  Future<List?> _loadList(Future<ApiResult> Function() fetch) async {
    statusRequest = StatusRequest.loading;
    update();
    try {
      final result = await fetch();
      switch (result) {
        case ApiSuccess(data: final body):
          statusRequest = StatusRequest.success;
          return (body['data'] as List)
              .map((item) => TreatmentRequestModel.fromJson(item))
              .toList();
        case ApiFailure(:final status, :final message):
          statusRequest = status;
          Get.snackbar('خطأ', message ?? 'تعذر تحميل الطلبات');
          return null;
      }
    } catch (_) {
      statusRequest = StatusRequest.serverFailure;
      Get.snackbar('خطأ', 'تعذر تحميل الطلبات');
      return null;
    } finally {
      update();
    }
  }

  @override
  getPendingRequests() async {
    final list = await _loadList(requestRemote.getPendingRequests);
    if (list != null) pendingRequests = list;
  }

  Future<void> getCompletedRequests() async {
    final list = await _loadList(requestRemote.getCompletedRequest);
    if (list != null) completedRequests = list;
  }

  @override
  Future getProcessingRequest() async {
    final list = await _loadList(requestRemote.getProcessingRequest);
    if (list != null) processingRequests = list;
  }

  @override
  agreeRequest(String idR, String idO) async {
    statusRequest = StatusRequest.loading;
    update();
    try {
      final result = await requestRemote.acceptRequestData({}, idR, idO);
      switch (result) {
        case ApiSuccess(data: final body):
          statusRequest = StatusRequest.success;
          Get.snackbar("${body['status']}", "${body['message']}");
          getPendingRequests();
        case ApiFailure(:final status, :final message):
          statusRequest = status;
          Get.snackbar('خطأ', message ?? 'تعذر قبول الطلب');
      }
    } catch (_) {
      statusRequest = StatusRequest.serverFailure;
      Get.snackbar('خطأ', 'تعذر قبول الطلب');
    }
    update();
  }

  void changePage(int index) {
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
    update();
  }

  // ===== جلب البيانات حسب الصفحة =====
  List getCurrentPageData() {
    if (currentPageIndex.value == 0) {
      return processingRequests; // قيد المعالجة
    } else {
      return completedRequests; // مكتملة
    }
  }

  /// تعيين مشرف للطلب.
  Future<void> dunningOverseerRequest(
      AcceptRequestModel data, String idR, String idO) async {
    statusRequest = StatusRequest.loading;
    update();
    try {
      final result =
          await requestRemote.dunningOverseerData(data.toJson(), idR, idO);
      switch (result) {
                case ApiSuccess(data: final body):
          statusRequest = StatusRequest.success;
          Get.snackbar('تم', "${body['message']}");
          await getProcessingRequest(); // القائمة اللي بتعرض المشرف
                   Get.close(1);

        case ApiFailure(:final status, :final message):
          statusRequest = status;
          Get.snackbar('خطأ', message ?? 'تعذر تعيين المشرف');
      }
    } catch (_) {
      statusRequest = StatusRequest.serverFailure;
      Get.snackbar('خطأ', 'تعذر تعيين المشرف');
    }
    update();
  }

  @override
  showRequest(TreatmentRequestModel requestModel) async {
    await getOverSeer(requestModel.courseInfo!.sId!);
    Get.dialog(StudentDunningRequest(requestModel: requestModel));
  }

  Future<void> showOnedRequest(TreatmentRequestModel requestModel) async {
    await getOverSeer(requestModel.courseInfo!.sId ?? "");
    Get.dialog(
      ShowRequest(
        requestModel: requestModel,
        children: [
          if (requestModel.overseer == null)
            BottonContainer(
              body: "تعيين مشرف",
              onTap: () {
                if (overseersCourse.isEmpty) {
                  Get.snackbar("لا يوجد مشرفين لهذا المقرر",
                      "يرجى التواصل مع الإدارة لتعيين مشرف لهذا المقرر");
                  return;
                }
                Get.dialog(
                  StudentSelectOverseer(
                    onTapSubmit: () {
                      // dunningOverseerRequest تعيد تحميل القائمة بنفسها عند النجاح
                      dunningOverseerRequest(acceptRequestModel,
                          requestModel.sId ?? "", selectOverseer);
                    },
                  ),
                );
              },
            )
        ],
      ),
    );
  }

  @override
  showMyRequest() async {
    currentPageIndex.value = 0;
    await getProcessingRequest();
    await getCompletedRequests();
    Get.toNamed(AppRroute.showOwnedStudentRequest);
  }

  @override
  Future getOverSeer(String id) async {
    statusRequest = StatusRequest.loading;
    update();
    try {
      final result = await requestRemote.getOverSeerForCourse(id);
      switch (result) {
        case ApiSuccess(data: final body):
          statusRequest = StatusRequest.success;
          final data = body['data'];
          overseersCourse = data is List ? data : [];
        case ApiFailure(:final status):
          statusRequest = status;
          overseersCourse = [];
      }
    } catch (_) {
      statusRequest = StatusRequest.serverFailure;
      overseersCourse = [];
    }
    update();
  }
}
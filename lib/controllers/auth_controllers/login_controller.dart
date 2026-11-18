import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mytooth/services/functions/show_snack.dart';

import '../../app_route.dart';
import '../../services/notification/websocket_service.dart';
import '../../services/local_storge/local_user_storage.dart';
import '../../services/remote/api_result.dart';
import '../../services/remote/public_remotes/auth_remote.dart';
import '../../utils/app_constants/colors_constant.dart';
import '../../utils/app_constants/status_request.dart';

abstract class LoginController extends GetxController {
  void login();
  void goToRegister();
  Future<void> toHome(Map<String, dynamic> response);
}

class LoginControllerImp extends LoginController {
  late TextEditingController email;
  late TextEditingController password;

  final Map<String, String> data = <String, String>{};
  final GlobalKey<FormState> formStateLogin = GlobalKey<FormState>();
  late StatusRequest statusRequest;

  WebSocketService get webSocketService => Get.find<WebSocketService>();
  final LocalUserStorage storage = Get.find<LocalUserStorage>();
  final AuthRemote authRemote = AuthRemote(Get.find());

  @override
  void onInit() {
    email = TextEditingController();
    password = TextEditingController();
    _checkForRegistrationEmail();
    super.onInit();
  }

  void _checkForRegistrationEmail() {
    final arguments = Get.arguments;
    if (arguments != null && arguments['email'] != null) {
      email.text = arguments['email'];
      update();
    }
  }

  void fillMap() {
    data['email'] = email.text;
    data['password'] = password.text;
  }

  @override
  Future<void> login() async {
    fillMap();
    final formData = formStateLogin.currentState;
    if (formData == null || !formData.validate()) return;

    statusRequest = StatusRequest.loading;
    update();

    try {
      final result = await authRemote.login(data);
      switch (result) {
        case ApiSuccess(data: final body):
          statusRequest = StatusRequest.success;
          await toHome(body);
        case ApiFailure(:final status, :final message):
          statusRequest = status;
          _showError(message ?? 'فشل في الاتصال بالخادم');
      }
    } catch (_) {
      statusRequest = StatusRequest.serverFailure;
      _showError('حدث خطأ غير متوقع');
    }
    update();
  }

  @override
  Future<void> toHome(Map<String, dynamic> response) async {
    if (response['status'] != 'success') {
      _showError(response['message']?.toString() ?? 'حدث خطأ غير معروف');
      return;
    }

    final user = response['data'];
    final String? route = switch (user['role']) {
      'student' => AppRroute.mainScreenStudent,
      'patient' => AppRroute.mainScreenPatient,
      _ => null,
    };

    // نتحقق من الدور قبل حفظ أي شيء، حتى لا يبقى توكن لمستخدم غير مخصص له التطبيق
    if (route == null) {
      showsnack(title: "خطأ", message: "هذا التطبيق غير مخصص لك");
      return;
    }

    await storage.saveAllFromJson(user);
    await storage.saveToken(response['token']);

    Get.offAndToNamed(route);
    webSocketService.connect(user['_id']);

    showsnack(
      title: "نجح تسجيل الدخول",
      message: 'اهلا بك ${user['first_name']}',
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'خطأ',
      message,
      backgroundColor: AppColors.error,
      colorText: AppColors.white,
    );
  }

  @override
  void goToRegister() {
    Get.offAndToNamed(AppRroute.register);
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }
}
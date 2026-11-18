import 'package:get/get.dart';

import '../controllers/conversations_controllers/conversations_controller.dart';
import '../controllers/public_controllers/public_controller.dart';
import '../controllers/public_controllers/unified_setting_controller.dart';

class GeneralBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UnifiedSettingController>(() => UnifiedSettingController(),fenix: true);
    Get.lazyPut<PublicController>(() => PublicController(), fenix: true);
    Get.lazyPut<ConversationsController>(() => ConversationsController(), fenix: true);
  }
}
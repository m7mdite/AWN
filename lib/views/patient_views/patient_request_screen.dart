import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/patient_controller/patient_request_controller.dart';
import '../../controllers/requests_controllers/fill_request_controller.dart';

import '../../controllers/public_controllers/unified_setting_controller.dart';
import '../../utils/app_constants/app_images_constant.dart';
import '../../utils/app_constants/app_theme_constants.dart';
import '../../utils/app_constants/colors_constant.dart';
import '../public_views/chats/conversations_screen.dart';
import '../public_views/notifications_view.dart';
import '../public_views/settings/profile_screen.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_icon_app_bar.dart';
import '../widgets/custom_photo_app_bar.dart';
import '../widgets/default_no_data.dart';
import '../widgets/requests/card_request_processing.dart';
import 'dialog_request/dialog_send_request.dart';

/// أسماء التبويبات الأربعة، بنفس ترتيب الـ PageView (0..3)
enum _RequestTab { pending, processing, completed, rejected }

class PatientRequestScreen extends StatelessWidget {
  final PatientRequestControllerImp controller =
      Get.put(PatientRequestControllerImp());
  final FillRequestControllerImp controllerr =
      Get.put(FillRequestControllerImp());
  final UnifiedSettingController settingController =
      Get.find<UnifiedSettingController>();

  PatientRequestScreen({super.key});

  static const List<String> _tabLabels = [
    "قيد الإنتظار",
    "قيد المعالجة",
    "تمت معالجتها",
    "تم رفضها",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          const SizedBox(height: 20),
          _SendRequestButton(controller: controller),
          const SizedBox(height: 10),
          _buildMyRequestsHeader(),
          const SizedBox(height: 10),
          Container(
            height: 2,
            width: Get.width * 0.75,
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          GetBuilder<PatientRequestControllerImp>(
            builder: (_) => _buildTabsRow(),
          ),
          const SizedBox(height: 10),
          Expanded(child: _buildTabsPageView()),
        ],
      ),
    );
  }

  // ===================== AppBar =====================
  CustomAppBar _buildAppBar() {
    return CustomAppBar(
      title: "طلبات المعالجة",
      automaticallyImplyLeading: false,
      actions: [
        CustomIconAppBar(
          iconData: Icons.chat,
          onTap: () => Get.to(() => ConversationsScreen()),
        ),
        CustomIconAppBar(
          iconData: Icons.notifications,
          onTap: () => Get.to(() => NotificationsView()),
          reverseColors: true,
        ),
      ],
      leading: Obx(() {
        final pic = settingController.profilePicture.value;
        return InkWell(
          onTap: () => Get.to(() => ProfileScreen()),
          child: CustomPhotoAppBar(pic: pic),
        );
      }),
    );
  }

  // ===================== عنوان "طلباتي" + زر التحديث =====================
  Widget _buildMyRequestsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        const Text("طلباتي"),
        InkWell(
          onTap: () => controller.refreshData(),
          child: Icon(Icons.refresh_outlined, color: AppColors.primary),
        ),
      ],
    );
  }

  // ===================== صف التبويبات الأربعة =====================
  Widget _buildTabsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(_tabLabels.length, (index) {
        final bool isActive = controller.currentPageFilter == index;
        return Flexible(
          child: InkWell(
            onTap: () => controller.toPageView(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _tabLabels[index],
                  style: TextStyle(
                    fontSize: isActive ? 14 : 12,
                    color: isActive ? AppColors.primary : AppColors.black,
                  ),
                ),
                // ✅ نفس مؤشر الـ Divider تحت كل تبويب فعّال (كان بس للمرفوضة)
                Divider(
                  endIndent: 30,
                  indent: 30,
                  thickness: 2,
                  color: isActive ? AppColors.primary : AppColors.transparent,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ===================== الـ PageView الرئيسي =====================
  Widget _buildTabsPageView() {
    return PageView.builder(
      controller: controller.pageController,
      itemCount: _tabLabels.length,
      onPageChanged: (value) {
        controller.currentPageFilter = value;
        controller.update();
      },
      itemBuilder: (context, indexPage) {
        return GetBuilder<PatientRequestControllerImp>(
          builder: (_) => _buildRequestsList(_RequestTab.values[indexPage]),
        );
      },
    );
  }

  // ===================== قائمة الطلبات حسب التبويب =====================
  Widget _buildRequestsList(_RequestTab tab) {
    final requests = controller.getListRequest();

    if (requests.isEmpty) return DefaultNoData();

    return ListView.builder(
      itemCount: requests.length + 1,
      itemBuilder: (context, index) {
        if (index == requests.length) {
          return const SizedBox(height: 60);
        }
        return CardRequestProcessing(
          requestModel: requests[index],
          onTap: () => _onRequestTap(tab, index),
        );
      },
    );
  }

  // ===================== ضغطة على بطاقة الطلب حسب نوع التبويب =====================
  void _onRequestTap(_RequestTab tab, int index) {
    switch (tab) {
      case _RequestTab.pending:
        controller.showRequest(controller.requestListPending[index]);
        break;
      case _RequestTab.processing:
        controller
            .showProcessingRequest(controller.requestListProcessing[index]);
        break;
      case _RequestTab.completed:
        // ⚠️ عدّل اسم الدالة/القائمة إذا كانت مختلفة بالـ Controller عندك
        controller.showProcessingRequest(controller.requestListCompleted[index]);
        break;
      case _RequestTab.rejected:
        // ⚠️ عدّل اسم الدالة/القائمة إذا كانت مختلفة بالـ Controller عندك
        controller.showProcessingRequest(controller.requestListRejected[index]);
        break;
    }
  }
}

/// ================================================================
/// زر "تقديم طلب" — فُصل بويدجت منفصل لتقليل حجم build() الرئيسي
/// ================================================================
class _SendRequestButton extends StatelessWidget {
  final PatientRequestControllerImp controller;
  const _SendRequestButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.dialog(
          DialogSendRequest(
            send: () => controller.sendRequest(),
            cancel: () => controller.cancelSendRequest(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppImages.authBackground),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.linearToSrgbGamma(),
          ),
          borderRadius:AppThemeConstants.borderRadius,
          border: Border(
            right: BorderSide(color: AppColors.success),
            bottom: BorderSide(color: AppColors.success),
          ),
        ),
        child: Center(
          child: Text(
            "تقديم طلب",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              shadows: [Shadow(color: AppColors.white, blurRadius: 1)],
            ),
          ),
        ),
      ),
    );
  }
}

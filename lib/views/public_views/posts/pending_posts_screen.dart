import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import '../../../app_route.dart';
import '../../../controllers/post_controllers/post_controller.dart';
import '../../../controllers/theme_controller.dart';
import '../../../utils/app_constants/colors_constant.dart';
import '../../widgets/custom_app_bar.dart';
import 'post_card.dart';

class PendingPostsScreen extends StatefulWidget {
  const PendingPostsScreen({super.key});

  @override
  State<PendingPostsScreen> createState() => _PendingPostsScreenState();
}

class _PendingPostsScreenState extends State<PendingPostsScreen> {
  final PostController controller = Get.find<PostController>();

  @override
  void initState() {
    super.initState();
    controller.fetchPendingPosts();
  }

  @override
  Widget build(BuildContext context) {

    return GetBuilder<ThemeController>(
      builder: (_) {
        return Scaffold(
          backgroundColor: AppColors.background, // ✅
          appBar: CustomAppBar(
            title: "المنشورات المعلقة",
            centerTitle: true,
            notifacation: false,
          ),
          body: RefreshIndicator(
            color: AppColors.primary, // ✅
            onRefresh: () => controller.fetchPendingPosts(),
            child: Obx(() {
              if (controller.isLoadingPending.value &&
                  controller.pendingPosts.isEmpty) {
                return Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (controller.pendingPosts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hourglass_empty,
                          size: 64, color: AppColors.grey400), // ✅
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد منشورات معلقة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary, // ✅
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: controller.pendingPosts.length,
                itemBuilder: (context, index) {
                  final post = controller.pendingPosts[index];
                  return AnimationConfiguration.staggeredList(
                    position: index,
                    duration: const Duration(milliseconds: 400),
                    child: SlideAnimation(
                      verticalOffset: 50,
                      child: FadeInAnimation(
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.cardColor, // ✅
                            border: Border.all(
                              color: AppColors.warning.withValues(alpha: 0.5),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.warning.withValues(alpha: 0.1),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              PostCard(
                                post: post,
                                onLike: () => controller.likePost(post.sId!),
                                onDislike: () =>
                                    controller.dislikePost(post.sId!),
                                onComment: () => Get.toNamed(
                                    AppRroute.postDetail,
                                    arguments: post.sId),
                              ),
                              // badge "قيد الانتظار"
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'قيد الانتظار',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        );
      },
    );
  }
}
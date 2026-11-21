
import 'package:get/get.dart';

import 'bindings/ai_chat_binding.dart';
import 'bindings/auth_binding.dart';
import 'bindings/feed_binding.dart';
import 'bindings/main_patient_binding.dart';
import 'bindings/main_student_binding.dart';
import 'bindings/student_requests_binding.dart';
import 'bindings/unified_setting_binding.dart';
import 'views/auth/auth_screen.dart';
import 'views/guest_view/main_screen_guest.dart';
import 'views/onboarding_screen.dart';
import 'views/patient_views/main_screen_patient.dart';
import 'views/public_views/chats/chat_screen.dart';
import 'views/public_views/chats/conversations_screen.dart';
import 'views/public_views/notifications_view.dart';
import 'views/public_views/posts/create_post_screen.dart';
import 'views/public_views/posts/feed_screen.dart';
import 'views/public_views/posts/pending_posts_screen.dart';
import 'views/public_views/posts/post_detail_screen.dart';
import 'views/public_views/server_setup_screen.dart';
import 'views/public_views/settings/change_password_screen.dart';
import 'views/public_views/settings/contact_admin_screen.dart';
import 'views/public_views/settings/edit_profile_screen.dart';
import 'views/public_views/settings/privacy_policy_screen.dart';
import 'views/public_views/settings/profile_screen.dart';
import 'views/public_views/settings/setting_screen.dart';
import 'views/splash_screen.dart';
import 'views/student_views/main_screen_student.dart';
import 'views/student_views/student_requests_screen.dart';
import 'views/student_views/show_owned_student_request.dart';
import 'views/student_views/view_verify_page.dart';
import 'views/widgets/ai/ai_chat_screen.dart';

List<GetPage<dynamic>> routes = [
  GetPage(name: AppRroute.onboarding, page: () => OnboardingScreen()),
  GetPage(
    name: "/",
    page: () => SplashScreen(),
  ),
  GetPage(
  name: '/server-setup',
  page: () => ServerSetupScreen(next: () => const SplashScreen()), // شاشتك الأولى
),
  // ========== AUTH ==========

  GetPage(
    name: AppRroute.auth,
    page: () => AuthScreen(),
    binding: AuthBinding(),
  ),

  // مستخدمان في Get.offAllNamed داخل الـ controllers (بعد التسجيل/تسجيل الخروج)
  GetPage(
    name: AppRroute.login,
    page: () => AuthScreen(),
    binding: AuthBinding(),
  ),
  GetPage(
    name: AppRroute.register,
    page: () => AuthScreen(),
    binding: AuthBinding(),
  ),

  // ========== GENERAL ==========
  GetPage(name: AppRroute.splash, page: () => const SplashScreen()),
  GetPage(name: AppRroute.mainScreenGuest, page: () => MainScreenGuest()),
  GetPage(name: AppRroute.notificationsView, page: () => NotificationsView()),
  GetPage(name: AppRroute.conversations, page: () => const ConversationsScreen()),
  GetPage(name: AppRroute.aiChat,page: () => AiChatScreen(),binding: AiChatBinding()),
  GetPage(name: AppRroute.changePassword, page: () => ChangePasswordScreen()),
  GetPage(name: AppRroute.privacyPolicy, page: () => PrivacyPolicyScreen()),
  GetPage(name: AppRroute.contactSupport, page: () => ContactAdminScreen()),

  // ================================================== CHAT (with arguments) ==========
  GetPage(
      name: AppRroute.chat,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return ChatScreen(otherPartyProfile: args['otherPartyProfile'],conversationId: args['conversationId']);
        }),
  // =========================================================== POSTS (Feed) ==========
  GetPage(name: AppRroute.feed, page: () => FeedScreen(), binding: FeedBinding()),
  GetPage(name: AppRroute.createPost, page: () => CreatePostScreen()),
  GetPage(name: AppRroute.postDetail,page: () => PostDetailScreen(postId: Get.arguments)),
  GetPage(name: AppRroute.pendingPosts, page: () => const PendingPostsScreen()),

  // ======================================================= UNIFIED SETTINGS & PROFILE ==========
  GetPage(
    name: AppRroute.unifiedSetting,
    page: () => SettingScreen(),
    binding: UnifiedSettingBinding(),
  ),
  GetPage(
    name: AppRroute.unifiedProfileScreen,
    page: () => ProfileScreen(),
  ),
  GetPage(
    name: AppRroute.unifiedEditProfile,
    page: () => EditProfileScreen(),
  ),

  // ========================================================================== STUDENT ==========
  GetPage(
    name: AppRroute.mainScreenStudent,
    page: () => MainScreenStudent(),
    binding: MainStudentBinding(),
  ),
 
  GetPage(
    name: AppRroute.studentRequests,
    page: () => StudentRequestsScreen(),
    binding: StudentRequestsBinding(),
  ),
  GetPage(
    name: AppRroute.showOwnedStudentRequest,
    page: () => ShowOwnedStudentRequest(),
  ),
  GetPage(
    name: AppRroute.viewVerify,
    page: () => ViewVerifyPage(),
  ),

  // ========== PATIENT ==========
  GetPage(
    name: AppRroute.mainScreenPatient,
    page: () => MainScreenPatient(),
    binding: MainPatientBinding(),
  ),
];

class AppRroute {
  static const String onboarding = '/onboarding';
  // ========== AUTH ==========
  static const String login = "/login";
  static const String register = "/register";
  static const String auth = "/auth";

  // ========== GENERAL ==========
  static const String notificationsView = "/notifications";
  static const String chat = "/chat";
  static const String conversations = "/conversations";
  static const String viewOtherProfile = "/viewOtherProfile";
  static const String aiChat = "/aiChat";
  static const String changePassword = "/change_password";
  static const String privacyPolicy = "/privacy_policy";
  static const String contactSupport = "/contact_support";
  static const String splash = "/splash";

  // ========== POSTS ==========
  static const String feed = "/feed";
  static const String createPost = "/create_post";
  static const String postDetail = "/post_detail";
  static const String pendingPosts = '/pending_posts';

  // ========== UNIFIED ==========
  static const String unifiedSetting = "/unified_setting";
  static const String unifiedProfileScreen = "/unifiedProfileScreen";
  static const String unifiedEditProfile = "/unified_edit_profile";
  static const String mainScreenGuest = "/mainScreenGuest";

  // ========== STUDENT ==========
  static const String mainScreenStudent = "/mainScreenStudent";
  static const String studentRequests = "/studentRequests";
  static const String showOwnedStudentRequest = "/showOwnedStudentRequest";
  static const String viewVerify = "/viewVerify";

  // ========== PATIENT ==========
  static const String mainScreenPatient = "/mainScreenPatient";

  // ========== LEGACY (keep if needed) ==========
  static const String notifications = "/notifications";
  static const String profile = "/profile";
}
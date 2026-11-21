import 'server_config.dart';

class ApiLink {
  // ===== العنوان الأساسي (يتغير وقت التشغيل من شاشة الإعداد) =====
  static String get servere => '${ServerConfig.baseUrl}/api';
  static String get kSocketBaseUrl => ServerConfig.baseUrl;

  // static const String apiAi = "http://localhost:11434";
  static String get aiChat => '$servere/ai/chat';
  static String get aiHistory => '$servere/ai/history';

  // ========================auth
  static String get login => '$servere/auth/login';
  static String get register => '$servere/auth/register';
  static String get logout => '$servere/auth/logout';

  // ===========================all user
  static String get profile => '$servere/profile';
  static String get photo => '$servere/users/photo';
  static String get conversations => '$servere/conversations';
  static String get getOtherProfile => '$servere/users';
  static String get report => '$servere/reports';
  static String get supportMessage => '$servere/support';
  static String get requests => '$servere/request';
  static String get posts => '$servere/posts';
  static String get getPendingPosts => '$servere/posts/pending';
  static String get comments => '$servere/posts/comments';
  static String get changePassword => '$servere/auth/change-password';
  static String get dashboard => '$servere/dashboard';

  // =========================== student
  static String get acceptRequest => '$servere/request/accept';
  static String get dunningOverseer => '$servere/request/reassign-overseer';
  static String get verify => '$servere/auth/verify';
  static String get getOverSeerForCourse => '$servere/request/course-overseers';

  // =========================== requests
  static String get getPendingRequest => '$servere/request/pending';
  static String get getCompletedRequests => '$servere/request/finished';
  static String get getRejectedRequests => '$servere/request/rejected';
  static String get getProcessingRequests => '$servere/request/processing';

  // ========================= treatment
  static String get getTreatments => '$servere/admin/treatment';

  // =========================== ml (التنبؤ بإمكانية العلاج)
  static String get predictTreatment => '$servere/ml/predict';

  // =========================== treatment-ml (التنبؤ بنوع المعالجة)
  static String get predictCaseType =>
      '$servere/treatment-ml/predict-with-image';
}
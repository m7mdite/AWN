class ApiLink {
  static const String servere = 'http://localhost:5000/api';
  static const String kSocketBaseUrl = 'http://localhost:5000';

  // static const String servere = 'http://mohammed-awad.local:5000/api';
  // static const String kSocketBaseUrl = 'http://mohammed-awad.local:5000';
  // static const String apiAi = "http://localhost:11434";
  // static const String apiAi = "http://10.97.1.102:11434";
  static const String aiChat = '$servere/ai/chat';
  static const String aiHistory = '$servere/ai/history';

  // static const String servere = 'http://10.97.1.103:5000/api';
  // static const String kSocketBaseUrl = 'http://10.97.1.103:5000';

  // ========================auth
  static const String login = '$servere/auth/login';
  static const String register = '$servere/auth/register';
  static const String logout = "$servere/auth/logout";
  // ===========================all user
  static const String profile = '$servere/profile';
  static const String photo = '$servere/users/photo';
  static const String conversations = '$servere/conversations';
  static const String getOtherProfile = '$servere/users';
  static const String report = '$servere/reports';
  static const String supportMessage = "$servere/support";
  static const String requests = '$servere/request';
  static const String posts = "$servere/posts";
  static const String getPendingPosts = "$servere/posts/pending";
  static const String comments = "$servere/posts/comments";
  static const String changePassword = "$servere/auth/change-password";
  static const String dashboard = "$servere/dashboard";

  // =========================== student
  static const String acceptRequest = '$servere/request/accept';
  static const String dunningOverseer = '$servere/request/reassign-overseer';

  static const String verify = '$servere/auth/verify';
  static const String getOverSeerForCourse =
      '$servere/request/course-overseers';

  // =========================== requests
  static const String getPendingRequest = '$servere/request/pending';

  static const String getCompletedRequests = '$servere/request/finished';

  static const String getRejectedRequests = '$servere/request/rejected';

  static const String getProcessingRequests = '$servere/request/processing';
  // ========================= treatment
  static const String getTreatments = '$servere/admin/treatment';

  // =========================== ml (التنبؤ بإمكانية العلاج)
  static const String predictTreatment = '$servere/ml/predict';
  // =========================== treatment-ml (التنبؤ بنوع المعالجة)
  static const String predictCaseType =
      '$servere/treatment-ml/predict-with-image';
}

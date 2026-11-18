import '../../services/remote/crud.dart';
import '../../api_link.dart';
// import '../../utils/app_constants/status_request.dart';

class DashboardRemote {
  final Crud crud;
  DashboardRemote(this.crud);
  Future<ApiResult> getDashboard() => crud.getData(ApiLink.dashboard);
}

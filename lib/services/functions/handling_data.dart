import '../../utils/app_constants/status_request.dart';

dynamic handlingData(dynamic response){
  if(response is ! StatusRequest){
    return StatusRequest.success;
    
  }else{
    return response;
  }
}
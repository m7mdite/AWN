import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';

import '../../../api_link.dart';
import '../../../services/remote/crud.dart';

class RequestRemote {
  final Crud _crud = Get.find<Crud>();

  // final _crud _crud;
  // RequestRemote(this._crud);

  // ========== GET ==========
  Future<ApiResult> getPendingRequests() =>
      _crud.getData(ApiLink.getPendingRequest);
  Future<ApiResult> getTreatments() =>
      _crud.getData(ApiLink.getTreatments);

  Future<ApiResult> getProcessingRequest() =>
      _crud.getData(ApiLink.getProcessingRequests);

  Future<ApiResult> getCompletedRequest() =>
      _crud.getData(ApiLink.getCompletedRequests);

  Future<ApiResult> getRejectedPatientRequest() =>
      _crud.getData(ApiLink.getRejectedRequests);

  Future<ApiResult> getOverSeerForCourse(String id) =>
      _crud.getData('${ApiLink.getOverSeerForCourse}/$id');

  // ========== POST / PUT / DELETE ==========
  Future<ApiResult> acceptRequestData(Map data, String idR, String idO) =>
      _crud.postData('${ApiLink.acceptRequest}/$idR/$idO', data);

  /// تعيين مشرف للطلب (PUT .../{idR} مع id المشرف).
  Future<ApiResult> dunningOverseerData(Map data, String idR, String idO) =>
      _crud.putData('${ApiLink.dunningOverseer}/$idR', data, id: idO);

  Future<ApiResult> deleteRequest(String id) =>
      _crud.deleteData(ApiLink.requests, id);

  /// التنبؤ بإمكانية علاج الحالة (اختياري).
  /// عند النجاح: data = {prediction, prediction_code, confidence}
  Future<ApiResult> predictTreatment(Map<String, dynamic> data) =>
      _crud.postData(ApiLink.predictTreatment, data);

  /// التنبؤ بنوع المعالجة. الصورة اختيارية.
  Future<ApiResult> predictCaseType(Map<String, dynamic> data, File? image) =>
      _crud.postDataWithFiles(
        ApiLink.predictCaseType,
        _convertToStringMap(data),
        image != null ? [image.path] : [],
        'image',
      );

  /// إرسال طلب: JSON بدون صورة، أو Multipart مع صورة.
  Future<ApiResult> sendRequestData(Map<String, dynamic> data, File? image) {
    if (image == null) return _crud.postData(ApiLink.requests, data);
    return _crud.postDataWithFiles(
      ApiLink.requests,
      _convertToStringMap(data),
      [image.path],
      'photo',
    );
  }

  /// تحديث طلب: JSON بدون صورة، أو Multipart مع صورة.
  Future<ApiResult> updateRequestData(
    Map<String, dynamic> data,
    File? image,
    String id,
  ) {
    if (image == null) return _crud.putData(ApiLink.requests, data, id: id);
    return _crud.putDataWithFiles(
      '${ApiLink.requests}/$id',
      _convertToStringMap(data),
      [image.path],
      'photo',
    );
  }

  Map<String, String> _convertToStringMap(Map<String, dynamic> data) {
    final result = <String, String>{};
    data.forEach((key, value) {
      if (value == null) return;
      result[key] = key == 'more_details' ? jsonEncode(value) : value.toString();
    });
    return result;
  }
}
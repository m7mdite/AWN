import 'dart:io';
import '../../../api_link.dart';
import '../../../services/remote/crud.dart';

class StudentRemote {
  final Crud crud;
  StudentRemote(this.crud);

  Future<ApiResult> sendVerifyDocument(File image) =>
      crud.postDataWithFiles(ApiLink.verify, {}, [image.path], 'document');
}
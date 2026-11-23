import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../api_link.dart';
import '../../models/requests_models/case_photos_model.dart';
import '../../services/functions/show_snack.dart';
import '../../services/remote/crud.dart';
import '../../utils/app_constants/colors_constant.dart';

/// رفع صور الحالة (قبل / بعد المعالجة) من طرف الطالب.
class CasePhotosController extends GetxController {
  final Crud _crud = Get.find<Crud>();

  /// يعرض خيارات (كاميرا / معرض) ويرجع الصورة المختارة.
  /// نضغط الصورة (جودة 80، عرض أقصى 1600) حتى لا نتجاوز حد 5 ميجا بالسيرفر.
  Future<File?> pickImage() async {
    final ImageSource? source = await Get.bottomSheet<ImageSource>(
      Container(
        color: AppColors.background,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'حدد طريقة رفع الصورة',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.camera_alt, color: AppColors.primary),
              title: Text('الكاميرا', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_rounded, color: AppColors.primary),
              title: Text('المعرض', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return null;

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1600,
    );
    return picked == null ? null : File(picked.path);
  }

  /// يرفع الصورة. [which] = 'before' | 'after'.
  /// يرجع الصور المحدثة، أو null عند الفشل (مع إظهار رسالة السيرفر).
  Future<CasePhotosUpdate?> upload({
    required String requestId,
    required String which,
    required File image,
  }) async {
    final result = await _crud.putDataWithFiles(
      '${ApiLink.requests}/processing/$requestId/photo/$which',
      {},
      [image.path],
      'photo',
    );

    CasePhotosUpdate? out;
    switch (result) {
      case ApiSuccess(data: final body):
        showsnack(
          title: 'تم',
          message: body['message']?.toString() ?? 'تم رفع الصورة',
        );
        final data = body['data'];
        if (data is Map) {
          out = CasePhotosUpdate(
            photos: CasePhotos.fromJson(
              data['photos'] is Map ? data['photos'] as Map : <String, dynamic>{},
            ),
            retake: RetakeRequest.tryParse(data['retake_request']),
          );
        }
      case ApiFailure(:final message):
        showsnack(title: 'خطأ', message: message ?? 'تعذر رفع الصورة');
    }
    return out;
  }
}

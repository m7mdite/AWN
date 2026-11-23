import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/public_controllers/case_photos_controller.dart';
import '../../../controllers/public_controllers/unified_setting_controller.dart';
import '../../../models/requests_models/case_photos_model.dart';
import '../../../models/requests_models/treatment_request_model.dart';
import '../../../services/functions/show_image_preview.dart';
import '../../../utils/app_constants/colors_constant.dart';

/// قسم "صور الحالة" (قبل / بعد المعالجة) داخل تفاصيل الطلب.
/// - الطالب + طلب قيد المعالجة: يقدر يضيف أو يستبدل.
///     * صورة قبل: مقفلة بعد أول تقييم مرحلي.
///     * صورة بعد: تتطلب وجود صورة قبل، وتقبل الاستبدال حتى الإنهاء.
/// - باقي الأدوار / الطلبات المكتملة: عرض فقط.
class CasePhotosSection extends StatefulWidget {
  final TreatmentRequestModel requestModel;
  const CasePhotosSection({super.key, required this.requestModel});

  @override
  State<CasePhotosSection> createState() => _CasePhotosSectionState();
}

class _CasePhotosSectionState extends State<CasePhotosSection> {
  bool _busy = false;

  TreatmentRequestModel get _r => widget.requestModel;

  bool get _isStudent {
    if (!Get.isRegistered<UnifiedSettingController>()) return false;
    return Get.find<UnifiedSettingController>().role.value == 'student';
  }

  bool get _editable => _isStudent && _r.status == 'processing';
  bool get _beforeLocked => _r.stageEvaluations?.isNotEmpty ?? false;

  Future<void> _upload(String which) async {
    final id = _r.sId;
    if (id == null) return;

    final ctrl = Get.isRegistered<CasePhotosController>()
        ? Get.find<CasePhotosController>()
        : Get.put(CasePhotosController());

    final file = await ctrl.pickImage();
    if (file == null) return;

    setState(() => _busy = true);
    final update = await ctrl.upload(requestId: id, which: which, image: file);
    if (update != null) {
      // نعدّل نفس الموديل حتى تنعكس الصور بالقائمة بدون إعادة تحميل
      _r.photos = update.photos;
      _r.retakeRequest = update.retake;
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final status = _r.status;
    if (status != 'processing' && status != 'finished') {
      return const SizedBox.shrink();
    }

    final photos = _r.photos;
    final retake = _r.retakeRequest;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.photo_library_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'صور الحالة',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (_busy)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: LinearProgressIndicator(),
            ),
          if (retake != null) ...[
            const SizedBox(height: 8),
            _retakeBanner(retake),
          ],
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _slot(
                  title: 'قبل المعالجة',
                  which: 'before',
                  photo: photos?.before,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _slot(
                  title: 'بعد المعالجة',
                  which: 'after',
                  photo: photos?.after,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _retakeBanner(RetakeRequest r) {
    final note = (r.note != null && r.note!.isNotEmpty) ? ': ${r.note}' : '';
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: AppColors.warning.shade700),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'طلب المشرف إعادة تصوير الصورة (${r.whichLabel})$note',
              style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slot({
    required String title,
    required String which,
    required CasePhoto? photo,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 6),
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: photo == null
                ? _emptyBox('لا توجد صورة')
                : GestureDetector(
                    onTap: () => showImagePreview(photo.url),
                    child: CachedNetworkImage(
                      imageUrl: photo.url,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      errorWidget: (_, _, _) => _emptyBox('تعذر تحميل الصورة'),
                    ),
                  ),
          ),
        ),
        _actions(which, photo),
      ],
    );
  }

  Widget _emptyBox(String text) {
    return Container(
      color: AppColors.grey.withValues(alpha: 0.15),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_outlined, color: AppColors.grey),
            const SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hint(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, color: AppColors.warning.shade700),
      ),
    );
  }

  Widget _actions(String which, CasePhoto? photo) {
    if (!_editable) return const SizedBox.shrink();

    if (which == 'before' && _beforeLocked) {
      return _hint('مقفلة بعد بدء التقييم المرحلي');
    }
    if (which == 'after' && _r.photos?.before == null) {
      return _hint('أضف صورة قبل المعالجة أولاً');
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: OutlinedButton.icon(
        onPressed: _busy ? null : () => _upload(which),
        icon: const Icon(Icons.add_a_photo_outlined, size: 16),
        label: Text(
          photo == null ? 'إضافة' : 'استبدال',
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }
}

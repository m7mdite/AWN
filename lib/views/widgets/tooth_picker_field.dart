import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/app_constants/app_images_constant.dart';
import '../../utils/app_constants/app_theme_constants.dart';
import '../../utils/app_constants/colors_constant.dart';
import '../../utils/app_constants/tooth_chart_data.dart';
import 'botton_controller.dart';
import 'tooth_chart.dart';

/// زر "اختيار السن" بنفس تصميم أزرار التطبيق (BottonContainer).
/// عند الضغط يفتح نافذة فيها مخطط الأسنان، فلا يأخذ المخطط مساحة من النموذج.
class ToothPickerField extends StatelessWidget {
  /// رقم السن الحالي (أو فارغ).
  final String? selected;
  final String? age;
  final ValueListenable<String?>? ageListenable;

  /// يُستدعى عند "تأكيد" برقم السن، أو بنص فارغ عند المسح.
  final ValueChanged<String> onChanged;

  const ToothPickerField({
    super.key,
    required this.selected,
    required this.onChanged,
    this.age,
    this.ageListenable,
  });

  bool get _hasSelection => selected != null && selected!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: BottonContainer(
            body: _hasSelection
                ? 'السن المحدد: ${toothDisplayName(selected)}'
                : 'اختيار السن المراد معالجته',
            paddingHorizontal: 14,
            paddingVertical: 6,
            fontSize: 14,
            onTap: _open,
          ),
        ),
        if (_hasSelection)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'رقم السن: $selected',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
      ],
    );
  }

  void _open() {
    Get.dialog(
      _ToothDialog(
        initial: _hasSelection ? selected!.trim() : null,
        age: age,
        ageListenable: ageListenable,
        onConfirm: onChanged,
      ),
    );
  }
}

class _ToothDialog extends StatefulWidget {
  final String? initial;
  final String? age;
  final ValueListenable<String?>? ageListenable;
  final ValueChanged<String> onConfirm;

  const _ToothDialog({
    required this.initial,
    required this.onConfirm,
    this.age,
    this.ageListenable,
  });

  @override
  State<_ToothDialog> createState() => _ToothDialogState();
}

class _ToothDialogState extends State<_ToothDialog> {
  String? _temp;

  @override
  void initState() {
    super.initState();
    _temp = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final hasTemp = _temp != null && _temp!.isNotEmpty;

    return Dialog(
      backgroundColor: AppColors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: AppColors.transparent,
          border: Border.all(width: 3.5, color: AppColors.borderColor),
          borderRadius: AppThemeConstants.borderRadius,
        ),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppImages.authBackground),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.linearToSrgbGamma(),
              opacity: 0.8,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Text(
                'حدد السن المراد معالجته',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(bottom: 8, top: 8),
                height: 2,
                color: AppColors.white,
                width: 200,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  'اضغط على السن في المخطط (اضغط مرة ثانية لإلغاء الاختيار)',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(height: 8),
              // المخطط داخل منطقة قابلة للتمرير حتى لا يطفح على الشاشات الصغيرة
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: Get.height * 0.55),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ToothChart(
                    selected: _temp,
                    age: widget.age,
                    ageListenable: widget.ageListenable,
                    onChanged: (v) => setState(() => _temp = v),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                hasTemp
                    ? '${toothDisplayName(_temp)}  (رقم $_temp)'
                    : 'لم يتم اختيار سن بعد',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 10),
                height: 2,
                color: AppColors.white,
                width: 200,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _actionButton(
                    label: 'إلغاء',
                    color: AppColors.error,
                    onTap: () => Get.back(),
                  ),
                  _actionButton(
                    label: 'تأكيد',
                    color: AppColors.success,
                    onTap: () {
                      Get.back();
                      widget.onConfirm(_temp ?? '');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          border: Border.all(width: 1.5, color: color),
          borderRadius: AppThemeConstants.borderRadius,
        ),
        child: Text(label, style: TextStyle(color: color)),
      ),
    );
  }
}

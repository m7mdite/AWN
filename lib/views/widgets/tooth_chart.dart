import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../utils/app_constants/colors_constant.dart';
import '../../utils/app_constants/tooth_chart_data.dart';

/// مخطط أسنان تفاعلي: يضغط المريض على السن فيُرجَع رقمه عبر [onChanged].
///
/// - يختار صورة الأطفال أو البالغين حسب العمر ([age] و[ageListenable]).
/// - مواضع الأسنان نسب من الصورة، فيعمل على أي حجم شاشة.
/// - الضغط يختار أقرب سن، فلا توجد مناطق ميتة بين الأسنان.
class ToothChart extends StatefulWidget {
  /// رقم السن المحدد حالياً (مثل "16") أو فارغ.
  final String? selected;

  /// العمر الحالي كنص كما أدخله المريض (قيمة ابتدائية / عند إعادة البناء).
  final String? age;

  /// اختياري: يُحدَّث عند كل تغيير في حقل العمر دون إعادة بناء النموذج كله.
  final ValueListenable<String?>? ageListenable;

  /// يُستدعى برقم السن عند الضغط، وبـ null عند مسح الاختيار.
  final ValueChanged<String?> onChanged;

  /// أقصى عرض للمخطط. على الأجهزة اللوحية يمكن رفعه ليكبر الهدف اللمسي.
  final double maxWidth;

  const ToothChart({
    super.key,
    required this.selected,
    required this.onChanged,
    this.age,
    this.ageListenable,
    this.maxWidth = 360,
  });

  @override
  State<ToothChart> createState() => _ToothChartState();
}

class _ToothChartState extends State<ToothChart> {
  late ToothChartSet _set;
  bool _manual = false; // اختار المستخدم المخطط يدوياً فلا نبدّله حسب العمر
  String? _age;

  @override
  void initState() {
    super.initState();
    _age = widget.age;
    _set = _initialSet();
    widget.ageListenable?.addListener(_onAgeNotifier);
  }

  @override
  void didUpdateWidget(covariant ToothChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ageListenable != widget.ageListenable) {
      oldWidget.ageListenable?.removeListener(_onAgeNotifier);
      widget.ageListenable?.addListener(_onAgeNotifier);
    }
    // لا نستدعي setState هنا: إعادة البناء قادمة أصلاً.
    if (oldWidget.age != widget.age) {
      _age = widget.age;
      _followAge();
    }
    if (oldWidget.selected != widget.selected) _followSelected();
  }

  @override
  void dispose() {
    widget.ageListenable?.removeListener(_onAgeNotifier);
    super.dispose();
  }

  // ---------- منطق اختيار المخطط ----------

  ToothChartSet _initialSet() {
    final s = (widget.selected ?? '').trim();
    if (s.isNotEmpty) {
      if (ToothChartData.adult.teeth.containsKey(s)) return ToothChartSet.adult;
      if (ToothChartData.child.teeth.containsKey(s)) return ToothChartSet.child;
    }
    return toothChartSetForAge(_age);
  }

  void _onAgeNotifier() {
    if (!mounted) return;
    setState(() {
      _age = widget.ageListenable?.value;
      _followAge();
    });
  }

  /// يبدّل المخطط حسب العمر ما لم يختر المستخدم يدوياً.
  void _followAge() {
    if (_manual) return;
    final next = toothChartSetForAge(_age);
    if (next != _set) {
      _set = next;
      _clearIfForeign();
    }
  }

  /// إن كُتب رقم سن يخص المخطط الآخر (من الحقل النصي) نبدّل إليه.
  void _followSelected() {
    final s = (widget.selected ?? '').trim();
    if (s.isEmpty || ToothChartData.of(_set).teeth.containsKey(s)) return;
    final other =
        _set == ToothChartSet.adult ? ToothChartSet.child : ToothChartSet.adult;
    if (ToothChartData.of(other).teeth.containsKey(s)) _set = other;
  }

  /// السن المحدد لا يخص المخطط الحالي ← نمسحه حتى لا يبقى رقم لا يطابق الصورة.
  void _clearIfForeign() {
    final s = (widget.selected ?? '').trim();
    if (s.isNotEmpty && !ToothChartData.of(_set).teeth.containsKey(s)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onChanged(null);
      });
    }
  }

  void _choose(ToothChartSet s) {
    setState(() {
      _set = s;
      _manual = true;
    });
    _clearIfForeign();
  }

  // ---------- الواجهة ----------

  Widget _chip(String label, ToothChartSet s) => ChoiceChip(
        label: Text(label),
        selected: _set == s,
        selectedColor: AppColors.primaryAccent,
        onSelected: (_) => _choose(s),
      );

  @override
  Widget build(BuildContext context) {
    final data = ToothChartData.of(_set);
    final sel = (widget.selected ?? '').trim();
    final age = int.tryParse((_age ?? '').trim());
    final mixed = age != null && age >= 6 && age <= 12;
    final name = toothDisplayName(sel);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          children: [
            _chip('أسنان الأطفال', ToothChartSet.child),
            _chip('أسنان البالغين', ToothChartSet.adult),
          ],
        ),
        if (mixed)
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Text(
              'أسنان مختلطة (6 إلى 12 سنة): اختر المخطط الذي يحتوي السن المطلوب.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.maxWidth),
          child: AspectRatio(
            aspectRatio: data.aspectRatio,
            child: LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final h = c.maxHeight;
                final marker = data.teeth[sel];
                final d = w * 0.11; // قطر علامة السن نسبةً للعرض
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (t) {
                    final p = Offset(
                      (t.localPosition.dx / w).clamp(0.0, 1.0),
                      (t.localPosition.dy / h).clamp(0.0, 1.0),
                    );
                    widget.onChanged(data.nearest(p));
                  },
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.asset(data.asset, fit: BoxFit.fill),
                        ),
                      ),
                      if (marker != null)
                        Positioned(
                          left: marker.dx * w - d / 2,
                          top: marker.dy * h - d / 2,
                          width: d,
                          height: d,
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: AppColors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryAccent,
                                    blurRadius: 14,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        if (sel.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              name.isEmpty ? 'السن المحدد: $sel' : 'السن المحدد: $sel — $name',
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

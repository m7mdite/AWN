import 'dart:ui' show Offset;

import 'tooth_constants.dart';

/// نوع مخطط الأسنان المعروض.
enum ToothChartSet { adult, child }

/// بيانات مخطط واحد: الصورة، نسبة أبعادها، ومراكز الأسنان كنسب (0..1)
/// من عرض الصورة وارتفاعها. لأنها نسب، تبقى صحيحة على أي حجم شاشة.
class ToothChartData {
  final String asset;
  final double aspectRatio; // العرض ÷ الارتفاع للصورة الأصلية
  final Map<String, Offset> teeth;

  const ToothChartData({
    required this.asset,
    required this.aspectRatio,
    required this.teeth,
  });

  /// مخطط البالغين (848×1264)، الأسنان الدائمة 11–48.
  static const adult = ToothChartData(
    asset: 'images/images_asnan/tooth_number.png',
    aspectRatio: 848 / 1264,
    teeth: {
    '11': Offset(0.454, 0.123),
    '12': Offset(0.368, 0.136),
    '13': Offset(0.318, 0.176),
    '14': Offset(0.274, 0.220),
    '15': Offset(0.233, 0.273),
    '16': Offset(0.206, 0.326),
    '17': Offset(0.189, 0.392),
    '18': Offset(0.189, 0.447),
    '21': Offset(0.545, 0.123),
    '22': Offset(0.627, 0.142),
    '23': Offset(0.682, 0.176),
    '24': Offset(0.719, 0.218),
    '25': Offset(0.764, 0.277),
    '26': Offset(0.792, 0.331),
    '27': Offset(0.808, 0.396),
    '28': Offset(0.811, 0.457),
    '31': Offset(0.537, 0.878),
    '32': Offset(0.590, 0.870),
    '33': Offset(0.643, 0.847),
    '34': Offset(0.690, 0.807),
    '35': Offset(0.743, 0.752),
    '36': Offset(0.796, 0.684),
    '37': Offset(0.814, 0.623),
    '38': Offset(0.808, 0.563),
    '41': Offset(0.458, 0.878),
    '42': Offset(0.407, 0.870),
    '43': Offset(0.354, 0.850),
    '44': Offset(0.309, 0.811),
    '45': Offset(0.262, 0.752),
    '46': Offset(0.212, 0.690),
    '47': Offset(0.200, 0.625),
    '48': Offset(0.200, 0.558),
    },
  );

  /// مخطط الأطفال (1024×1536)، الأسنان اللبنية 51–85.
  static const child = ToothChartData(
    asset: 'images/images_asnan/tooth_number_child.png',
    aspectRatio: 1024 / 1536,
    teeth: {
    '51': Offset(0.444, 0.146),
    '52': Offset(0.352, 0.168),
    '53': Offset(0.291, 0.212),
    '54': Offset(0.244, 0.267),
    '55': Offset(0.210, 0.332),
    '61': Offset(0.552, 0.146),
    '62': Offset(0.646, 0.168),
    '63': Offset(0.707, 0.212),
    '64': Offset(0.757, 0.267),
    '65': Offset(0.791, 0.332),
    '71': Offset(0.441, 0.833),
    '72': Offset(0.344, 0.807),
    '73': Offset(0.276, 0.765),
    '74': Offset(0.242, 0.706),
    '75': Offset(0.210, 0.641),
    '81': Offset(0.559, 0.833),
    '82': Offset(0.659, 0.807),
    '83': Offset(0.728, 0.765),
    '84': Offset(0.764, 0.706),
    '85': Offset(0.793, 0.641),
    },
  );

  static ToothChartData of(ToothChartSet set) =>
      set == ToothChartSet.adult ? adult : child;

  /// أقرب سن إلى النقطة [p] (نسب 0..1). نصحّح المسافة الأفقية بنسبة
  /// الأبعاد حتى تُقاس المسافتان بنفس الوحدة.
  String nearest(Offset p) {
    String best = teeth.keys.first;
    double bestDist = double.infinity;
    teeth.forEach((k, o) {
      final dx = (o.dx - p.dx) * aspectRatio;
      final dy = o.dy - p.dy;
      final d = dx * dx + dy * dy;
      if (d < bestDist) {
        bestDist = d;
        best = k;
      }
    });
    return best;
  }
}

/// المخطط المناسب للعمر: 13 فأكثر أو غير معروف ← بالغين، وغير ذلك ← أطفال
/// (6–12 سنة أسنان مختلطة، يبدّل المستخدم يدوياً عند الحاجة).
ToothChartSet toothChartSetForAge(String? age) {
  final a = int.tryParse((age ?? '').trim());
  if (a == null) return ToothChartSet.adult;
  return a >= 13 ? ToothChartSet.adult : ToothChartSet.child;
}

const _permanent = <int, (String, bool)>{
  1: ('ثنية', true),
  2: ('رباعية', true),
  3: ('ناب', false),
  4: ('ضاحك أول', false),
  5: ('ضاحك ثاني', false),
  6: ('رحى أولى', true),
  7: ('رحى ثانية', true),
  8: ('رحى ثالثة', true),
};

const _primary = <int, (String, bool)>{
  1: ('ثنية', true),
  2: ('رباعية', true),
  3: ('ناب', false),
  4: ('رحى أولى', true),
  5: ('رحى ثانية', true),
};

/// اسم السن مولَّداً من رقمه (الأرباع 1–4 دائمة، 5–8 لبنية). فارغ إن لم يُعرف.
String generatedToothName(String? number) {
  final s = (number ?? '').trim();
  if (s.length != 2) return '';
  final q = int.tryParse(s[0]) ?? 0;
  final p = int.tryParse(s[1]) ?? 0;
  if (q < 1 || q > 8) return '';
  final isPrimary = q >= 5;
  final e = (isPrimary ? _primary : _permanent)[p];
  if (e == null) return '';
  final upper = isPrimary ? q <= 6 : q <= 2;
  final right = isPrimary ? (q == 5 || q == 8) : (q == 1 || q == 4);
  final adj = upper ? (e.$2 ? 'علوية' : 'علوي') : (e.$2 ? 'سفلية' : 'سفلي');
  return '${e.$1} $adj ${right ? 'يمين' : 'يسار'}${isPrimary ? ' (لبنية)' : ''}';
}

/// اسم السن للعرض: من ToothConstants إن وُجد، وإلا المولَّد (للأسنان اللبنية).
String toothDisplayName(String? number) {
  final fromMap = ToothConstants.toothLocationMap[(number ?? '').trim()];
  if (fromMap != null && fromMap.trim().isNotEmpty) return fromMap;
  return generatedToothName(number);
}

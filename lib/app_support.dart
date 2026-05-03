import 'package:intl/intl.dart';

String bi(String sw, String en) {
  final swTrimmed = sw.trim();
  final enTrimmed = en.trim();
  if (swTrimmed.isEmpty) {
    return enTrimmed;
  }
  if (enTrimmed.isEmpty) {
    return swTrimmed;
  }
  return swTrimmed.length <= enTrimmed.length ? swTrimmed : enTrimmed;
}

String sanitizeUiText(String text) {
  final parts = text
      .split(RegExp(r'\s*/\s*'))
      .map((String part) => part.trim())
      .where((String part) => part.isNotEmpty)
      .toList();

  if (parts.length < 2) {
    return text;
  }

  final digitParts =
      parts.where((String part) => RegExp(r'\d').hasMatch(part)).toList();
  final candidates = digitParts.isEmpty ? parts : digitParts;

  return candidates.reduce(
    (String shortest, String current) =>
        current.length < shortest.length ? current : shortest,
  );
}

String formatTzs(num value) =>
    'TZS ${NumberFormat.decimalPattern().format(value)}';

String formatTzsPerKg(num value) => '${formatTzs(value)} kwa kg';

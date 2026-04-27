import 'package:url_launcher/url_launcher.dart';

String normalizePhoneNumber(String phone) {
  var digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.startsWith('00')) {
    digits = digits.substring(2);
  }
  if (digits.startsWith('0')) {
    digits = '255${digits.substring(1)}';
  }
  if (digits.startsWith('255')) {
    return digits;
  }
  return digits;
}

Future<bool> openWhatsApp(String phone, {String? message}) async {
  final normalized = normalizePhoneNumber(phone);
  if (normalized.isEmpty) {
    return false;
  }

  final text = Uri.encodeComponent(message ?? 'Hello, I am interested in your post.');
  final uri = Uri.parse('https://wa.me/$normalized?text=$text');
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<bool> openDialer(String phone) async {
  final value = phone.trim();
  if (value.isEmpty) {
    return false;
  }

  final uri = Uri(scheme: 'tel', path: value);
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}

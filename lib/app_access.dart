const Set<String> _bootstrapAdminEmails = <String>{
  'mkorihafidhi@gmail.com',
};

bool isBootstrapAdminEmail(String? email) {
  final normalized = email?.trim().toLowerCase() ?? '';
  return _bootstrapAdminEmails.contains(normalized);
}

String resolveUserRole(Map<String, dynamic>? userData, String? email) {
  final role = (userData?['role'] ?? '').toString().trim().toLowerCase();
  if (role == 'admin' || isBootstrapAdminEmail(email)) {
    return 'admin';
  }
  return 'user';
}

bool isAdminUser(Map<String, dynamic>? userData, String? email) =>
    resolveUserRole(userData, email) == 'admin';

String defaultRoleForEmail(String? email) =>
    isBootstrapAdminEmail(email) ? 'admin' : 'user';

class Validators {
  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final cleaned = value.replaceAll(RegExp(r'[\s\-+]'), '');
    if (cleaned.length < 10) return 'Invalid phone number';
    if (!RegExp(r'^\d{10,12}$').hasMatch(cleaned)) return 'Invalid phone number';
    return null;
  }

  static String? abha(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    final cleaned = value.replaceAll(RegExp(r'[\s\-]'), '');
    if (!RegExp(r'^\d{12,14}$').hasMatch(cleaned)) return 'Invalid ABHA ID';
    return null;
  }

  static String? required(String? value, [String field = 'This field']) {
    if (value == null || value.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Invalid email';
    }
    return null;
  }

  static bool isValidAbha(String id) {
    final cleaned = id.replaceAll(RegExp(r'[\s\-]'), '');
    return RegExp(r'^\d{12,14}$').hasMatch(cleaned);
  }

  static bool isValidPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[\s\-+]'), '');
    return RegExp(r'^\d{10,12}$').hasMatch(cleaned);
  }
}
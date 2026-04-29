class ApiConstants {
  static const String _defaultBaseUrl = 'https://smartkidshub.runasp.net';
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  static String get baseUrl {
    final url = _configuredBaseUrl.trim();
    if (url.isEmpty) return _defaultBaseUrl;
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static const String registerParent = '/api/auth/register-parent';
  static const String verifyOtp = '/api/auth/verify-otp';
  static const String addChild = '/api/children';
  static const String getChildren = '/api/children';
  static const String login = '/api/auth/login';
  static const String logout = '/api/auth/logout';
  static const String refreshToken = '/api/auth/refresh-token';
  static const String forgotPassword = '/api/auth/forgot-password';
  static const String resendCode = '/api/auth/resend-code';
  static const String setNewPassword = '/api/auth/set-new-password';
  static const String updateWeight = '/api/ScaleReading/update-weight';
  static const String generateDietPlan = '/api/DietPlan/generate';
  static const String getDietPlan = '/api/DietPlan'; 
}

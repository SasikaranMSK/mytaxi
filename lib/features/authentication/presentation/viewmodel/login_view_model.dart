class LoginViewModel {
  final String username;
  final String password;
  final bool rememberMe;
  final bool obscure;

  const LoginViewModel({
    required this.username,
    required this.password,
    required this.rememberMe,
    required this.obscure,
  });

  factory LoginViewModel.initial() => const LoginViewModel(
    username: '',
    password: '',
    rememberMe: true,
    obscure: true,
  );

  LoginViewModel copyWith({
    String? username,
    String? password,
    bool? rememberMe,
    bool? obscure,
  }) {
    return LoginViewModel(
      username: username ?? this.username,
      password: password ?? this.password,
      rememberMe: rememberMe ?? this.rememberMe,
      obscure: obscure ?? this.obscure,
    );
  }

  String? get usernameError {
    return validateUsername(username);
  }

  String? get passwordError {
    return validatePassword(password);
  }

  bool get canSubmit => usernameError == null && passwordError == null;

  String get usernameValue => username.trim();
  String get passwordValue => password.trim();

  static String? validateUsername(String value) {
    final v = value.trim();
    if (v.isEmpty) return 'Username is required';
    if (v.length < 3) return 'Username is too short';
    return null;
  }

  static String? validatePassword(String value) {
    final v = value;
    if (v.trim().isEmpty) return 'Password is required';
    if (v.length < 4) return 'Password is too short';
    return null;
  }
}

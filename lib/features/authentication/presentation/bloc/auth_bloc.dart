import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meter_taxi/features/authentication/domain/usecases/authentications/login_usecase.dart';
import 'package:meter_taxi/features/authentication/domain/usecases/authentications/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase _login;
  final LogoutUseCase _logout;

  AuthBloc(this._login, this._logout) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final auth = await _login(
        username: event.username,
        password: event.password,
      );

      if (auth == null) {
        emit(AuthFailure('Login failed - no data returned'));
        return;
      }

      emit(AuthSuccess(auth));
    } catch (e) {
      // Extract clean error message
      String errorMessage = e.toString();

      // Remove 'Exception: ' prefix if present
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      // Trim and ensure we have a message
      errorMessage = errorMessage.trim();
      if (errorMessage.isEmpty) {
        errorMessage = 'Login failed';
      }

      emit(AuthFailure(errorMessage));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await _logout();
      emit(AuthLoggedOut());
      emit(AuthInitial());
    } catch (_) {
      // even if something fails, clear UI state
      emit(AuthLoggedOut());
      emit(AuthInitial());
    }
  }
}

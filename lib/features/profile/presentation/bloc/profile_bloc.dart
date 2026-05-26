import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../authentication/data/datasources/auth_local_datasource.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../viewmodel/profile_view_model.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final AuthenticationLocalDataSource authLocalDataSource;
  final BuildContext? context;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.authLocalDataSource,
    this.context,
  }) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<RefreshProfile>(_onRefreshProfile);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    await _fetchProfile(emit);
  }

  Future<void> _onRefreshProfile(
    RefreshProfile event,
    Emitter<ProfileState> emit,
  ) async {
    await _fetchProfile(emit);
  }

  Future<void> _fetchProfile(Emitter<ProfileState> emit) async {
    try {
      final token = await authLocalDataSource.getToken();

      if (token == null || token.isEmpty) {
        emit(const ProfileError('No authentication token found'));
        return;
      }

      final profileEntity = await getProfileUseCase(token, context);

      if (profileEntity == null) {
        emit(const ProfileError('Failed to load profile'));
        return;
      }

      final profileVm = ProfileViewModel.fromEntity(profileEntity);
      emit(ProfileLoaded(profileVm));
    } catch (e) {
      emit(ProfileError(e.toString().replaceAll('Exception: ', '')));
    }
  }

}

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasources/location_datasource.dart';
import '../../domain/usecases/store_location_history_usecase.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final LocationDataSource ds;
  final StoreLocationHistoryUseCase storeLocationHistoryUseCase;
  StreamSubscription? _sub;

  MapBloc({required this.ds, required this.storeLocationHistoryUseCase})
    : super(MapState.initial()) {
    on<MapStarted>(_onStart);
    on<MapStopped>(_onStop);
    on<MapLocationUpdated>(_onUpdated);
  }

  Future<void> _onStart(MapStarted event, Emitter<MapState> emit) async {
    emit(state.copyWith(loading: true, error: null));

    try {
      final first = await ds.getCurrentLocation();

      // ✅ IMPORTANT: permission denied / null case
      if (first == null) {
        emit(
          state.copyWith(
            loading: false,
            error:
                "Location permission denied. Please allow location and refresh.",
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          loading: false,
          error: null,
          lat: first.lat,
          lng: first.lng,
        ),
      );

      // Store the first location
      await storeLocationHistoryUseCase(lat: first.lat, lng: first.lng);

      await _sub?.cancel();
      _sub = ds.streamLocation().listen(
        (loc) {
          // ✅ stream can also return null if permission/service off
          if (loc == null) return;
          add(MapLocationUpdated(lat: loc.lat, lng: loc.lng));
        },
        onError: (e) {
          add(MapStopped());
          emit(state.copyWith(loading: false, error: e.toString()));
        },
      );
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  Future<void> _onStop(MapStopped event, Emitter<MapState> emit) async {
    await _sub?.cancel();
    _sub = null;
  }

  void _onUpdated(MapLocationUpdated event, Emitter<MapState> emit) {
    emit(
      state.copyWith(
        loading: false,
        error: null,
        lat: event.lat,
        lng: event.lng,
      ),
    );

    // Store location history with automatic cleanup of data older than 5 minutes
    storeLocationHistoryUseCase(lat: event.lat, lng: event.lng);
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/fetch_and_save_vehicle_usecase.dart';
import '../../../tariff/domain/usecases/fetch_and_save_tariffs_by_vehicle_type_id_v2_usecase.dart';

import 'vehicle_event.dart';
import 'vehicle_state.dart';
import '../viewmodel/vehicle_view_model.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final FetchAndSaveVehicleUseCase _fetchVehicle;
  final FetchAndSaveTariffsByVehicleTypeIdV2UseCase _fetchTariffsV2;

  VehicleBloc(this._fetchVehicle, this._fetchTariffsV2)
      : super(VehicleInitial()) {
    on<VehicleSubmitted>(_onSubmitted);
    on<VehicleReset>(_onReset);
  }

  Future<void> _onSubmitted(
      VehicleSubmitted event,
      Emitter<VehicleState> emit,
      ) async {
    final vehicleNo = event.vehicleNo.trim();
    if (vehicleNo.isEmpty) {
      emit(VehicleFailure('Vehicle number is required'));
      return;
    }

    emit(VehicleLoading());

    try {
      // 1) Domain returns Entity
      final vehicleEntity = await _fetchVehicle(
        FetchAndSaveVehicleParams(
          networkId: event.networkId,
          vehicleNo: vehicleNo,
        ),
      ).timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        debugPrint('====== VEHICLE FETCHED ======');
        debugPrint('Vehicle ID: ${vehicleEntity.id}');
        debugPrint('Vehicle No: ${vehicleEntity.vehicleNo}');
        debugPrint('Vehicle Type ID: ${vehicleEntity.vehicleTypeId}');
        debugPrint('=============================');
      }

      // Convert Entity -> ViewModel for UI
      final vehicleVm = VehicleViewModel.fromEntity(vehicleEntity);

      // Emit success immediately so navigation is never blocked by tariff prefetch.
      emit(VehicleSuccess(vehicleVm));

      // Best-effort tariff prefetch in background.
      unawaited(_prefetchTariffs(vehicleEntity.vehicleTypeId));
    } on TimeoutException {
      emit(
        VehicleFailure(
          'Vehicle verification timed out. Please check internet and try again.',
        ),
      );
    } catch (e) {
      final raw = e.toString();
      final cleaned = raw.replaceFirst(RegExp(r'^Exception:\\s*'), '').trim();
      final message = cleaned.isNotEmpty ? cleaned : 'Vehicle fetch failed';
      emit(VehicleFailure(message));
    }
  }

  void _onReset(VehicleReset event, Emitter<VehicleState> emit) {
    emit(VehicleInitial());
  }

  Future<void> _prefetchTariffs(int vehicleTypeId) async {
    try {
      final tariffs = await _fetchTariffsV2(
        vehicleTypeId,
      ).timeout(const Duration(seconds: 15));
      if (kDebugMode) {
        debugPrint('====== TARIFF RESPONSE (v2) ======');
        debugPrint('Total tariffs fetched: ${tariffs.length}');
        for (final tariff in tariffs) {
          debugPrint(
            'Tariff ID: ${tariff.vehicleTypeTarifId}, '
            'TarifId: ${tariff.tarifId}, '
            'VehicleTypeId: ${tariff.vehicleTypeId}, '
            'Active: ${tariff.active}',
          );
        }
        debugPrint('==================================');
      }
    } catch (tariffError) {
      if (kDebugMode) {
        debugPrint('====== TARIFF FETCH ERROR ======');
        debugPrint('Error: $tariffError');
        debugPrint('================================');
      }
    }
  }
}

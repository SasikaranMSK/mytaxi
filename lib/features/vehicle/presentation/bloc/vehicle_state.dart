import '../viewmodel/vehicle_view_model.dart';

abstract class VehicleState {}

class VehicleInitial extends VehicleState {}

class VehicleLoading extends VehicleState {}

class VehicleSuccess extends VehicleState {
  final VehicleViewModel vehicle;

  VehicleSuccess(this.vehicle);
}

class VehicleFailure extends VehicleState {
  final String message;

  VehicleFailure(this.message);
}

abstract class VehicleEvent {}

class VehicleSubmitted extends VehicleEvent {
  final int networkId;
  final String vehicleNo;

  VehicleSubmitted({required this.networkId, required this.vehicleNo});
}

class VehicleReset extends VehicleEvent {}

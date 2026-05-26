/// API Configuration
class ApiConfig {
  // API base URL
  static const String baseUrl = 'https://mytaxis.softclient.com.au';

  // API Endpoints
  static const String vehicleTariffsByVehicleId =
      '/taxis-api/api/VehicleTarifs/Tarifs';
  static const String tariffsByVehicleTypeId = '/taxis-api/api/VehicleType';

  static const String devicePublicVehicle =
      '/devices-api/api/DevicePublic/Vehicle';

  // Timeout configurations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Example vehicle type IDs for testing
  static const int exampleVehicleTypeId = 2;
  static const int exampleVehicleId = 1;
}

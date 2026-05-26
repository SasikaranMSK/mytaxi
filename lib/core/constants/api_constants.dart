class ApiConstants {
  static const String apiBaseURL = 'https://mytaxis.softclient.com.au';

  // Auth endpoints (use exactly)
  static const String loginPath = '/taxis-api/api/Authentications/Login';
  static const String logoutPath = '/taxis-api/api/Authentications/Logout';

  // Profile endpoints
  static const String profilePath = '/taxis-api/api/Profile';

  // Tariff endpoints
  static String getTariffsByVehicleIdPath(int vehicleId) =>
      '/taxis-api/api/VehicleTarifs/Tarifs/$vehicleId';
  static String getTariffsByVehicleTypeIdPath(int vehicleTypeId) =>
      '/taxis-api/api/VehicleType/$vehicleTypeId/Tarifs';
  static String getTariffsByVehicleTypeIdV2Path(int vehicleTypeId) =>
      '/taxis-api/api/VehicleType/$vehicleTypeId/Tarifs/v2';
}

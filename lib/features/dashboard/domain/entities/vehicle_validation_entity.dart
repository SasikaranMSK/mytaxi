class VehicleValidationEntity {
  final bool isValid;
  final bool isDriverAuthorized;
  final bool areDocumentsValid;
  final String? message;
  final List<String>? invalidDocuments;

  const VehicleValidationEntity({
    required this.isValid,
    required this.isDriverAuthorized,
    required this.areDocumentsValid,
    this.message,
    this.invalidDocuments,
  });
}

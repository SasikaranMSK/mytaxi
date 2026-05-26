import '../../domain/entities/vehicle_validation_entity.dart';

class VehicleValidationModel extends VehicleValidationEntity {
  const VehicleValidationModel({
    required super.isValid,
    required super.isDriverAuthorized,
    required super.areDocumentsValid,
    super.message,
    super.invalidDocuments,
  });

  factory VehicleValidationModel.fromJson(Map<String, dynamic> json) {
    return VehicleValidationModel(
      isValid: json['isValid'] ?? json['valid'] ?? false,
      isDriverAuthorized:
          json['isDriverAuthorized'] ?? json['authorized'] ?? false,
      areDocumentsValid:
          json['areDocumentsValid'] ?? json['documentsValid'] ?? false,
      message: json['message']?.toString(),
      invalidDocuments: json['invalidDocuments'] != null
          ? List<String>.from(json['invalidDocuments'])
          : json['errors'] != null
          ? List<String>.from(json['errors'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isValid': isValid,
      'isDriverAuthorized': isDriverAuthorized,
      'areDocumentsValid': areDocumentsValid,
      'message': message,
      'invalidDocuments': invalidDocuments,
    };
  }
}

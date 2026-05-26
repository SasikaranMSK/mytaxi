import '../../domain/entities/job_entity.dart';

class JobModel extends JobEntity {
  const JobModel({
    required super.id,
    required super.jobNo,
    required super.pickupAddress,
    required super.dropoffAddress,
    super.pickupDateTime,
    super.pickupLatitude,
    super.pickupLongitude,
    super.dropLatitude,
    super.dropLongitude,
    required super.status,
    super.customerName,
    super.customerPhone,
    super.specialInstructions,
    super.estimatedFare,
    super.estimatedDistance,
    super.passengerCount,
    super.isPriorityJob,
    super.acceptedAt,
    super.startedAt,
    super.completedAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['id'] ?? json['jobId'] ?? 0,
      jobNo: json['jobNo'] ?? json['jobNumber'] ?? 0,
      pickupAddress: json['pickupAddress'] ?? json['fromAddress'] ?? '',
      dropoffAddress: json['dropoffAddress'] ?? json['toAddress'] ?? '',
      pickupDateTime: json['pickupDateTime'] != null
          ? DateTime.tryParse(json['pickupDateTime'].toString())
          : json['bookingDateTime'] != null
          ? DateTime.tryParse(json['bookingDateTime'].toString())
          : null,
      pickupLatitude:
          json['pickupLatitude']?.toString() ??
          json['fromLatitude']?.toString(),
      pickupLongitude:
          json['pickupLongitude']?.toString() ??
          json['fromLongitude']?.toString(),
      dropLatitude:
          json['dropLatitude']?.toString() ?? json['toLatitude']?.toString(),
      dropLongitude:
          json['dropLongitude']?.toString() ?? json['toLongitude']?.toString(),
      status:
          json['status']?.toString() ??
          json['jobStatus']?.toString() ??
          'pending',
      customerName:
          json['customerName'] ?? json['passengerName'] ?? json['passenger'],
      customerPhone:
          json['customerPhone'] ??
          json['passengerPhone'] ??
          json['phoneNumber'],
      specialInstructions:
          json['specialInstructions'] ?? json['notes'] ?? json['remarks'],
      estimatedFare: json['estimatedFare'] != null
          ? (json['estimatedFare'] as num).toDouble()
          : json['fare'] != null
          ? (json['fare'] as num).toDouble()
          : null,
      estimatedDistance: json['estimatedDistance'] != null
          ? (json['estimatedDistance'] as num).toDouble()
          : json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
      passengerCount:
          json['passengerCount']?.toString() ?? json['passengers']?.toString(),
      isPriorityJob:
          json['isPriority'] ??
          json['isPriorityJob'] ??
          json['priority'] ??
          false,
      acceptedAt: json['acceptedAt'] != null
          ? DateTime.tryParse(json['acceptedAt'].toString())
          : null,
      startedAt: json['startedAt'] != null
          ? DateTime.tryParse(json['startedAt'].toString())
          : json['startTime'] != null
          ? DateTime.tryParse(json['startTime'].toString())
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString())
          : json['endTime'] != null
          ? DateTime.tryParse(json['endTime'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jobNo': jobNo,
      'pickupAddress': pickupAddress,
      'dropoffAddress': dropoffAddress,
      'pickupDateTime': pickupDateTime?.toIso8601String(),
      'pickupLatitude': pickupLatitude,
      'pickupLongitude': pickupLongitude,
      'dropLatitude': dropLatitude,
      'dropLongitude': dropLongitude,
      'status': status,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'specialInstructions': specialInstructions,
      'estimatedFare': estimatedFare,
      'estimatedDistance': estimatedDistance,
      'passengerCount': passengerCount,
      'isPriorityJob': isPriorityJob,
      'acceptedAt': acceptedAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}

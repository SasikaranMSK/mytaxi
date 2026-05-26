class JobEntity {
  final int id;
  final int jobNo;
  final String pickupAddress;
  final String dropoffAddress;
  final DateTime? pickupDateTime;
  final String? pickupLatitude;
  final String? pickupLongitude;
  final String? dropLatitude;
  final String? dropLongitude;
  final String status;
  final String? customerName;
  final String? customerPhone;
  final String? specialInstructions;
  final double? estimatedFare;
  final double? estimatedDistance;
  final String? passengerCount;
  final bool isPriorityJob;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  const JobEntity({
    required this.id,
    required this.jobNo,
    required this.pickupAddress,
    required this.dropoffAddress,
    this.pickupDateTime,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropLatitude,
    this.dropLongitude,
    required this.status,
    this.customerName,
    this.customerPhone,
    this.specialInstructions,
    this.estimatedFare,
    this.estimatedDistance,
    this.passengerCount,
    this.isPriorityJob = false,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
  });

  JobEntity copyWith({
    int? id,
    int? jobNo,
    String? pickupAddress,
    String? dropoffAddress,
    DateTime? pickupDateTime,
    String? pickupLatitude,
    String? pickupLongitude,
    String? dropLatitude,
    String? dropLongitude,
    String? status,
    String? customerName,
    String? customerPhone,
    String? specialInstructions,
    double? estimatedFare,
    double? estimatedDistance,
    String? passengerCount,
    bool? isPriorityJob,
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return JobEntity(
      id: id ?? this.id,
      jobNo: jobNo ?? this.jobNo,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      pickupDateTime: pickupDateTime ?? this.pickupDateTime,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      dropLatitude: dropLatitude ?? this.dropLatitude,
      dropLongitude: dropLongitude ?? this.dropLongitude,
      status: status ?? this.status,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,
      passengerCount: passengerCount ?? this.passengerCount,
      isPriorityJob: isPriorityJob ?? this.isPriorityJob,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

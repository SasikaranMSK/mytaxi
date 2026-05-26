import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/color_constants.dart';
import '../../domain/entities/job_entity.dart';

class JobCard extends StatelessWidget {
  final JobEntity job;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onViewDetails;
  final VoidCallback? onStartTrip;

  const JobCard({
    super.key,
    required this.job,
    required this.onAccept,
    required this.onReject,
    required this.onViewDetails,
    this.onStartTrip,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return kOrangeColor;
      case 'assigned':
        return kAccentColor;
      case 'accepted':
        return kGreenColor;
      case 'in_progress':
      case 'started':
        return kAccentColor;
      case 'completed':
        return kSecondaryText;
      case 'cancelled':
        return kRedColor;
      default:
        return kSecondaryText;
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Not set';
    return DateFormat('MMM dd, hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(job.status);
    final bool canAccept =
        job.status.toLowerCase() == 'pending' ||
        job.status.toLowerCase() == 'assigned';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      color: kCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: job.isPriorityJob
              ? kOrangeColor
              : kAccentColor.withOpacity(0.2),
          width: job.isPriorityJob ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onViewDetails,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Job No and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Job #${job.jobNo}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryText,
                        ),
                      ),
                      if (job.isPriorityJob) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: kOrangeColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'PRIORITY',
                            style: TextStyle(
                              color: kBgColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      job.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Pickup Time
              if (job.pickupDateTime != null) ...[
                Row(
                  children: [
                    Icon(Icons.access_time, size: 16, color: kSecondaryText),
                    const SizedBox(width: 8),
                    Text(
                      _formatDateTime(job.pickupDateTime),
                      style: const TextStyle(fontSize: 14, color: kPrimaryText),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Pickup Location
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.trip_origin, size: 16, color: kGreenColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pickup',
                          style: TextStyle(
                            fontSize: 12,
                            color: kSecondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          job.pickupAddress,
                          style: const TextStyle(
                            fontSize: 14,
                            color: kPrimaryText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Dropoff Location
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.location_on, size: 16, color: kRedColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dropoff',
                          style: TextStyle(
                            fontSize: 12,
                            color: kSecondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          job.dropoffAddress,
                          style: const TextStyle(
                            fontSize: 14,
                            color: kPrimaryText,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Customer Info
              if (job.customerName != null || job.customerPhone != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: kSecondaryText),
                    const SizedBox(width: 8),
                    Text(
                      job.customerName ?? 'Unknown',
                      style: const TextStyle(fontSize: 14, color: kPrimaryText),
                    ),
                    if (job.customerPhone != null) ...[
                      const SizedBox(width: 16),
                      Icon(Icons.phone, size: 16, color: kAccentColor),
                      const SizedBox(width: 4),
                      Text(
                        job.customerPhone!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: kAccentColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              // Estimated Fare and Distance
              if (job.estimatedFare != null ||
                  job.estimatedDistance != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (job.estimatedFare != null) ...[
                      const Icon(
                        Icons.attach_money,
                        size: 16,
                        color: kGreenColor,
                      ),
                      Text(
                        '\$${job.estimatedFare!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: kGreenColor,
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (job.estimatedDistance != null) ...[
                      Icon(Icons.route, size: 16, color: kSecondaryText),
                      const SizedBox(width: 4),
                      Text(
                        '${job.estimatedDistance!.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          fontSize: 14,
                          color: kPrimaryText,
                        ),
                      ),
                    ],
                  ],
                ),
              ],

              // Special Instructions
              if (job.specialInstructions != null &&
                  job.specialInstructions!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kOrangeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kOrangeColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 16,
                        color: kOrangeColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          job.specialInstructions!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: kPrimaryText,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Action Buttons for pending/assigned jobs
              if (canAccept) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onAccept,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('ACCEPT'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kGreenColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onReject,
                        icon: const Icon(Icons.cancel),
                        label: const Text('REJECT'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: kRedColor,
                          side: const BorderSide(color: kRedColor, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Start Trip button for accepted jobs
              if (onStartTrip != null &&
                  job.status.toLowerCase() == 'accepted') ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onStartTrip,
                    icon: const Icon(Icons.local_taxi, size: 24),
                    label: const Text(
                      'START TRIP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccentColor,
                      foregroundColor: kBgColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

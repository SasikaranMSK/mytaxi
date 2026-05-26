import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../di/injection_container.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../../core/widgets/popup_message_view.dart';
import '../../../../core/storage/token_storage.dart';
import '../../../../core/storage/vehicle_storage.dart';
import '../../../../features/vehicle/data/datasources/vehicle_local_data_source.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/job_card.dart';
import '../widgets/driver_status_indicator.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    // Load dashboard data on init
    context.read<DashboardBloc>().add(LoadDashboard());
  }

  void _handleAcceptJob(int jobId) async {
    final vehicleLocalDataSource = sl<VehicleLocalDataSource>();
    final vehicle = await vehicleLocalDataSource.getVehicle();

    if (vehicle == null) {
      if (!mounted) return;
      showErrorPopup(context, message: 'Vehicle information not found');
      return;
    }

    // TODO: Get MAC address from device
    const macAddress = 'DEVICE_MAC_ADDRESS';

    if (!mounted) return;
    context.read<DashboardBloc>().add(
      AcceptJob(jobId: jobId, macAddress: macAddress, vehicleId: vehicle.id),
    );
  }

  void _handleRejectJob(int jobId) {
    context.read<DashboardBloc>().add(RejectJob(jobId));
  }

  void _handleStartWork() {
    context.read<DashboardBloc>().add(StartWork());
  }

  void _handleViewDetails(int jobId) {
    // TODO: Navigate to job details page or show dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Job Details'),
        content: Text('Viewing details for Job #$jobId'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  void _handleStartTrip(int jobId) {
    Navigator.pushNamed(
      context,
      RouteConstants.meter,
      arguments: {'jobId': jobId},
    );
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        title: Row(
          children: [
            Icon(Icons.logout, color: kOrangeColor, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Logout',
              style: TextStyle(
                color: kPrimaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to logout? You will need to login again to access the dashboard.',
          style: TextStyle(color: kSecondaryText, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(foregroundColor: kSecondaryText),
            child: const Text(
              'CANCEL',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: kRedColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'LOGOUT',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Clear all stored data
      await sl<TokenStorage>().clearAll();
      await sl<VehicleStorage>().clearVehicle();

      if (!mounted) return;

      // Navigate to login and clear navigation stack
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(RouteConstants.login, (route) => false);
    }
  }

  Future<bool> _handleBackPressed() async {
    final shouldChangeVehicle = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: kCardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        title: Row(
          children: [
            Icon(Icons.directions_car, color: kAccentColor, size: 28),
            const SizedBox(width: 12),
            const Text(
              'Change Vehicle',
              style: TextStyle(
                color: kPrimaryText,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: const Text(
          'Do you want to re-enter vehicle number?',
          style: TextStyle(color: kSecondaryText, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: TextButton.styleFrom(foregroundColor: kSecondaryText),
            child: const Text(
              'CANCEL',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: kAccentColor,
              foregroundColor: kBgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'YES',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (shouldChangeVehicle == true) {
      if (!mounted) return false;

      // Navigate to vehicle entry screen
      Navigator.of(context).pushReplacementNamed(RouteConstants.vehicle);
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await _handleBackPressed();
        }
      },
      child: Scaffold(
        backgroundColor: kBgColor,
        appBar: AppBar(
          title: const Text(
            'Driver Dashboard',
            style: TextStyle(color: kPrimaryText, fontWeight: FontWeight.bold),
          ),
          backgroundColor: kCardColor,
          elevation: 0,
          iconTheme: const IconThemeData(color: kPrimaryText),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: kAccentColor),
              tooltip: 'Refresh Jobs',
              onPressed: () {
                context.read<DashboardBloc>().add(RefreshJobs());
              },
            ),
            PopupMenuButton<String>(
              icon: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: kAccentColor.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.person, color: kAccentColor, size: 20),
                ),
              ),
              color: kCardColor,
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.account_circle, color: kAccentColor, size: 20),
                      const SizedBox(width: 12),
                      const Text(
                        'View Profile',
                        style: TextStyle(color: kPrimaryText),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(Icons.logout, color: kRedColor, size: 20),
                      const SizedBox(width: 12),
                      const Text('Logout', style: TextStyle(color: kRedColor)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) async {
                switch (value) {
                  case 'profile':
                    Navigator.pushNamed(context, RouteConstants.profile);
                    break;
                  case 'logout':
                    await _handleLogout();
                    break;
                }
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: BlocConsumer<DashboardBloc, DashboardState>(
          listener: (context, state) {
            if (state is DashboardError) {
              showErrorPopup(context, message: state.message);
            } else if (state is WorkStartError) {
              showErrorPopup(context, message: state.message);
            } else if (state is WorkStarted) {
              showSuccessPopup(context, message: 'Successfully started work');
            }
          },
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: kAccentColor,
                  strokeWidth: 3,
                ),
              );
            }

            if (state is DashboardLoaded) {
              final filteredJobs = _selectedFilter == 'all'
                  ? state.jobs
                  : state.jobs
                        .where(
                          (job) =>
                              job.status.toLowerCase() ==
                              _selectedFilter.toLowerCase(),
                        )
                        .toList();

              return Column(
                children: [
                  // Driver Status Indicator
                  DriverStatusIndicator(
                    status: state.driverStatus,
                    onStartWork: state.driverStatus.isOnDuty
                        ? null
                        : _handleStartWork,
                  ),

                  // Filter Chips
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip('All', 'all'),
                        _buildFilterChip('Pending', 'pending'),
                        _buildFilterChip('Assigned', 'assigned'),
                        _buildFilterChip('Accepted', 'accepted'),
                        _buildFilterChip('In Progress', 'in_progress'),
                      ],
                    ),
                  ),

                  // Jobs Count
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: kCardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: kAccentColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.work_outline,
                              color: kAccentColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${filteredJobs.length} Job${filteredJobs.length != 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: kPrimaryText,
                              ),
                            ),
                          ],
                        ),
                        if (state.jobs.any((job) => job.isPriorityJob))
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: kOrangeColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: kOrangeColor),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.priority_high,
                                  color: kOrangeColor,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                const Text(
                                  'Priority',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: kOrangeColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Jobs List
                  Expanded(
                    child: filteredJobs.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: kCardColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.inbox_outlined,
                                    size: 64,
                                    color: kSecondaryText,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                const Text(
                                  'No jobs available',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: kPrimaryText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Pull down to refresh',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: kSecondaryText,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              context.read<DashboardBloc>().add(RefreshJobs());
                              await Future.delayed(const Duration(seconds: 1));
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 16),
                              itemCount: filteredJobs.length,
                              itemBuilder: (context, index) {
                                final job = filteredJobs[index];
                                return JobCard(
                                  job: job,
                                  onAccept: () => _handleAcceptJob(job.id),
                                  onReject: () => _handleRejectJob(job.id),
                                  onViewDetails: () =>
                                      _handleViewDetails(job.id),
                                  onStartTrip:
                                      job.status.toLowerCase() == 'accepted'
                                      ? () => _handleStartTrip(job.id)
                                      : null,
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            }

            // Initial state or error
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: kCardColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.dashboard,
                      size: 64,
                      color: kAccentColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome to Driver Dashboard',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: kPrimaryText,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DashboardBloc>().add(LoadDashboard());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccentColor,
                      foregroundColor: kBgColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'LOAD JOBS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
          if (value != 'all') {
            context.read<DashboardBloc>().add(FilterJobsByStatus(value));
          } else {
            context.read<DashboardBloc>().add(RefreshJobs());
          }
        },
        selectedColor: kAccentColor,
        backgroundColor: kCardColor,
        side: BorderSide(
          color: isSelected ? kAccentColor : kSecondaryText.withOpacity(0.3),
          width: 1.5,
        ),
        labelStyle: TextStyle(
          color: isSelected ? kBgColor : kPrimaryText,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
        elevation: isSelected ? 4 : 0,
        pressElevation: 2,
      ),
    );
  }
}

void showSuccessPopup(BuildContext context, {required String message}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Text('Success'),
        ],
      ),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

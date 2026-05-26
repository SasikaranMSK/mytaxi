import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/usecases/get_driver_jobs_usecase.dart';
import '../../domain/usecases/accept_job_usecase.dart';
import '../../domain/usecases/start_work_usecase.dart';
import '../../domain/usecases/get_driver_status_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDriverJobsUseCase getDriverJobs;
  final AcceptJobUseCase acceptJob;
  final StartWorkUseCase startWork;
  final GetDriverStatusUseCase getDriverStatus;

  DashboardBloc({
    required this.getDriverJobs,
    required this.acceptJob,
    required this.startWork,
    required this.getDriverStatus,
  }) : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<RefreshJobs>(_onRefreshJobs);
    on<AcceptJob>(_onAcceptJob);
    on<RejectJob>(_onRejectJob);
    on<StartWork>(_onStartWork);
    on<FilterJobsByStatus>(_onFilterJobsByStatus);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final jobs = await getDriverJobs();
      final status = await getDriverStatus();

      // Add dummy jobs for testing
      final jobsWithDummy = [
        ...jobs,
        _createDummyJob(),
        _createAcceptedDummyJob(),
      ];

      emit(DashboardLoaded(jobs: jobsWithDummy, driverStatus: status));
    } catch (e) {
      emit(DashboardError('Failed to load dashboard: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshJobs(
    RefreshJobs event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final jobs = await getDriverJobs();
      final status = await getDriverStatus();

      // Add dummy job for testing
      final jobsWithDummy = [...jobs, _createDummyJob()];

      emit(DashboardLoaded(jobs: jobsWithDummy, driverStatus: status));
    } catch (e) {
      emit(DashboardError('Failed to refresh jobs: ${e.toString()}'));
    }
  }

  Future<void> _onAcceptJob(
    AcceptJob event,
    Emitter<DashboardState> emit,
  ) async {
    try {
      final success = await acceptJob(
        jobId: event.jobId,
        macAddress: event.macAddress,
        vehicleId: event.vehicleId,
      );

      if (success) {
        // Refresh jobs after accepting
        final jobs = await getDriverJobs();
        final status = await getDriverStatus();

        // Find the accepted job
        final acceptedJob = jobs.firstWhere(
          (job) => job.id == event.jobId,
          orElse: () => jobs.first,
        );

        emit(
          DashboardLoaded(
            jobs: jobs,
            driverStatus: status,
            selectedJob: acceptedJob,
          ),
        );
      } else {
        emit(DashboardError('Failed to accept job'));
      }
    } catch (e) {
      emit(DashboardError('Error accepting job: ${e.toString()}'));
    }
  }

  Future<void> _onRejectJob(
    RejectJob event,
    Emitter<DashboardState> emit,
  ) async {
    // For now, just refresh the jobs list
    // In a real app, you'd call a reject API endpoint
    try {
      final jobs = await getDriverJobs();
      final status = await getDriverStatus();
      emit(DashboardLoaded(jobs: jobs, driverStatus: status));
    } catch (e) {
      emit(DashboardError('Failed to reject job: ${e.toString()}'));
    }
  }

  Future<void> _onStartWork(
    StartWork event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      final result = await startWork();

      if (result.success && result.driverStatus != null) {
        final jobs = await getDriverJobs();
        emit(DashboardLoaded(jobs: jobs, driverStatus: result.driverStatus!));
      } else {
        emit(WorkStartError(result.message));
      }
    } catch (e) {
      emit(WorkStartError('Failed to start work: ${e.toString()}'));
    }
  }

  Future<void> _onFilterJobsByStatus(
    FilterJobsByStatus event,
    Emitter<DashboardState> emit,
  ) async {
    // This would typically filter the existing jobs or make a new API call
    // For now, just reload all jobs
    add(RefreshJobs());
  }

  // Create dummy jobs for testing
  JobEntity _createDummyJob() {
    return JobEntity(
      id: 99999,
      jobNo: 12345,
      pickupAddress: '123 Main Street, Sydney CBD, NSW 2000',
      dropoffAddress: '456 George Street, Sydney Airport, NSW 2020',
      pickupDateTime: DateTime.now().add(const Duration(minutes: 15)),
      pickupLatitude: '-33.8688',
      pickupLongitude: '151.2093',
      dropLatitude: '-33.9399',
      dropLongitude: '151.1753',
      status: 'pending',
      customerName: 'John Smith',
      customerPhone: '+61 400 123 456',
      specialInstructions:
          'Please call on arrival. Carry luggage assistance needed.',
      estimatedFare: 45.50,
      estimatedDistance: 12.5,
      passengerCount: '2',
      isPriorityJob: true,
    );
  }

  JobEntity _createAcceptedDummyJob() {
    return JobEntity(
      id: 88888,
      jobNo: 12346,
      pickupAddress: '789 Elizabeth Street, Melbourne CBD, VIC 3000',
      dropoffAddress: '321 Collins Street, South Melbourne, VIC 3205',
      pickupDateTime: DateTime.now().subtract(const Duration(minutes: 5)),
      pickupLatitude: '-37.8136',
      pickupLongitude: '144.9631',
      dropLatitude: '-37.8306',
      dropLongitude: '144.9633',
      status: 'accepted',
      customerName: 'Sarah Johnson',
      customerPhone: '+61 411 987 654',
      specialInstructions: 'Customer waiting at main entrance. 2 bags.',
      estimatedFare: 28.50,
      estimatedDistance: 8.2,
      passengerCount: '1',
      isPriorityJob: false,
      acceptedAt: DateTime.now().subtract(const Duration(minutes: 3)),
    );
  }
}

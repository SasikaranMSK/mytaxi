import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meter_taxi/core/constants/route_constants.dart';
import 'package:meter_taxi/core/widgets/bottom_nav_tabs.dart';
import 'package:meter_taxi/features/meter_screen/presentation/pages/payment_summary_page.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../core/constants/color_constants.dart';
import '../../../../di/injection_container.dart';
import '../../../tariff/data/constants/default_tariffs.dart';
import '../../../tariff/domain/entities/tariff_entity.dart';
import '../../../tariff/domain/usecases/fetch_and_save_tariffs_by_vehicle_type_id_v2_usecase.dart';
import '../../../tariff/domain/usecases/get_vehicle_type_tariffs_by_vehicle_type_id_usecase.dart';
import '../../../tariff/domain/usecases/select_active_tariff_usecase.dart';
import '../../../vehicle/data/datasources/vehicle_local_data_source.dart';
import '../../../vehicle/data/mappers/vehicle_mapper.dart';
import '../../domain/usecases/calculate_fare.dart';
import '../../domain/usecases/start_meter.dart';
import '../../domain/usecases/stop_meter.dart';
import '../bloc/meter_bloc.dart';
import '../bloc/meter_event.dart';
import '../bloc/meter_state.dart';
import '../widgets/meter_bottom_controls.dart';
import '../widgets/meter_fare_display.dart';
import '../widgets/meter_stats_grid.dart';
import '../widgets/meter_status_banner.dart';
import '../widgets/vehicle_tariff_info.dart';

class TaxiMeterScreen extends StatefulWidget {
  const TaxiMeterScreen({super.key});

  // Keep MeterBloc alive across route navigations.
  static MeterBloc? _sharedMeterBloc;
  static bool _isInitializing = false;

  @override
  State<TaxiMeterScreen> createState() => _TaxiMeterScreenState();
}

class _TaxiMeterScreenState extends State<TaxiMeterScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  MeterBloc? get _meterBloc => TaxiMeterScreen._sharedMeterBloc;
  set _meterBloc(MeterBloc? bloc) => TaxiMeterScreen._sharedMeterBloc = bloc;

  bool _ready = false;
  bool _navigatedToSummary = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable();
    _init();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_meterBloc == null && !_ready) {
      _init();
      return;
    }

    if (_meterBloc != null && !_ready && mounted) {
      setState(() => _ready = true);
    }
  }

  @override
  void activate() {
    super.activate();
    if (_meterBloc == null) {
      setState(() => _ready = false);
      _init();
      return;
    }

    if (mounted && !_ready) {
      setState(() => _ready = true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    try {
      WakelockPlus.disable();
    } catch (_) {}
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _meterBloc?.add(RestoreStateEvent());
    }
  }

  Future<void> _init() async {
    if (_meterBloc != null) {
      if (mounted) setState(() => _ready = true);
      return;
    }

    if (TaxiMeterScreen._isInitializing) {
      int waitCount = 0;
      while (TaxiMeterScreen._isInitializing && mounted && waitCount < 50) {
        await Future.delayed(const Duration(milliseconds: 100));
        waitCount++;
      }
      if (_meterBloc != null && mounted) {
        setState(() => _ready = true);
      }
      return;
    }

    TaxiMeterScreen._isInitializing = true;

    try {
      final vehicle = await sl<VehicleLocalDataSource>().getVehicle();
      if (vehicle == null) return;

      final tariffs = await _resolveTariffs(vehicle.vehicleTypeId);
      final selectedTariff = tariffs.isNotEmpty
          ? SelectActiveTariffUseCase()(tariffs)
          : _buildFallbackTariff();

      _meterBloc = MeterBloc(
        startMeter: sl<StartMeter>(),
        stopMeter: sl<StopMeter>(),
        calculateFare: sl<CalculateFare>(),
        repository: sl(),
        vehicle: vehicle.toEntity(),
        tariff: selectedTariff,
      );

      if (mounted) setState(() => _ready = true);
    } catch (e) {
      debugPrint('Error initializing meter: $e');
    } finally {
      TaxiMeterScreen._isInitializing = false;
    }
  }

  Future<List<TariffEntity>> _resolveTariffs(int vehicleTypeId) async {
    final localUseCase = sl<GetVehicleTypeTariffsByVehicleTypeIdUseCase>();

    var vehicleTypeTariffs = await localUseCase.call(vehicleTypeId);
    var tariffs = vehicleTypeTariffs
        .where((vtt) => vtt.active && vtt.tariff != null)
        .map((vtt) => vtt.tariff!)
        .toList();

    if (tariffs.isNotEmpty) return tariffs;

    try {
      final fetched = await sl<FetchAndSaveTariffsByVehicleTypeIdV2UseCase>()
          .call(vehicleTypeId);
      if (fetched.isNotEmpty) {
        vehicleTypeTariffs = await localUseCase.call(vehicleTypeId);
        tariffs = vehicleTypeTariffs
            .where((vtt) => vtt.active && vtt.tariff != null)
            .map((vtt) => vtt.tariff!)
            .toList();
      }
    } catch (_) {}

    if (tariffs.isNotEmpty) return tariffs;

    // Final fallback to bundled defaults converted to cents.
    return DefaultTariffs.list
        .where((t) => t.active)
        .map(
          (t) => TariffEntity(
            tarifId: t.tarifId,
            tarifName: t.tarifName,
            active: t.active,
            flagFall: (t.flagFall * 100).roundToDouble(),
            distanceRate: (t.distanceRate * 100).roundToDouble(),
            distanceRateRange: t.distanceRateRange,
            distanceRate2: (t.distanceRate2 * 100).roundToDouble(),
            timeRate: (t.waitingTimeRate * 100).roundToDouble(),
            waitingTimeRate: (t.waitingTimeRate * 100).roundToDouble(),
            startTime: t.startTime,
            endTime: t.endTime,
            fromDay: t.fromDay,
            toDay: t.toDay,
            publicHolidays: t.publicHolidays,
          ),
        )
        .toList();
  }

  TariffEntity _buildFallbackTariff() {
    return const TariffEntity(
      tarifId: -1,
      tarifName: 'Fallback Tariff',
      active: true,
      flagFall: 360,
      distanceRate: 252,
      distanceRateRange: 12.0,
      distanceRate2: 229,
      timeRate: 109,
      waitingTimeRate: 109,
      startTime: '00:00',
      endTime: '23:59',
      fromDay: 1,
      toDay: 7,
      publicHolidays: false,
    );
  }

  void _onStartTrip() {
    _meterBloc?.add(StartMeterEvent());
  }

  void _onStopTrip() {
    _meterBloc?.add(StopMeterEvent());
  }

  void _onCollectPayment() {
    debugPrint('[TaxiMeterScreen] Collect payment confirmed, resetting meter.');
    // Keep existing bloc alive; just reset to initial state for a fresh trip.
    // Closing immediately after add() can race and skip reset processing.
    _meterBloc?.add(ResetMeterEvent());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_ready || _meterBloc == null) {
      return const Scaffold(
        backgroundColor: kBgColor,
        body: Center(child: CircularProgressIndicator(color: kAccentColor)),
      );
    }

    return BlocProvider.value(
      value: _meterBloc!,
      child: Scaffold(
        backgroundColor: kBgColor,
        bottomNavigationBar: const BottomNavTabs(activeTab: BottomNavTab.fare),
        body: SafeArea(
          child: BlocListener<MeterBloc, MeterState>(
            listener: (context, state) {
              // Reset navigation guard once meter is fully reset to initial state.
              if (_navigatedToSummary &&
                  !state.isRunning &&
                  state.startTime == null &&
                  state.endTime == null) {
                _navigatedToSummary = false;
              }

              debugPrint(
                '[TaxiMeterScreen] Listener triggered: isRunning=${state.isRunning}, endTime=${state.endTime}, navigated=$_navigatedToSummary',
              );
              if (!_navigatedToSummary &&
                  !state.isRunning &&
                  state.startTime != null &&
                  state.endTime != null) {
                _navigatedToSummary = true;
                final args = PaymentSummaryArgs(
                  distanceKm: state.distance,
                  waitingSeconds: state.waitingTime,
                  totalFare: state.totalFare,
                  startTime: state.startTime!,
                  endTime: state.endTime!,
                  tariff: _meterBloc!.tariff,
                );
                debugPrint(
                  '[TaxiMeterScreen] Payment summary args prepared: fare=${args.totalFare}',
                );
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    debugPrint(
                      '[TaxiMeterScreen] Navigating to payment summary page...',
                    );
                    Navigator.pushNamed(
                          context,
                          RouteConstants.summary,
                          arguments: args,
                        )
                        .then((result) {
                          debugPrint(
                            '[TaxiMeterScreen] Returned from payment summary: $result',
                          );
                          if (result == true && mounted) {
                            _onCollectPayment();
                          } else if (result != true) {
                            // User clicked back without completing payment
                            _navigatedToSummary = false;
                          }
                        })
                        .catchError((e) {
                          debugPrint('[TaxiMeterScreen] Navigation error: $e');
                          _navigatedToSummary = false;
                        });
                  }
                });
              }
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final h = constraints.maxHeight;
                final isSmallScreen = h < 600;
                final padding = isSmallScreen ? 12.0 : 20.0;

                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: BlocBuilder<MeterBloc, MeterState>(
                        builder: (context, state) {
                          return Column(
                            children: [
                              MeterStatusBanner(state: state),
                              SizedBox(height: isSmallScreen ? 12 : 16),
                              VehicleTariffInfo(
                                vehicle: _meterBloc!.vehicle,
                                tariff: _meterBloc!.tariff,
                                isSmall: isSmallScreen,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: padding,
                                    vertical: padding / 2,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      MeterFareDisplay(
                                        totalFare: state.totalFare,
                                        isSmall: isSmallScreen,
                                      ),
                                      SizedBox(height: isSmallScreen ? 12 : 24),
                                      MeterStatsGrid(
                                        state: state,
                                        isSmall: isSmallScreen,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              MeterBottomControls(
                                state: state,
                                padding: padding,
                                onStartTrip: _onStartTrip,
                                onStopTrip: _onStopTrip,
                                onTogglePause: () =>
                                    _meterBloc?.add(TogglePauseEvent()),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

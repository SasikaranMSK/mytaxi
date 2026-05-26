import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../../core/widgets/bottom_nav_tabs.dart';
import '../bloc/map_bloc.dart';
import '../bloc/map_event.dart';
import '../bloc/map_state.dart';
import '../viewmodel/map_view_model.dart';
import '../widgets/map_view.dart';
import '../widgets/map_recenter_button.dart';
import '../widgets/map_error_banner.dart';
import '../widgets/map_loading_overlay.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  MapBloc? _mapBloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _mapBloc = context.read<MapBloc>();
        _mapBloc?.add(MapStarted());
      }
    });
  }

  @override
  void dispose() {
    _mapBloc?.add(MapStopped());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavTabs(activeTab: BottomNavTab.map),
      body: BlocBuilder<MapBloc, MapState>(
        builder: (context, state) {
          final vm = MapViewModel.fromState(state);
          final center = vm.center;

          // Smooth recenter when new location arrives
          WidgetsBinding.instance.addPostFrameCallback((_) {
            try {
              _mapController.move(center, 16);
            } catch (_) {
              // ignore
            }
          });

          return Stack(
            children: [
              MapView(mapController: _mapController, vm: vm),

              Positioned(
                right: 16,
                bottom: 16,
                child: MapRecenterButton(
                  onPressed: () => _mapController.move(center, 16),
                ),
              ),

              if (vm.showInitialLoading) const MapLoadingOverlay(),

              if (vm.hasError)
                Positioned(
                  left: 16,
                  right: 16,
                  top: 16,
                  child: MapErrorBanner(message: vm.errorMessage!),
                ),
            ],
          );
        },
      ),
    );
  }
}

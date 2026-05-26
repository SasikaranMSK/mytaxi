import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../viewmodel/map_view_model.dart';

class MapView extends StatelessWidget {
  final MapController mapController;
  final MapViewModel vm;

  const MapView({
    super.key,
    required this.mapController,
    required this.vm,
  });

  @override
  Widget build(BuildContext context) {
    final LatLng center = vm.center;

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: 16,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: "com.example.meter_taxi2",
        ),
        MarkerLayer(
          markers: [
            Marker(
              point: center,
              width: 44,
              height: 44,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.my_location,
                    color: Colors.blue,
                    size: 22,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

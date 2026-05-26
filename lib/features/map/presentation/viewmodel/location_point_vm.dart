class LocationPointVm {
  final double lat;
  final double lng;
  final DateTime? timestamp;

  const LocationPointVm({
    required this.lat,
    required this.lng,
    this.timestamp,
  });

  String get latText => lat.toStringAsFixed(6);
  String get lngText => lng.toStringAsFixed(6);

  String get coordsText => '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';

  String get timeText {
    final t = timestamp;
    if (t == null) return '';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.hour)}:${two(t.minute)}:${two(t.second)}';
  }
}

import 'package:flutter/material.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../tariff/domain/entities/tariff_entity.dart';
import '../../../vehicle/domain/entities/vehicle_entity.dart';

class VehicleTariffInfo extends StatelessWidget {
  final VehicleEntity vehicle;
  final TariffEntity tariff;
  final bool isSmall;

  const VehicleTariffInfo({
    super.key,
    required this.vehicle,
    required this.tariff,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = isSmall ? 11.0 : 13.0;
    final iconSize = isSmall ? 14.0 : 16.0;
    final padding = isSmall ? 8.0 : 12.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmall ? 16.0 : 20.0),
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: padding * 0.8,
      ),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kAccentColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Vehicle Number
          Icon(Icons.local_taxi, color: kAccentColor, size: iconSize),
          SizedBox(width: isSmall ? 6 : 8),
          Text(
            vehicle.vehicleNo,
            style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),

          // Divider
          Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmall ? 12.0 : 16.0),
            child: Container(
              height: isSmall ? 16 : 20,
              width: 1,
              color: kAccentColor.withValues(alpha: 0.3),
            ),
          ),

          // Tariff Name
          Icon(Icons.description_outlined, color: kAccentColor, size: iconSize),
          SizedBox(width: isSmall ? 6 : 8),
          Flexible(
            child: Text(
              tariff.tarifName,
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

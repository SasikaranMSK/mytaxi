import '../../domain/entities/tariff_entity.dart';

class DefaultTariffs {
  static const List<TariffEntity> list = [
    // --- SEDAN RATES ---

    // 01 Sedan Day Rate (06:00-21:59) Mon-Sun
    TariffEntity(
      tarifId: 101,
      tarifName: '01 Sedan Day Rate',
      active: true,
      flagFall: 3.60,
      distanceRate: 2.52,
      distanceRateRange: 12.0,
      distanceRate2: 2.29,
      waitingTimeRate: 1.09,
      timeRate: 0, // Not specified, assuming 0 or same as waiting
      startTime: '06:00',
      endTime: '21:59',
      fromDay: 1, // Monday
      toDay: 7,   // Sunday
      publicHolidays: false,
    ),

    // 02 Sedan Night Rate (22:00-05:59) Mon-Sun
    TariffEntity(
      tarifId: 102,
      tarifName: '02 Sedan Night Rate',
      active: true,
      flagFall: 3.60,
      distanceRate: 3.00,
      distanceRateRange: 12.0,
      distanceRate2: 2.73,
      waitingTimeRate: 1.09,
      timeRate: 0,
      startTime: '22:00',
      endTime: '05:59',
      fromDay: 1,
      toDay: 7,
      publicHolidays: false,
    ),

    // 03 Sedan Night Owl Rate (22:00 - 23:59) Fri, Sat, PH
    TariffEntity(
      tarifId: 103,
      tarifName: '03 Sedan Night Owl Rate (Late)',
      active: true,
      flagFall: 6.10,
      distanceRate: 3.00,
      distanceRateRange: 12.0,
      distanceRate2: 2.73,
      waitingTimeRate: 1.09,
      timeRate: 0,
      startTime: '22:00',
      endTime: '23:59',
      fromDay: 5, // Friday
      toDay: 6,   // Saturday
      publicHolidays: true,
    ),

    // 03 Sedan Night Owl Rate (00:00 - 05:59) Sat, Sun, PH
    TariffEntity(
      tarifId: 104,
      tarifName: '03 Sedan Night Owl Rate (Early)',
      active: true,
      flagFall: 6.10,
      distanceRate: 2.73,
      distanceRateRange: 12.0,
      distanceRate2: 2.73,
      waitingTimeRate: 1.09,
      timeRate: 0,
      startTime: '00:00',
      endTime: '05:59',
      fromDay: 6, // Saturday
      toDay: 7,   // Sunday
      publicHolidays: true,
    ),

    // --- MAXI RATES ---

    // 04 Maxi Day Rate (06:00-21:59) Mon-Sun
    TariffEntity(
      tarifId: 201,
      tarifName: '04 Maxi Day Rate',
      active: true,
      flagFall: 7.50,
      distanceRate: 3.78,
      distanceRateRange: 12.0,
      distanceRate2: 3.44,
      waitingTimeRate: 1.64,
      timeRate: 0,
      startTime: '06:00',
      endTime: '21:59',
      fromDay: 1,
      toDay: 7,
      publicHolidays: false,
    ),

    // 05 Maxi Night (10:00-05:59) Sun-Thu -> Assuming 22:00 start
    TariffEntity(
      tarifId: 202,
      tarifName: '05 Maxi Night',
      active: true,
      flagFall: 7.50,
      distanceRate: 4.50,
      distanceRateRange: 12.0,
      distanceRate2: 4.12,
      waitingTimeRate: 1.64,
      timeRate: 0,
      startTime: '22:00',
      endTime: '05:59',
      fromDay: 7, // Sunday
      toDay: 4,   // Thursday
      publicHolidays: false,
    ),

    // 06 Maxi Night OWL Rates (22:00-23:59) Fri, Sat, PH
    TariffEntity(
      tarifId: 203,
      tarifName: '06 Maxi Night OWL Rates (Late)',
      active: true,
      flagFall: 10.06,
      distanceRate: 4.50,
      distanceRateRange: 12.0,
      distanceRate2: 4.12,
      waitingTimeRate: 1.64,
      timeRate: 0,
      startTime: '22:00',
      endTime: '23:59',
      fromDay: 5, // Friday
      toDay: 6,   // Saturday
      publicHolidays: true,
    ),

    // 06 Maxi Night OWL Rates (00:00-05:59) Sat, Sun, PH
    TariffEntity(
      tarifId: 204,
      tarifName: '06 Maxi Night OWL Rates (Early)',
      active: true,
      flagFall: 10.06,
      distanceRate: 4.50,
      distanceRateRange: 12.0,
      distanceRate2: 4.12,
      waitingTimeRate: 1.64,
      timeRate: 0,
      startTime: '00:00',
      endTime: '05:59',
      fromDay: 6, // Saturday
      toDay: 7,   // Sunday
      publicHolidays: true,
    ),
  ];
}

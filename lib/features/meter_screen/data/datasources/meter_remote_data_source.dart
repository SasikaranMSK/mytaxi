import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/clients/api_client.dart';
import '../../../../core/config/navigation_service.dart';
import '../../../../core/utils/log_utils.dart';
import '../dto/meter_dto.dart';

abstract class MeterRemoteDataSource {
  Future<void> sendTrip(MeterDto trip, {BuildContext? context});
  Future<List<MeterDto>> fetchTrips({BuildContext? context});
}

class MeterRemoteDataSourceImpl implements MeterRemoteDataSource {
  final ApiClient client;

  MeterRemoteDataSourceImpl({required this.client});

  static const String _saveTripPath = '/taxis-api/api/Meter/SaveTrip';
  static const String _getTripsPath = '/taxis-api/api/Meter/GetTrips';

  @override
  Future<void> sendTrip(MeterDto trip, {BuildContext? context}) async {
    try {
      final effectiveContext = _resolveContext(context);
      final res = await client.postRequest(
        _saveTripPath,
        jsonEncode(trip.toJson()),
        effectiveContext,
      );

      if (res == null) {
        throw Exception('Failed to send trip');
      }

      if (res is Map<String, dynamic> && res.containsKey('success')) {
        if (res['success'] != true) {
          throw Exception(_extractErrorMessage(res, 'Failed to send trip'));
        }
      }

      LoggingUtil.logDebug('MeterRemoteDataSource: Trip sent successfully');
    } catch (e, st) {
      LoggingUtil.logError('MeterRemoteDataSource sendTrip error: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<List<MeterDto>> fetchTrips({BuildContext? context}) async {
    try {
      final effectiveContext = _resolveContext(context);
      final res = await client.getRequest(
        _getTripsPath,
        null,
        effectiveContext,
      );

      if (res == null) return [];
      final data = res;

      // handle either:
      // 1) List<Map>
      // 2) Map{ data: [...] }
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['data'] is List) {
        list = (data['data'] as List).toList();
      } else {
        return [];
      }

      final trips = <MeterDto>[];
      for (final item in list) {
        if (item is Map) {
          trips.add(MeterDto.fromJson(item.cast<String, dynamic>()));
        }
      }
      return trips;
    } catch (e, st) {
      LoggingUtil.logError('MeterRemoteDataSource fetchTrips error: $e\n$st');
      return [];
    }
  }

  BuildContext _resolveContext(BuildContext? context) {
    final resolved = context ?? rootContext;
    if (resolved != null) return resolved;
    throw Exception('No BuildContext available for API call');
  }

  String _extractErrorMessage(Map<String, dynamic> response, String fallback) {
    final errors = response['errors'];
    if (errors is List && errors.isNotEmpty) {
      return errors
          .map((e) {
            if (e is String) return e;
            if (e is Map && e['message'] != null) return e['message'].toString();
            return e.toString();
          })
          .join(', ');
    }

    final message = response['message'];
    if (message is String && message.isNotEmpty) {
      return message;
    }

    return fallback;
  }
}

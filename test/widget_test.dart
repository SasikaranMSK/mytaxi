import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:meter_taxi/main.dart';
import 'package:meter_taxi/di/injection_container.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await initializeDependencies();
  });

  testWidgets('App builds without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const TaxiMeterApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

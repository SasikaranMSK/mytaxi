import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../constants/route_constants.dart';
import '../../constants/color_constants.dart';
import '../../../di/injection_container.dart';

import '../../../features/authentication/presentation/bloc/auth_bloc.dart';
import '../../../features/authentication/presentation/bloc/auth_state.dart';
import '../../../features/authentication/presentation/pages/login_page.dart';

import '../../../features/vehicle/presentation/pages/vehicle_entry_screen.dart';
import '../../../features/vehicle/presentation/bloc/vehicle_bloc.dart';
import '../../../features/meter_screen/presentation/pages/taximeter_screen.dart';

// ✅ DASHBOARD IMPORTS
import '../../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../../features/dashboard/presentation/bloc/dashboard_bloc.dart';

// ✅ NEW IMPORTS
import '../../../features/map/presentation/pages/map_screen.dart';
import '../../../features/map/presentation/bloc/map_bloc.dart';
import '../../../features/meter_screen/presentation/widgets/profile_menu_button.dart';
import '../../../features/profile/presentation/pages/profile_screen.dart';
import '../../../features/meter_screen/presentation/pages/payment_summary_page.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteConstants.login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginPage(),
        );

      case RouteConstants.vehicle:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider<VehicleBloc>(
            create: (_) => sl<VehicleBloc>(),
            child: const _LogoutScaffold(child: VehicleEntryScreen()),
          ),
        );

      case RouteConstants.dashboard:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider<DashboardBloc>(
            create: (_) => sl<DashboardBloc>(),
            child: const DashboardPage(),
          ),
        );

      case RouteConstants.meter:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const _LogoutScaffold(
            backRoute: RouteConstants.dashboard,
            child: TaxiMeterScreen(),
          ),
        );

      // ✅ NEW MAP ROUTE
      case RouteConstants.map:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => BlocProvider<MapBloc>(
            create: (_) => sl<MapBloc>(),
            child: const _LogoutScaffold(child: MapScreen()),
          ),
        );

      // ✅ PROFILE ROUTE
      case RouteConstants.profile:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProfileScreen(),
        );

      // ✅ PAYMENT SUMMARY ROUTE
      case RouteConstants.summary:
        try {
          final args = settings.arguments as PaymentSummaryArgs?;
          if (args == null) {
            debugPrint(
              '[AppRouter] Payment summary args are null, returning to meter',
            );
            // If no args provided, go back to dashboard
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const _LogoutScaffold(
                backRoute: RouteConstants.dashboard,
                child: TaxiMeterScreen(),
              ),
            );
          }
          debugPrint(
            '[AppRouter] Found payment summary args: ${args.totalFare}',
          );
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => PaymentSummaryPage(args: args),
          );
        } catch (e) {
          debugPrint('[AppRouter] Error parsing payment summary args: $e');
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const _LogoutScaffold(
              backRoute: RouteConstants.dashboard,
              child: TaxiMeterScreen(),
            ),
          );
        }

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginPage(),
        );
    }
  }
}

class _LogoutScaffold extends StatelessWidget {
  final Widget child;
  final String? backRoute;
  const _LogoutScaffold({required this.child, this.backRoute});

  @override
  Widget build(BuildContext context) {
    Future<void> handleBack() async {
      if (backRoute == null || !context.mounted) return;
      Navigator.pushReplacementNamed(context, backRoute!);
    }

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOut) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            RouteConstants.login,
            (_) => false,
          );
        }
      },
      child: PopScope<Object?>(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop || backRoute == null) return;
          unawaited(handleBack());
        },
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: kBgColor,
            elevation: 0,
            automaticallyImplyLeading: backRoute != null,
            leading: backRoute == null
                ? null
                : IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: handleBack,
                  ),
            title: const Text(
              'Taxi Meter',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: const [ProfileMenuButton(), SizedBox(width: 12)],
          ),
          body: child,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/widgets/popup_message_view.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushReplacementNamed(context, RouteConstants.vehicle);
          } else if (state is AuthFailure) {
            showErrorPopup(
              context,
              message: state.message,
            );
          }
        },
        child: const LoginForm(),
      ),
    );
  }
}

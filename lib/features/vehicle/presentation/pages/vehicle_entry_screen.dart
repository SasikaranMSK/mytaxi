import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/widgets/popup_message_view.dart';
import '../bloc/vehicle_bloc.dart';
import '../bloc/vehicle_event.dart';
import '../bloc/vehicle_state.dart';

class VehicleEntryScreen extends StatefulWidget {
  const VehicleEntryScreen({super.key});

  @override
  State<VehicleEntryScreen> createState() => _VehicleEntryScreenState();
}

class _VehicleEntryScreenState extends State<VehicleEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicleController = TextEditingController();

  void _submit() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    final vehicleNo = _vehicleController.text.trim();
    context.read<VehicleBloc>().add(
      VehicleSubmitted(networkId: 2, vehicleNo: vehicleNo),
    );
  }

  @override
  void dispose() {
    _vehicleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VehicleBloc, VehicleState>(
      listenWhen: (previous, current) =>
          current is VehicleFailure || current is VehicleSuccess,
      listener: (context, state) {
        if (state is VehicleFailure) {
          showErrorPopup(context, message: state.message);
        }

        if (state is VehicleSuccess) {
          if (!context.mounted) return;
          Navigator.pushReplacementNamed(context, RouteConstants.dashboard);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1E2A32),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Enter Vehicle Number",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: TextFormField(
                  controller: _vehicleController,
                  textCapitalization: TextCapitalization.characters,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vehicle number is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Vehicle Number",
                    prefixIcon: const Icon(Icons.directions_car),
                    filled: true,
                    fillColor: const Color(0xFF26333D),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: BlocBuilder<VehicleBloc, VehicleState>(
                  builder: (context, state) {
                    final loading = state is VehicleLoading;
                    return ElevatedButton(
                      onPressed: loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text("CONTINUE"),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

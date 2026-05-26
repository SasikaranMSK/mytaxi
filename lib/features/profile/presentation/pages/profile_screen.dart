import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/color_constants.dart';
import '../../../../di/injection_container.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../viewmodel/profile_view_model.dart'; // ✅ add this
import 'package:meter_taxi/main.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ProfileBloc>()..add(const LoadProfile()),
      child: Scaffold(
        backgroundColor: kBgColor,
        appBar: AppBar(
          backgroundColor: kBgColor,
          elevation: 0,
          title: const Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(
                child: CircularProgressIndicator(color: kAccentColor),
              );
            }

            if (state is ProfileError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProfileBloc>().add(const RefreshProfile());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentColor,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is ProfileLoaded) {
              final ProfileViewModel profile = state.profile; // ✅ ViewModel

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ProfileBloc>().add(const RefreshProfile());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Profile Photo
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: kAccentColor.withValues(alpha: 0.3),
                        backgroundImage: profile.profilePhoto != null
                            ? NetworkImage(profile.profilePhoto!)
                            : null,
                        child: profile.profilePhoto == null
                            ? const Icon(
                          Icons.person,
                          size: 60,
                          color: kAccentColor,
                        )
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Full Name
                      Text(
                        profile.fullName, // ✅ VM helper
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Username
                      Text(
                        profile.usernameText, // ✅ '@username'
                        style: TextStyle(
                          color: kSecondaryText.withValues(alpha: 0.7),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Profile Details Card
                      _buildInfoCard(
                        children: [
                          _buildInfoRow(Icons.email, 'Email', profile.emailText),
                          const Divider(color: Colors.white12, height: 32),
                          _buildInfoRow(
                            Icons.phone,
                            'Mobile',
                            profile.mobileText,
                          ),
                          const Divider(color: Colors.white12, height: 32),
                          _buildInfoRow(
                            Icons.call,
                            'Phone',
                            profile.phoneText,
                          ),
                          if (profile.hasAddress) ...[
                            const Divider(color: Colors.white12, height: 32),
                            _buildInfoRow(
                              Icons.location_on,
                              'Address',
                              profile.addressText,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Account Details Card
                      _buildInfoCard(
                        title: 'Account Details',
                        children: [
                          _buildInfoRow(
                            Icons.account_circle,
                            'Username',
                            profile.username,
                          ),
                          const Divider(color: Colors.white12, height: 32),
                          _buildInfoRow(
                            Icons.calendar_today,
                            'Created At',
                            profile.user.createdAtText, // ✅ from UserViewModel
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Settings Card
                      _buildInfoCard(
                        title: 'Settings',
                        children: [
                          Builder(builder: (context) {
                            final appState =
                                TaxiMeterApp.of(context); // from main
                            return SwitchListTile(
                              title: const Text('Dark Mode'),
                              value: appState?.isDark ?? true,
                              onChanged: (_) => appState?.toggleDark(),
                              activeThumbColor: kAccentColor,
                              contentPadding: EdgeInsets.zero,
                            );
                          }),
                          const Divider(color: Colors.white12, height: 32),
                          Builder(builder: (context) {
                            final appState = TaxiMeterApp.of(context);
                            return SwitchListTile(
                              title: const Text('Large Text'),
                              value: appState?.largeText ?? false,
                              onChanged: (_) => appState?.toggleLargeText(),
                              activeThumbColor: kAccentColor,
                              contentPadding: EdgeInsets.zero,
                            );
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard({String? title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(
                color: kAccentColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
          ],
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: kAccentColor, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: kSecondaryText.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

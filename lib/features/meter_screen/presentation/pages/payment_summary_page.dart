import 'package:flutter/material.dart';
import '../../../../core/constants/color_constants.dart';
import '../../../tariff/domain/entities/tariff_entity.dart';
import '../viewmodel/payment_summary_view_model.dart';

class PaymentSummaryArgs {
  final double distanceKm;
  final int waitingSeconds;
  final double totalFare;
  final DateTime startTime;
  final DateTime endTime;
  final TariffEntity tariff;

  PaymentSummaryArgs({
    required this.distanceKm,
    required this.waitingSeconds,
    required this.totalFare,
    required this.startTime,
    required this.endTime,
    required this.tariff,
  });
}

class PaymentSummaryPage extends StatefulWidget {
  final PaymentSummaryArgs args;
  const PaymentSummaryPage({super.key, required this.args});

  @override
  State<PaymentSummaryPage> createState() => _PaymentSummaryPageState();
}

class _PaymentSummaryPageState extends State<PaymentSummaryPage> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final vm = PaymentSummaryViewModel(widget.args);
    final b = vm.breakdown;

    return Scaffold(
      backgroundColor: kBgColor,
      appBar: AppBar(
        backgroundColor: kBgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryText),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          'Ride Summary',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: kPrimaryText,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Total Fare Banner
                _totalFareBanner(context, vm),
                const SizedBox(height: 28),

                // Ride Details List
                _rideDetailsSection(context, vm),
                const SizedBox(height: 28),

                // Fare Breakdown List
                _fareBreakdownSection(context, b),
                const SizedBox(height: 32),

                // Collect Payment Button
                _collectButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _totalFareBanner(BuildContext context, PaymentSummaryViewModel vm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            kAccentColor,
            Color.lerp(kAccentColor, Colors.black, 0.3) ?? kAccentColor,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(
            'Total Fare',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                vm.totalFareText,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _rideDetailsSection(BuildContext context, PaymentSummaryViewModel vm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ride Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: kPrimaryText,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: kCardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _detailRow(context, 'Distance', vm.distanceText, Icons.map),
                _dividerRow(),
                _detailRow(
                  context,
                  'Duration',
                  vm.durationText,
                  Icons.access_time,
                ),
                _dividerRow(),
                _detailRow(
                  context,
                  'Waiting Time',
                  vm.waitingText,
                  Icons.hourglass_empty,
                ),
                _dividerRow(),
                _detailRow(
                  context,
                  'Start Time',
                  vm.startTimeText,
                  Icons.schedule,
                ),
                _dividerRow(),
                _detailRow(context, 'End Time', vm.endTimeText, Icons.schedule),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: kAccentColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: kSecondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dividerRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0),
      child: Divider(color: Colors.white12, height: 1),
    );
  }

  Widget _fareBreakdownSection(BuildContext context, FareBreakdownViewModel b) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fare Breakdown',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: kPrimaryText,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          color: kCardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _breakdownRow(context, 'Flag Fall', '\$${b.flagFallText}'),
                if (b.distanceFareTier1 > 0) ...[
                  _dividerRow(),
                  _breakdownRow(
                    context,
                    'Distance (km) - Tier 1',
                    '\$${b.tier1Text}',
                  ),
                ],
                if (b.distanceFareTier2 > 0) ...[
                  _dividerRow(),
                  _breakdownRow(
                    context,
                    'Distance (km) - Tier 2',
                    '\$${b.tier2Text}',
                  ),
                ],
                if (b.waitingFare > 0) ...[
                  _dividerRow(),
                  _breakdownRow(
                    context,
                    'Waiting Time Charges',
                    '\$${b.waitingText}',
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(
                    color: Colors.white24,
                    height: 2,
                    thickness: 1.5,
                  ),
                ),
                _breakdownRow(
                  context,
                  'Total Fare',
                  '\$${b.totalText}',
                  isTotal: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _breakdownRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isTotal ? Colors.white : kSecondaryText,
              fontSize: isTotal ? 15 : 14,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: isTotal ? kAccentColor : Colors.white,
              fontSize: isTotal ? 18 : 15,
              fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _collectButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: _isProcessing
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.payments_outlined, color: Colors.white),
        label: Text(
          _isProcessing ? 'Processing...' : 'Collect Payment & Start New Trip',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: kGreenColor,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
        onPressed: _isProcessing
            ? null
            : () {
                setState(() => _isProcessing = true);
                // Immediately close the dialog
                if (mounted) {
                  Navigator.pop(context, true);
                }
              },
      ),
    );
  }
}

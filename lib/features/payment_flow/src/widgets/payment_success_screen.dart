import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:plebqr_india/component_library/component_library.dart';

class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({
    required this.amountInSats,
    required this.amountInInr,
    this.beneficiaryName,
    super.key,
  });

  final int? amountInSats;
  final String amountInInr;
  final String? beneficiaryName;

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen> {
  late ConfettiController _topConfettiController;
  late ConfettiController _centerConfettiController;

  @override
  void initState() {
    super.initState();
    _topConfettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _centerConfettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    // Start confetti animations
    _topConfettiController.play();
    // Delay center confetti for more dramatic effect
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _centerConfettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _topConfettiController.dispose();
    _centerConfettiController.dispose();
    super.dispose();
  }

  void _handleDone() {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          _handleDone();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Top confetti - falls from top
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _topConfettiController,
                blastDirection: pi / 2, // Downward
                maxBlastForce: 5,
                minBlastForce: 2,
                emissionFrequency: 0.05,
                numberOfParticles: 15,
                gravity: 0.1,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
              ),
            ),
            // Center confetti - explosive burst
            Align(
              alignment: Alignment.center,
              child: ConfettiWidget(
                confettiController: _centerConfettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.1,
                numberOfParticles: 30,
                maxBlastForce: 10,
                minBlastForce: 5,
                gravity: 0.1,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.yellow,
                  Colors.cyan,
                ],
              ),
            ),
            // Content
            SafeArea(
              child: Column(
                children: [
                  // Close button
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.mediumLarge),
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: _handleDone,
                        tooltip: 'Close',
                      ),
                    ),
                  ),
                  // Main content
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.mediumLarge,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Success icon
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_circle,
                                size: 80,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(height: Spacing.xxxLarge),
                            // Success title
                            Text(
                              'Payment Successful!',
                              style: Theme.of(
                                context,
                              ).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: Spacing.medium),
                            // Success message
                            Text(
                              'Your payment has been settled successfully',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: Spacing.xxxLarge),
                            // Amount card
                            Container(
                              padding: const EdgeInsets.all(
                                Spacing.mediumLarge,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  if (widget.beneficiaryName != null) ...[
                                    Text(
                                      'Paid to',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: Spacing.xSmall),
                                    Text(
                                      widget.beneficiaryName!,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: Spacing.medium),
                                  ],
                                  Text(
                                    'Amount Paid',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: Spacing.small),
                                  Text(
                                    '₹${widget.amountInInr}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .displaySmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  if (widget.amountInSats != null &&
                                      widget.amountInSats! > 0) ...[
                                    const SizedBox(height: Spacing.small),
                                    Text(
                                      '${widget.amountInSats} sats',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(color: Colors.grey[600]),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: Spacing.xxxLarge),
                            // Done button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _handleDone,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: Spacing.mediumLarge,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Done',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: Spacing.mediumLarge),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:easy_stepper/easy_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plebqr_india/plebqr_repository/plebqr_repository.dart';
import 'package:plebqr_india/features/payment_flow/src/payment_flow_cubit.dart';
import 'package:plebqr_india/features/payment_flow/src/payment_flow_state.dart';
import 'package:plebqr_india/features/payment_flow/src/widgets/step_content.dart';
import 'package:plebqr_india/features/payment_flow/src/widgets/payment_success_screen.dart';

class PaymentFlowScreen extends StatelessWidget {
  const PaymentFlowScreen({required this.repository, super.key});

  final PlebQrRepository repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PaymentFlowCubit>(
      create: (_) => PaymentFlowCubit(repository: repository),
      child: const PaymentFlowView(),
    );
  }
}

@visibleForTesting
class PaymentFlowView extends StatelessWidget {
  const PaymentFlowView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _releaseFocus(context),
      child: Scaffold(
        appBar: AppBar(title: const Text('PlebQR India')),
        body: BlocConsumer<PaymentFlowCubit, PaymentFlowState>(
          listenWhen:
              (oldState, newState) =>
                  oldState.submissionStatus != newState.submissionStatus,
          listener: (context, state) async {
            if (state.submissionStatus == SubmissionStatus.success &&
                state.invoice != null) {
              // Show success screen as modal
              final beneficiaryName =
                  state.paymentStatus?.receiptData?.summary.beneficiaryName;
              final cubit = context.read<PaymentFlowCubit>();

              // Wait for the success screen to be dismissed
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder:
                      (_) => PaymentSuccessScreen(
                        amountInSats: state.amountInSats,
                        amountInInr: state.invoice!.successAction.ccyAmount,
                        beneficiaryName: beneficiaryName,
                      ),
                  fullscreenDialog: true,
                ),
              );

              // Reset the payment flow state when user returns
              cubit.onCancel();
              return;
            }

            final hasError =
                state.submissionStatus == SubmissionStatus.genericError ||
                state.submissionStatus == SubmissionStatus.invalidUpiIdError ||
                state.submissionStatus ==
                    SubmissionStatus.paymentRequestError ||
                state.submissionStatus ==
                    SubmissionStatus.invoiceGenerationError ||
                state.submissionStatus == SubmissionStatus.paymentStatusError;

            if (hasError) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(_buildErrorSnackBar(context, state));
            }
          },
          builder: (context, state) {
            final cubit = context.read<PaymentFlowCubit>();
            return Column(
              children: [
                // Stepper
                _PaymentStepper(
                  activeStep: state.activeStep,
                  onStepChanged: cubit.onStepChanged,
                ),

                // Step Content
                Expanded(child: StepContent(state: state)),
              ],
            );
          },
        ),
      ),
    );
  }

  void _releaseFocus(BuildContext context) => FocusScope.of(context).unfocus();

  SnackBar _buildErrorSnackBar(BuildContext context, PaymentFlowState state) {
    final errorMessage = _getErrorMessage(state);
    return SnackBar(content: Text(errorMessage));
  }

  String _getErrorMessage(PaymentFlowState state) {
    switch (state.submissionStatus) {
      case SubmissionStatus.invalidUpiIdError:
        return 'Invalid UPI ID. Please check and try again.';
      case SubmissionStatus.paymentRequestError:
        return 'Failed to fetch payment details. Please try again.';
      case SubmissionStatus.invoiceGenerationError:
        return 'Failed to generate invoice. Please try again.';
      case SubmissionStatus.paymentStatusError:
        return 'Unable to check payment status.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}

class _PaymentStepper extends StatelessWidget {
  const _PaymentStepper({
    required this.activeStep,
    required this.onStepChanged,
  });

  final int activeStep;
  final ValueChanged<int> onStepChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
      child: EasyStepper(
        activeStep: activeStep,
        activeStepTextColor: primaryColor,
        finishedStepTextColor: primaryColor,
        activeStepIconColor: Colors.white,
        finishedStepIconColor: Colors.white,
        activeStepBackgroundColor: primaryColor,
        finishedStepBackgroundColor: primaryColor,
        stepRadius: 18,
        showLoadingAnimation: false,
        padding: const EdgeInsets.all(8),
        steps: [
          EasyStep(
            icon: const Icon(Icons.qr_code_scanner, size: 20),
            customTitle: const Text(
              'Scan QR\nEnter UPI',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.visible,
            ),
          ),
          EasyStep(
            icon: const Icon(Icons.currency_rupee, size: 20),
            customTitle: const Text(
              'Enter\nAmount',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.visible,
            ),
          ),
          EasyStep(
            icon: const Icon(Icons.receipt_long, size: 20),
            customTitle: const Text(
              'Pay\nInvoice',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11),
              maxLines: 2,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
        onStepReached: onStepChanged,
      ),
    );
  }
}

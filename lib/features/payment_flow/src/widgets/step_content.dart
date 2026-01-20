import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plebqr_india/features/payment_flow/src/payment_flow_cubit.dart';
import 'package:plebqr_india/features/payment_flow/src/payment_flow_state.dart';
import 'package:plebqr_india/features/payment_flow/src/widgets/step1_upi_entry.dart';
import 'package:plebqr_india/features/payment_flow/src/widgets/step2_amount_entry.dart';
import 'package:plebqr_india/features/payment_flow/src/widgets/step3_invoice_display.dart';

class StepContent extends StatelessWidget {
  const StepContent({required this.state, super.key});

  final PaymentFlowState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PaymentFlowCubit>();

    switch (state.activeStep) {
      case 0:
        return Step1UpiEntry(
          upiId: state.upiId,
          onUpiIdChanged: cubit.onUpiIdChanged,
          onUpiIdUnfocused: cubit.onUpiIdUnfocused,
          onStep1Submit: cubit.onStep1Submit,
          isLoading: state.submissionStatus == SubmissionStatus.inProgress,
        );
      case 1:
        return Step2AmountEntry(
          amount: state.amount,
          paymentRequest: state.paymentRequest,
          onAmountChanged: cubit.onAmountChanged,
          onAmountUnfocused: cubit.onAmountUnfocused,
          onStep2Submit: cubit.onStep2Submit,
          onBackPressed: cubit.onBackPressed,
          isLoading: state.submissionStatus == SubmissionStatus.inProgress,
        );
      case 2:
        return Step3InvoiceDisplay(
          invoice: state.invoice,
          amountInSats: state.amountInSats,
          paymentStatus: state.paymentStatus,
          onCancel: cubit.onCancel,
        );
      default:
        return const SizedBox();
    }
  }
}

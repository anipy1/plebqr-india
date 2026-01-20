import 'dart:async';

import 'package:bolt11_decoder/bolt11_decoder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plebqr_india/domain_models/domain_models.dart';
import 'package:plebqr_india/form_fields/form_fields.dart';
import 'package:plebqr_india/plebqr_api/src/models/response/invoice_rm.dart';
import 'package:plebqr_india/plebqr_repository/plebqr_repository.dart';
import 'package:plebqr_india/features/payment_flow/src/payment_flow_state.dart';

class PaymentFlowCubit extends Cubit<PaymentFlowState> {
  PaymentFlowCubit({required this.repository})
    : super(const PaymentFlowState());

  final PlebQrRepository repository;
  Timer? _pollingTimer;

  // Step 1: UPI ID handling
  void onUpiIdChanged(String newValue) {
    final previousState = state;
    final previousUpiIdState = previousState.upiId;
    final shouldValidate = !previousUpiIdState.isValid;

    final newUpiIdState =
        shouldValidate
            ? UpiId.validated(newValue)
            : UpiId.unvalidated(newValue);

    emit(state.copyWith(upiId: newUpiIdState));
  }

  void onUpiIdUnfocused() {
    final previousState = state;
    final previousUpiIdValue = previousState.upiId.value;

    final newUpiIdState = UpiId.validated(previousUpiIdValue);
    emit(previousState.copyWith(upiId: newUpiIdState));
  }

  // Step 2: Amount handling
  void onAmountChanged(String newValue) {
    final previousState = state;
    final previousAmountState = previousState.amount;
    final shouldValidate = !previousAmountState.isValid;

    final newAmountState =
        shouldValidate
            ? Amount.validated(newValue)
            : Amount.unvalidated(newValue);

    emit(state.copyWith(amount: newAmountState));
  }

  void onAmountUnfocused() {
    final previousState = state;
    final previousAmountValue = previousState.amount.value;

    final newAmountState = Amount.validated(previousAmountValue);
    emit(previousState.copyWith(amount: newAmountState));
  }

  // Step 1: Fetch payment request
  Future<void> onStep1Submit() async {
    final upiId = UpiId.validated(state.upiId.value);

    if (!upiId.isValid) {
      emit(state.copyWith(upiId: upiId));
      return;
    }

    emit(
      state.copyWith(
        upiId: upiId,
        submissionStatus: SubmissionStatus.inProgress,
      ),
    );

    try {
      final paymentRequest = await repository.getPaymentRequest(upiId.value);
      emit(
        state.copyWith(
          paymentRequest: paymentRequest,
          activeStep: 1,
          submissionStatus: SubmissionStatus.idle,
        ),
      );
    } catch (error) {
      final submissionStatus =
          error is InvalidUpiIdException
              ? SubmissionStatus.invalidUpiIdError
              : error is PaymentRequestException
              ? SubmissionStatus.paymentRequestError
              : SubmissionStatus.genericError;

      emit(
        state.copyWith(
          upiId: upiId,
          submissionStatus: submissionStatus,
          error: error,
        ),
      );
    }
  }

  // Step 2: Generate invoice
  Future<void> onStep2Submit() async {
    final amount = Amount.validated(state.amount.value);
    final paymentRequest = state.paymentRequest;

    if (!amount.isValid || paymentRequest == null) {
      emit(state.copyWith(amount: amount));
      return;
    }

    // TODO: Validate amount against API limits (minSendable/maxSendable)
    // Note: minSendable and maxSendable are in millisats, not INR.
    // We would need to convert INR to sats using a conversion rate to properly validate.
    // For now, we rely on the form field validation (1-200 INR) and let the API handle limits.

    final amountInInr = amount.numericValue!.toInt();

    emit(
      state.copyWith(
        amount: amount,
        submissionStatus: SubmissionStatus.inProgress,
      ),
    );

    try {
      final invoice = await repository.generateInvoice(
        paymentRequest.callback,
        amountInInr,
      );
      // Calculate amount in sats from the bolt11 invoice
      final amountInSats = _calculateAmountInSats(invoice.pr);
      emit(
        state.copyWith(
          invoice: invoice,
          amountInSats: amountInSats,
          activeStep: 2,
          submissionStatus: SubmissionStatus.idle,
        ),
      );
      // Start polling for payment status
      _startPolling(invoice);
    } catch (error) {
      final submissionStatus =
          error is InvoiceGenerationException
              ? SubmissionStatus.invoiceGenerationError
              : SubmissionStatus.genericError;

      emit(
        state.copyWith(
          amount: amount,
          submissionStatus: submissionStatus,
          error: error,
        ),
      );
    }
  }

  // Step 3: Poll payment status
  void _startPolling(InvoiceRM invoice) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (state.paymentStatus?.status == 'Settled') {
        timer.cancel();
        return;
      }

      try {
        final amountInSats = _calculateAmountInSats(invoice.pr);
        // Use the status URL from successAction instead of building from tracker
        final paymentStatus = await repository.getPaymentStatus(
          invoice.successAction.url,
          invoice: invoice,
          amountInSats: amountInSats,
        );

        emit(
          state.copyWith(
            paymentStatus: paymentStatus,
            submissionStatus:
                paymentStatus.status == 'Settled'
                    ? SubmissionStatus.success
                    : SubmissionStatus.idle,
          ),
        );

        if (paymentStatus.status == 'Settled') {
          timer.cancel();
        }
      } catch (error) {
        emit(
          state.copyWith(
            submissionStatus: SubmissionStatus.paymentStatusError,
            error: error,
          ),
        );
        timer.cancel();
      }
    });
  }

  // Navigation
  void onStepChanged(int step) {
    if (step < state.activeStep) {
      // Allow going back
      emit(state.copyWith(activeStep: step));
    }
  }

  void onBackPressed() {
    if (state.activeStep > 0) {
      emit(state.copyWith(activeStep: state.activeStep - 1));
    }
  }

  // Cancel payment flow and reset to initial state
  void onCancel() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    emit(const PaymentFlowState());
  }

  // Cleanup
  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }

  // Helper: Calculate amount in sats from bolt11 invoice
  int _calculateAmountInSats(String bolt11) {
    try {
      final req = Bolt11PaymentRequest(bolt11);
      // req.amount is a Decimal type, convert to double
      // Convert to sats: 1 BTC = 100,000,000 sats
      final amountInBtc = req.amount.toDouble();
      final amountInSats = (amountInBtc * 100000000).round();
      return amountInSats;
    } catch (e) {
      // If decoding fails, return 0 as fallback
      return 0;
    }
  }
}

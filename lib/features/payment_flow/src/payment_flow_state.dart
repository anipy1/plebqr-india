import 'package:equatable/equatable.dart';
import 'package:plebqr_india/form_fields/form_fields.dart';
import 'package:plebqr_india/plebqr_api/src/models/response/invoice_rm.dart';
import 'package:plebqr_india/plebqr_api/src/models/response/payment_request_rm.dart';
import 'package:plebqr_india/plebqr_api/src/models/response/payment_status_rm.dart';

enum SubmissionStatus {
  /// Initial state, no submission in progress
  idle,

  /// API call in progress (fetching payment request, generating invoice, etc.)
  inProgress,

  /// Payment successfully settled
  success,

  /// Generic error (network, etc.)
  genericError,

  /// Invalid UPI ID error
  invalidUpiIdError,

  /// Payment request failed
  paymentRequestError,

  /// Invoice generation failed
  invoiceGenerationError,

  /// Payment status check failed
  paymentStatusError,
}

class PaymentFlowState extends Equatable {
  const PaymentFlowState({
    this.activeStep = 0,
    this.upiId = const UpiId.unvalidated(),
    this.amount = const Amount.unvalidated(),
    this.paymentRequest,
    this.invoice,
    this.amountInSats,
    this.paymentStatus,
    this.submissionStatus = SubmissionStatus.idle,
    this.error,
  });

  final int activeStep;
  final UpiId upiId;
  final Amount amount;
  final PaymentRequestRM? paymentRequest;
  final InvoiceRM? invoice;
  final int? amountInSats;
  final PaymentStatusRM? paymentStatus;
  final SubmissionStatus submissionStatus;
  final dynamic error;

  PaymentFlowState copyWith({
    int? activeStep,
    UpiId? upiId,
    Amount? amount,
    PaymentRequestRM? paymentRequest,
    InvoiceRM? invoice,
    int? amountInSats,
    PaymentStatusRM? paymentStatus,
    SubmissionStatus? submissionStatus,
    dynamic error,
  }) {
    return PaymentFlowState(
      activeStep: activeStep ?? this.activeStep,
      upiId: upiId ?? this.upiId,
      amount: amount ?? this.amount,
      paymentRequest: paymentRequest ?? this.paymentRequest,
      invoice: invoice ?? this.invoice,
      amountInSats: amountInSats ?? this.amountInSats,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      submissionStatus: submissionStatus ?? this.submissionStatus,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    activeStep,
    upiId,
    amount,
    paymentRequest,
    invoice,
    amountInSats,
    paymentStatus,
    submissionStatus,
    error,
  ];
}

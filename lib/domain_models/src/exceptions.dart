/// Exception thrown when the UPI ID format is invalid.
class InvalidUpiIdException implements Exception {
  const InvalidUpiIdException(this.message);
  final String message;
}

/// Exception thrown when payment request fails.
class PaymentRequestException implements Exception {
  const PaymentRequestException(this.message);
  final String message;
}

/// Exception thrown when invoice generation fails.
class InvoiceGenerationException implements Exception {
  const InvoiceGenerationException(this.message);
  final String message;
}

/// Exception thrown when payment status check fails.
class PaymentStatusException implements Exception {
  const PaymentStatusException(this.message);
  final String message;
}

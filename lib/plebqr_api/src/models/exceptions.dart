/// Exception thrown when the UPI ID format is invalid.
class InvalidUpiId256DException implements Exception {
  const InvalidUpiId256DException(this.message);
  final String message;
}

/// Exception thrown when payment request fails.
class PaymentRequest256DException implements Exception {
  const PaymentRequest256DException(this.message);
  final String message;
}

/// Exception thrown when invoice generation fails.
class InvoiceGeneration256DException implements Exception {
  const InvoiceGeneration256DException(this.message);
  final String message;
}

/// Exception thrown when payment status check fails.
class PaymentStatus256DException implements Exception {
  const PaymentStatus256DException(this.message);
  final String message;
}

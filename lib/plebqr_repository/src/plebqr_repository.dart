import 'package:meta/meta.dart';
import 'package:plebqr_india/domain_models/domain_models.dart';
import 'package:plebqr_india/key_value_storage/key_value_storage.dart';
import 'package:plebqr_india/plebqr_api/plebqr_api.dart';
import 'package:plebqr_india/plebqr_api/src/models/exceptions.dart';
import 'package:plebqr_india/plebqr_repository/src/mappers/mappers.dart';
import 'package:plebqr_india/plebqr_repository/src/plebqr_local_storage.dart';

class PlebQrRepository {
  PlebQrRepository({
    required KeyValueStorage keyValueStorage,
    required this.remoteApi,
    @visibleForTesting PlebQrLocalStorage? localStorage,
  }) : _localStorage =
           localStorage ?? PlebQrLocalStorage(keyValueStorage: keyValueStorage);

  final PlebQrApi remoteApi;
  final PlebQrLocalStorage _localStorage;

  /// Fetches the payment request configuration for a given UPI ID.
  ///
  /// Returns a domain model with payment request details.
  ///
  /// Throws [InvalidUpiIdException] if the UPI ID format is invalid.
  /// Throws [PaymentRequestException] if the request fails.
  Future<PaymentRequestRM> getPaymentRequest(String upiId) async {
    try {
      final apiPaymentRequest = await remoteApi.getPaymentRequest(upiId);
      return apiPaymentRequest;
    } on InvalidUpiId256DException catch (e) {
      throw InvalidUpiIdException(e.message);
    } on PaymentRequest256DException catch (e) {
      throw PaymentRequestException(e.message);
    }
  }

  /// Generates a Lightning invoice for the specified INR amount.
  ///
  /// Returns the invoice response from the API.
  ///
  /// Throws [InvoiceGenerationException] if the request fails.
  Future<InvoiceRM> generateInvoice(String callbackUrl, int amountInInr) async {
    try {
      final apiInvoice = await remoteApi.generateInvoice(
        callbackUrl,
        amountInInr,
      );
      return apiInvoice;
    } on InvoiceGeneration256DException catch (e) {
      throw InvoiceGenerationException(e.message);
    }
  }

  /// Checks the payment status using the status URL.
  ///
  /// This method should be polled to check the payment status.
  /// Status values: "New", "Processing", "Settled"
  ///
  /// When status is "Settled", the payment is automatically stored in cache.
  ///
  /// Throws [PaymentStatusException] if the request fails.
  Future<PaymentStatusRM> getPaymentStatus(
    String statusUrl, {
    required InvoiceRM invoice,
    required int amountInSats,
  }) async {
    try {
      final apiPaymentStatus = await remoteApi.getPaymentStatus(statusUrl);

      // If payment is settled, store it in cache
      if (apiPaymentStatus.status == 'Settled' &&
          apiPaymentStatus.receiptData != null) {
        final settledPaymentCM = invoice.toSettledPaymentCacheModel(
          apiPaymentStatus,
          amountInSats: amountInSats,
        );
        await _localStorage.upsertSettledPayment(settledPaymentCM);
      }

      return apiPaymentStatus;
    } on PaymentStatus256DException catch (e) {
      throw PaymentStatusException(e.message);
    }
  }

  /// Retrieves all settled payments from cache.
  ///
  /// Returns a list of domain models.
  Future<List<SettledPayment>> getSettledPayments() async {
    final cachedPayments = await _localStorage.getAllSettledPayments();
    return cachedPayments.map((payment) => payment.toDomainModel()).toList();
  }

  /// Retrieves a specific settled payment by tracker ID.
  ///
  /// Returns null if the payment is not found in cache.
  Future<SettledPayment?> getSettledPayment(String tracker) async {
    final cachedPayment = await _localStorage.getSettledPayment(tracker);
    return cachedPayment?.toDomainModel();
  }

  /// Clears all settled payments from cache.
  Future<void> clearCache() async {
    await _localStorage.clear();
  }
}

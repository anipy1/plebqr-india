import 'package:plebqr_india/key_value_storage/key_value_storage.dart';

class PlebQrLocalStorage {
  PlebQrLocalStorage({required this.keyValueStorage});

  final KeyValueStorage keyValueStorage;

  /// Stores a settled payment in the cache.
  ///
  /// Uses the tracker as the key for easy retrieval.
  Future<void> upsertSettledPayment(SettledPaymentCM settledPayment) async {
    final box = await keyValueStorage.settledPaymentsBox;
    return box.put(settledPayment.tracker, settledPayment);
  }

  /// Retrieves a settled payment by tracker ID.
  Future<SettledPaymentCM?> getSettledPayment(String tracker) async {
    final box = await keyValueStorage.settledPaymentsBox;
    return box.get(tracker);
  }

  /// Retrieves all settled payments from cache.
  Future<List<SettledPaymentCM>> getAllSettledPayments() async {
    final box = await keyValueStorage.settledPaymentsBox;
    return box.values.toList();
  }

  /// Clears all settled payments from cache.
  Future<void> clear() async {
    final box = await keyValueStorage.settledPaymentsBox;
    await box.clear();
  }
}

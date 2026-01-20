class UrlBuilder {
  const UrlBuilder();

  /// Builds the payment request URL from a UPI ID.
  ///
  /// Parses the UPI ID format `{username}@{domain}` and constructs:
  /// `https://{domain}.temp.256d.in/.well-known/lnurlp/{username}`
  ///
  /// Examples:
  /// - `user123@bank` → `https://bank.temp.256d.in/.well-known/lnurlp/user123`
  /// - `merchant@paytm` → `https://paytm.temp.256d.in/.well-known/lnurlp/merchant`
  String buildPaymentRequestUrl(String upiId) {
    final parts = upiId.split('@');
    if (parts.length != 2) {
      throw ArgumentError(
        'Invalid UPI ID format. Expected format: username@domain',
      );
    }
    final username = parts[0];
    final domain = parts[1];
    return 'https://$domain.temp.256d.in/.well-known/lnurlp/$username';
  }

  /// Builds the invoice generation URL from the callback URL and amount.
  ///
  /// Constructs: `{callback_url}?ccy=INR&ccyamt={amount}`
  String buildInvoiceGenerationUrl(String callbackUrl, int amountInInr) {
    return '$callbackUrl?ccy=INR&ccyamt=$amountInInr';
  }

  /// Builds the payment status check URL from the tracker ID.
  ///
  /// Constructs: `https://pay.256d.in/checkstatus/{tracker}`
  String buildPaymentStatusUrl(String tracker) {
    return 'https://pay.256d.in/checkstatus/$tracker';
  }
}

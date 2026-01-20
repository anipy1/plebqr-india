import 'package:flutter/foundation.dart';

/// Result of parsing a UPI QR code or URL
sealed class UpiParseResult {
  const UpiParseResult();
}

/// Successfully parsed static UPI QR code with extracted UPI ID
class UpiParseSuccess extends UpiParseResult {
  const UpiParseSuccess(this.upiId);

  final String upiId;
}

/// Dynamic QR code detected (not supported)
class UpiParseDynamicQrCode extends UpiParseResult {
  const UpiParseDynamicQrCode();
}

/// Invalid UPI URL format
class UpiParseInvalidFormat extends UpiParseResult {
  const UpiParseInvalidFormat(this.message);

  final String message;
}

/// UPI Deep Link Parser
///
/// Parses UPI deep link URLs (e.g., `upi://pay?pa=merchant@oksbi&...`)
/// and extracts the UPI ID. Also detects dynamic QR codes which are not supported.
class UpiParser {
  /// Parse UPI URL and extract UPI ID if it's a static QR code
  ///
  /// Returns:
  /// - [UpiParseSuccess] with UPI ID if it's a valid static QR code
  /// - [UpiParseDynamicQrCode] if it's a dynamic QR code (not supported)
  /// - [UpiParseInvalidFormat] if the format is invalid
  static UpiParseResult parseUpiUrl(String upiUrl) {
    try {
      // Handle both upi:// and upiqr:// schemes
      final normalizedUrl = upiUrl.trim();
      if (!normalizedUrl.toLowerCase().startsWith('upi://') &&
          !normalizedUrl.toLowerCase().startsWith('upiqr://')) {
        // If it's not a UPI URL, check if it's already a UPI ID format
        // This handles cases where user manually enters UPI ID or scans a plain UPI ID
        if (_looksLikeUpiId(normalizedUrl)) {
          return UpiParseSuccess(normalizedUrl);
        }
        return const UpiParseInvalidFormat(
          'Invalid UPI format. Expected UPI URL (upi://pay?...) or UPI ID (username@bank)',
        );
      }

      // Parse the URI
      final uri = Uri.parse(normalizedUrl);

      // Extract query parameters
      final params = uri.queryParameters;

      if (params.isEmpty) {
        return const UpiParseInvalidFormat(
          'No query parameters found in UPI URL',
        );
      }

      // Check for dynamic QR code indicator (url parameter)
      if (params.containsKey('url') && params['url']!.isNotEmpty) {
        return const UpiParseDynamicQrCode();
      }

      // Extract payee address (UPI ID)
      final payeeAddress = params['pa'];
      if (payeeAddress == null || payeeAddress.isEmpty) {
        return const UpiParseInvalidFormat(
          'UPI ID (pa parameter) not found in QR code',
        );
      }

      // Check for known gateway patterns that indicate dynamic QR codes
      // even if url parameter is missing (some gateways might not include it)
      if (_isGatewayPattern(payeeAddress)) {
        return const UpiParseDynamicQrCode();
      }

      // Successfully extracted UPI ID from static QR code
      return UpiParseSuccess(payeeAddress);
    } catch (e) {
      debugPrint('Error parsing UPI URL: $e');
      return UpiParseInvalidFormat('Failed to parse UPI URL: $e');
    }
  }

  /// Extract only the UPI ID from a UPI URL (if static)
  ///
  /// Returns the UPI ID if successful, null otherwise.
  /// Use [parseUpiUrl] if you need to distinguish between different error types.
  static String? extractUpiId(String upiUrl) {
    final result = parseUpiUrl(upiUrl);
    return switch (result) {
      UpiParseSuccess(upiId: final upiId) => upiId,
      _ => null,
    };
  }

  /// Check if a string looks like a UPI ID format
  static bool _looksLikeUpiId(String text) {
    // Basic check: contains @ and looks like email format
    if (!text.contains('@')) {
      return false;
    }
    final parts = text.split('@');
    if (parts.length != 2) {
      return false;
    }
    // Check if both parts are non-empty
    return parts[0].isNotEmpty && parts[1].isNotEmpty;
  }

  /// Check if payee address contains gateway patterns indicating dynamic QR code
  static bool _isGatewayPattern(String payeeAddress) {
    final lowerAddress = payeeAddress.toLowerCase();
    final gatewayPatterns = [
      '@razorpay',
      '@paytm',
      '@phonepe',
      '@gateway',
      'temp',
      'merchant@paytm',
      'merchant@phonepe',
    ];

    return gatewayPatterns.any((pattern) => lowerAddress.contains(pattern));
  }
}

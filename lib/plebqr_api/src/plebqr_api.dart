import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:plebqr_india/plebqr_api/src/models/exceptions.dart';
import 'package:plebqr_india/plebqr_api/src/models/models.dart';
import 'package:plebqr_india/plebqr_api/src/url_builder.dart';

class PlebQrApi {
  PlebQrApi({
    @visibleForTesting Dio? dio,
    @visibleForTesting UrlBuilder? urlBuilder,
  }) : _dio = dio ?? Dio(),
       _urlBuilder = urlBuilder ?? const UrlBuilder() {
    _dio.interceptors.add(LogInterceptor(responseBody: false));
  }

  final Dio _dio;
  final UrlBuilder _urlBuilder;

  /// Fetches the payment request configuration for a given UPI ID.
  ///
  /// Parses the UPI ID to construct the appropriate endpoint URL and
  /// retrieves payment request details including callback URL, min/max
  /// sendable amounts, and metadata.
  ///
  /// Throws [InvalidUpiId256DException] if the UPI ID format is invalid.
  /// Throws [PaymentRequest256DException] if the request fails.
  Future<PaymentRequestRM> getPaymentRequest(String upiId) async {
    try {
      final url = _urlBuilder.buildPaymentRequestUrl(upiId);

      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.json,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // Try to parse the response as JSON
      // Note: Server may send wrong content-type header, but body might still be valid JSON
      Map<String, dynamic> jsonObject;

      if (response.data is Map<String, dynamic>) {
        // Already a Map, use it directly
        jsonObject = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        // Response is a String, try to parse it as JSON
        final responseString = response.data as String;

        try {
          // Manually parse the JSON string using jsonDecode
          jsonObject = jsonDecode(responseString) as Map<String, dynamic>;
        } catch (_) {
          // If parsing fails, it's not valid JSON
          throw PaymentRequest256DException(
            'UPI ID not found or not registered. Please check the UPI ID and try again.',
          );
        }
      } else {
        throw PaymentRequest256DException(
          'Unexpected response format. Expected JSON but received: ${response.data.runtimeType}',
        );
      }

      final paymentRequest = PaymentRequestRM.fromJson(jsonObject);
      return paymentRequest;
    } on ArgumentError catch (e) {
      throw InvalidUpiId256DException(e.message);
    } on PaymentRequest256DException {
      rethrow;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;

      String errorMessage;
      if (statusCode == 404) {
        errorMessage =
            'UPI ID not found. Please check the UPI ID and try again.';
      } else if (responseData != null) {
        errorMessage = responseData.toString();
      } else {
        errorMessage = e.message ?? 'Failed to fetch payment request';
      }

      throw PaymentRequest256DException(errorMessage);
    } catch (e) {
      throw PaymentRequest256DException('Failed to fetch payment request: $e');
    }
  }

  /// Generates a Lightning invoice for the specified INR amount.
  ///
  /// Uses the callback URL from the payment request to generate a
  /// bolt11 Lightning invoice.
  ///
  /// Throws [InvoiceGeneration256DException] if the request fails.
  Future<InvoiceRM> generateInvoice(String callbackUrl, int amountInInr) async {
    try {
      final url = _urlBuilder.buildInvoiceGenerationUrl(
        callbackUrl,
        amountInInr,
      );

      final response = await _dio.get(url);

      // Parse response - handle both Map and String (when server sends wrong content-type)
      Map<String, dynamic> jsonObject;
      if (response.data is Map<String, dynamic>) {
        jsonObject = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        final responseString = response.data as String;
        try {
          jsonObject = jsonDecode(responseString) as Map<String, dynamic>;
        } catch (e) {
          throw InvoiceGeneration256DException(
            'Failed to generate invoice: Invalid response format',
          );
        }
      } else {
        throw InvoiceGeneration256DException(
          'Unexpected response format. Expected JSON but received: ${response.data.runtimeType}',
        );
      }

      final invoice = InvoiceRM.fromJson(jsonObject);
      return invoice;
    } on DioException catch (e) {
      throw InvoiceGeneration256DException(
        e.response?.data?.toString() ??
            e.message ??
            'Failed to generate invoice',
      );
    } catch (e) {
      throw InvoiceGeneration256DException('Failed to generate invoice: $e');
    }
  }

  /// Checks the payment status using the status URL.
  ///
  /// This endpoint should be polled to check the payment status.
  /// Status values: "New", "Processing", "Settled"
  ///
  /// Throws [PaymentStatus256DException] if the request fails.
  Future<PaymentStatusRM> getPaymentStatus(String statusUrl) async {
    try {
      final response = await _dio.get(
        statusUrl,
        options: Options(
          headers: {'Accept': 'application/json'},
          responseType: ResponseType.json,
        ),
      );

      // Parse response - handle both Map and String (when server sends wrong content-type)
      Map<String, dynamic> jsonObject;
      if (response.data is Map<String, dynamic>) {
        jsonObject = response.data as Map<String, dynamic>;
      } else if (response.data is String) {
        final responseString = response.data as String;
        try {
          jsonObject = jsonDecode(responseString) as Map<String, dynamic>;
        } catch (e) {
          throw PaymentStatus256DException(
            'Failed to check payment status: Invalid response format',
          );
        }
      } else {
        throw PaymentStatus256DException(
          'Unexpected response format. Expected JSON but received: ${response.data.runtimeType}',
        );
      }

      final paymentStatus = PaymentStatusRM.fromJson(jsonObject);
      return paymentStatus;
    } on DioException catch (e) {
      throw PaymentStatus256DException(
        e.response?.data?.toString() ??
            e.message ??
            'Failed to check payment status',
      );
    } catch (e) {
      throw PaymentStatus256DException('Failed to check payment status: $e');
    }
  }
}

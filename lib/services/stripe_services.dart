import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:logger/logger.dart';
import 'package:stripe_paymnet_app/consts.dart';

import '../thank_you_page.dart';

class StripeServices {
  // Create a logger instance for debugging
  final logger = Logger(printer: PrettyPrinter());

  // Private constructor for singleton
  StripeServices._();

  // Singleton instance
  static final StripeServices instance = StripeServices._();

  /// Initiates a payment of $999.99 USD.
  /// Navigates to ThankYouPage on success, shows SnackBar on failure.
  Future<void> makePayment(BuildContext context) async {
    // Ensure context is valid for navigation
    if (!context.mounted) {
      logger.e("Invalid context: Cannot navigate");
      return;
    }

    try {
      // Step 1: Create Payment Intent
      logger.i("Creating Payment Intent...");
      String? paymentClientSecret = await _createPaymentIntent(99999, "USD");
      if (paymentClientSecret == null) {
        _showSnackBar(context, 'Failed to create payment intent');
        logger.e("Failed to create payment intent");
        return;
      }

      // Step 2: Initialize Payment Sheet
      logger.i("Initializing Payment Sheet...");
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentClientSecret,
          merchantDisplayName: "Md Razib",
        ),
      );
      logger.i("Payment Sheet initialized");

      // Step 3: Process Payment
      logger.i("Processing payment...");
      await _processPayment();

      // Step 4: Navigate to ThankYouPage on success
      logger.i("Payment successful");
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ThankYouPage()),
        );
      }
    } catch (e) {
      // Show SnackBar on failure
      if (context.mounted) {
        _showSnackBar(context, 'Payment failed: $e');
      }
      logger.e("Error making payment: $e");
    }
  }

  /// Creates a Payment Intent by calling Stripe's API.
  /// Returns the client secret or null if the request fails.
  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      final Dio dio = Dio();
      Map<String, dynamic> data = {
        'amount': _calculateAmount(amount),
        'currency': currency,
      };
      var response = await dio.post(
        "https://api.stripe.com/v1/payment_intents",
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": "Bearer ${dotenv.env['STRIP_SECRET_KEY']}",
            "Content-Type": "application/x-www-form-urlencoded",
          },
        ),
      );
      if (response.data != null) {
        logger.i("Payment Intent created: ${response.data['client_secret']}");
        return response.data["client_secret"];
      }
      return null;
    } catch (e) {
      logger.e("Error creating payment intent: $e");
      return null;
    }
  }

  /// Presents the Payment Sheet to process the payment.
  Future<void> _processPayment() async {
    try {
      // Show the Payment Sheet (handles confirmation automatically)
      await Stripe.instance.presentPaymentSheet();
      logger.i("Payment Sheet presented successfully");
    } catch (e) {
      logger.e("Error processing payment: $e");
      rethrow; // Re-throw to handle in makePayment
    }
  }

  /// Converts amount to cents for Stripe (e.g., 99999 -> 9999900).
  String _calculateAmount(int amount) {
    final calculateAmount = amount * 100;
    return calculateAmount.toString();
  }

  /// Shows a SnackBar with the specified message.
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
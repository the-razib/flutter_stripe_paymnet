import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'dart:convert';

class StripeServicesGetWithHttp {
  // Create a logger instance for debugging
  final logger = Logger(printer: PrettyPrinter());

  // Private constructor for singleton
  StripeServicesGetWithHttp._();

  // Singleton instance
  static final StripeServicesGetWithHttp instance =
      StripeServicesGetWithHttp._();

  /// Initiates a payment of $999.99 USD.
  /// Navigates to VCongratulationScreen on success using GetX, shows snackbar on failure.
  Future<void> makePayment() async {
    try {
      // Step 1: Create Payment Intent
      logger.i("Creating Payment Intent...");
      String? paymentClientSecret = await _createPaymentIntent(99999, "USD");
      if (paymentClientSecret == null) {
        Get.snackbar(
          'Error',
          'Failed to create payment intent',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
        );
        logger.e("Failed to create payment intent");
        return;
      }

      // Step 2: Initialize Payment Sheet
      logger.i("Initializing Payment Sheet...");
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentClientSecret,
          merchantDisplayName: "Md Razib",
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'US',
            testEnv: true, // Set to false in production
          ),
        ),
      );
      logger.i("Payment Sheet initialized");

      // Step 3: Process Payment
      logger.i("Processing payment...");
      await _processPayment();

      // Step 4: Navigate to VCongratulationScreen on success using GetX
      logger.i("Payment successful");
      Get.to(
        () => const (),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 500),
      );
    } on StripeException catch (e) {
      // Handle Stripe-specific errors
      Get.snackbar(
        'Error',
        'Payment failed: ${e.error.localizedMessage}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
      logger.e("Stripe error: ${e.error.message}");
    } catch (e) {
      // Handle other errors
      Get.snackbar(
        'Error',
        'Payment failed: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
      logger.e("Error making payment: $e");
    }
  }

  /// Creates a Payment Intent by calling Stripe's API using http package.
  /// Returns the client secret or null if the request fails.
  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      final response = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        headers: {
          "Authorization": "Bearer ${dotenv.env['STRIP_SECRET_KEY']}",
          "Content-Type": "application/x-www-form-urlencoded",
        },
        body: {
          'amount': _calculateAmount(amount),
          'currency': currency,
          'automatic_payment_methods[enabled]': 'true',
          // Enable automatic payment methods
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        logger.i("Payment Intent created: ${data['client_secret']}");
        return data["client_secret"];
      } else {
        logger.e("Failed to create Payment Intent: ${response.body}");
        return null;
      }
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
}

import 'package:flutter/material.dart';
import 'package:stripe_paymnet_app/services/service_get_with_http.dart';
import 'package:stripe_paymnet_app/services/stripe_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Call the payment method from StripeServices
            StripeServices.instance.makePayment(context);
            // StripeServicesGetWithHttp.instance.makePayment();
          },
          child: Text('Pay with Stripe'),
        ),
      ),
    );
  }
}

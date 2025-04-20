import 'package:flutter/material.dart';
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
          },
          child: Text('Pay with Stripe'),
        ),
      ),
    );
  }
}

import 'package:field_star_technician_app/pages/payments/payment_page.dart';
import 'package:flutter/material.dart';

class SignaturePage extends StatelessWidget {
  const SignaturePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: .5,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Complete Service',
              style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'TCK-2451 • Final verification required',
              style: TextStyle(color: Colors.blueGrey, fontSize: 11),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const SizedBox(height: 10),

          Row(
            children: [
              step(Icons.shield_outlined, 'OTP', true),
              line(true),
              step(Icons.draw_outlined, 'Sign', true),
              line(true),
              step(Icons.credit_card, 'Payment', false),
            ],
          ),

          const SizedBox(height: 28),

          const Center(
            child: Text(
              'Customer Signature',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Confirm service satisfaction',
              style: TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ),

          const SizedBox(height: 22),

          Container(
            padding: const EdgeInsets.all(26),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              height: 154,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.draw_outlined, size: 40, color: Colors.blueGrey),
                  SizedBox(height: 12),
                  Text(
                    'Signature capture area',
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                  ),
                  Text(
                    'Request customer to sign here',
                    style: TextStyle(fontSize: 11, color: Colors.blueGrey),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Work Completed',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Text('✓ Temperature controller replaced',
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                SizedBox(height: 7),
                Text('✓ System calibrated and tested',
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                SizedBox(height: 7),
                Text('✓ Safety checks completed',
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
                SizedBox(height: 7),
                Text('✓ Equipment operational',
                    style: TextStyle(fontSize: 12, color: Colors.blueGrey)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                 Navigator.push(context,MaterialPageRoute(builder: (context)=>PaymentPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: const Text(
                'Confirm Signature',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget step(IconData icon, String title, bool active) {
    return Column(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: active ? Colors.blue : Colors.grey.shade300,
          child: Icon(icon, color: active ? Colors.white : Colors.grey, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 10,
            color: active ? Colors.blue : Colors.blueGrey,
          ),
        ),
      ],
    );
  }

  static Widget line(bool active) {
    return Expanded(
      child: Container(
        height: 1.5,
        margin: const EdgeInsets.only(bottom: 18),
        color: active ? Colors.blue : Colors.grey.shade300,
      ),
    );
  }
}
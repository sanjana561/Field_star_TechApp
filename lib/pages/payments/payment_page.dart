import 'package:field_star_technician_app/model/raiseComplaint_model.dart';
import 'package:field_star_technician_app/pages/payments/servicecompleted.dart';
import 'package:flutter/material.dart';

class PaymentPage extends StatefulWidget {
    final RaiseComplaintModel complaint;
  const PaymentPage({super.key, required this.complaint});

  @override
  State<PaymentPage> createState() => _PaymentPageState();

  static Widget step(IconData icon, String title, bool active) => Column(
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

  static Widget line(bool active) => Expanded(
    child: Container(
      height: 1.5,
      margin: const EdgeInsets.only(bottom: 18),
      color: active ? Colors.blue : Colors.grey.shade300,
    ),
  );
}

class _PaymentPageState extends State<PaymentPage> {
  String? selectedPaymentMethod;
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
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
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
          Row(
            children: [
              PaymentPage.step(Icons.shield_outlined, 'OTP', true),
              PaymentPage.line(true),
              PaymentPage.step(Icons.draw_outlined, 'Sign', true),
              PaymentPage.line(true),
              PaymentPage.step(Icons.credit_card, 'Payment', true),
            ],
          ),

          const SizedBox(height: 28),

          const Center(
            child: Text(
              'Collect Payment',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Total amount: ₹6,962',
              style: TextStyle(fontSize: 12, color: Colors.blueGrey),
            ),
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xff21262D),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invoice Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 16),
                amountRow('Parts', '₹3,200'),
                amountRow('Labor', '₹1,800'),
                amountRow('GST (18%)', '₹962'),
                Divider(color: Colors.white24),
                amountRow('Total', '₹6,962', bold: true),
              ],
            ),
          ),

          const SizedBox(height: 18),

          paymentOption(
            method: "upi",
            icon: Icons.credit_card,
            iconColor: Colors.blue,
            title: 'UPI Payment',
            subtitle: 'QR Code / UPI ID',
          ),

          const SizedBox(height: 12),

          paymentOption(
            method: "cash",
            icon: Icons.payments_outlined,
            iconColor: Colors.green,
            title: 'Cash Payment',
            subtitle: 'Collect cash directly',
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 42,
            child: ElevatedButton(
              onPressed: selectedPaymentMethod == null ? null : () {
                Navigator.push(context,MaterialPageRoute(builder: (context)=>ServiceCompletedPage(
                  complaint: widget.complaint,
                )));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                disabledBackgroundColor: Colors.orange.shade200,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: const Text(
                'Confirm Payment Received',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget paymentOption({
    required String method,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    final isSelected = selectedPaymentMethod == method;

    return InkWell(
      onTap: () {
        setState(() {
          selectedPaymentMethod = method;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xffEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: iconColor,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),

            if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}

class amountRow extends StatelessWidget {
  final String title, amount;
  final bool bold;

  const amountRow(this.title, this.amount, {super.key, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: bold ? 15 : 12,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            amount,
            style: TextStyle(
              color: Colors.white,
              fontSize: bold ? 15 : 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

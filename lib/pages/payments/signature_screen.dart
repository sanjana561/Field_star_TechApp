import 'dart:typed_data';

import 'package:field_star_technician_app/model/raiseComplaint_model.dart';
import 'package:field_star_technician_app/pages/payments/payment_page.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



class SignaturePage extends StatefulWidget {
  final RaiseComplaintModel complaint;

  const SignaturePage({super.key, required this.complaint});

  @override
  State<SignaturePage> createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
 bool _isVerifying = false;
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  bool _isSaving = false;
  bool get _hasSignature => _signatureController.isNotEmpty;

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _confirmSignature() async {
    if (!_hasSignature) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide signature first')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Export signature as image bytes
      final Uint8List? signatureBytes = await _signatureController.toPngBytes();

      if (signatureBytes == null) return;

      // Optional: Upload to Supabase storage
      final fileName = 'signature_${widget.complaint.dbId}_${DateTime.now().millisecondsSinceEpoch}.png';

      await Supabase.instance.client.storage
          .from('signatures')               // ← your bucket name
          .uploadBinary(fileName, signatureBytes);

      final signatureUrl = Supabase.instance.client.storage
          .from('signatures')
          .getPublicUrl(fileName);

      // Optional: Save URL to complaint record
      await Supabase.instance.client
          .from('Raise_complaint')
          .update({'signature_url': signatureUrl})
          .eq('id', widget.complaint.dbId!);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PaymentPage(
          complaint: widget.complaint,
        )),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: .5,
        title: const Text(
          'Complete Service',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
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

       

          // Signature Area
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

          // ── Signature Box ──
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                // Signature canvas
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Signature(
                    controller: _signatureController,
                    height: 200,
                    backgroundColor: Colors.grey.shade100,
                  ),
                ),
                // Clear button
                TextButton.icon(
                  onPressed: () {
                    _signatureController.clear();
                    setState(() {});
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Clear', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const SizedBox(height: 20),

          // Work Completed
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Work Completed', style: TextStyle(fontWeight: FontWeight.bold)),
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
                onPressed: _isSaving ? null : _confirmSignature,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Confirm Signature', style: TextStyle(fontWeight: FontWeight.bold)),
            
          
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
          style: TextStyle(fontSize: 10, color: active ? Colors.blue : Colors.blueGrey),
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
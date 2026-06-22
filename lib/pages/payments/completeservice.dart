import 'package:field_star_technician_app/model/raiseComplaint_model.dart';
import 'package:field_star_technician_app/pages/payments/signature_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CompleteServicePage extends StatefulWidget {
  final RaiseComplaintModel complaint;
  const CompleteServicePage({super.key, required this.complaint});

  @override
  State<CompleteServicePage> createState() => _CompleteServicePageState();
}

class _CompleteServicePageState extends State<CompleteServicePage>
    with SingleTickerProviderStateMixin {
  static const int _otpLength = 4;

  bool _isVerifying = false;
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  bool _hasError = false;

  String get _otpValue => _controllers.map((c) => c.text).join();
  bool get _isComplete => _otpValue.length == _otpLength;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_otpLength, (_) => TextEditingController());
    _focusNodes = List.generate(_otpLength, (_) => FocusNode());

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _shakeAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -8.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(_shakeController);
  }

  void _onChanged(int index, String value) {
    setState(() => _hasError = false);

    if (value.length == _otpLength) {
      for (int i = 0; i < _otpLength; i++) {
        _controllers[i].text = value[i];
      }
      _focusNodes[_otpLength - 1].requestFocus();
      setState(() {});
      return;
    }

    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
      _controllers[index - 1].clear();
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (!_isComplete) return;

    setState(() => _isVerifying = true);

    try {
      final response = await Supabase.instance.client
          .from('Raise_complaint')
          .select('otp')
          .eq('id', widget.complaint.dbId!)
          .single();

      final savedOtp = response['otp']?.toString() ?? '';

      if (_otpValue == savedOtp) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SignaturePage(complaint: widget.complaint),
          ),
        );
      } else {
        setState(() => _hasError = true);
        _shakeController.forward(from: 0);
        for (final c in _controllers) c.clear();
        _focusNodes[0].requestFocus();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isVerifying = false);
    }
  }

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
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
// ── Step indicator ──────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              step(Icons.shield_outlined, 'OTP', true),
              line(true),
              step(Icons.draw_outlined, 'Sign', false),
              line(false),
              step(Icons.credit_card, 'Payment', false),
            ],
          ),

          const SizedBox(height: 28),

// ── Info banner ─────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xfffff7ed),
              border: Border.all(color: const Color(0xffFDBA74)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined, color: Colors.deepOrange, size: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Customer OTP Required',
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Request customer to provide the 4-digit OTP sent to their registered mobile number',
                        style: TextStyle(
                          color: Colors.deepOrange,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

  // ── OTP heading ─────────────────────────────────────────────────
          const Center(
            child: Text(
              'Enter Customer OTP',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'This confirms service completion',
              style: TextStyle(color: Colors.blueGrey, fontSize: 12),
            ),
          ),

          const SizedBox(height: 22),

  // ── OTP boxes ───────────────────────────────────────────────────
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) => Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: child,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_otpLength, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _OtpBox(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    hasError: _hasError,
                    onChanged: (v) => _onChanged(i, v),
                    onKeyEvent: (e) => _onKeyEvent(i, e),
                  ),
                );
              }),
            ),
          ),

 // ── Error label ─────────────────────────────────────────────────
          const SizedBox(height: 10),
          AnimatedOpacity(
            opacity: _hasError ? 1 : 0,
            duration: const Duration(milliseconds: 200),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFDC2626),
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'Invalid OTP. Please try again.',
                  style: TextStyle(
                    color: Color(0xFFDC2626),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

 // ── Verify button ───────────────────────────────────────────────
          SizedBox(
            height: 44,
            child: ElevatedButton(
              onPressed: _isComplete && !_isVerifying ? _verifyOtp : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: _isVerifying
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Verify OTP',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget step(IconData icon, String title, bool active) {
    return Column(
      children: [
        CircleAvatar(
          radius: 17,
          backgroundColor: active ? Colors.blue : Colors.grey.shade200,
          child: Icon(
            icon,
            size: 18,
            color: active ? Colors.white : Colors.grey,
          ),
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

  Widget line(bool active) {
    return Expanded(
      child: Container(
        height: 1.5,
        margin: const EdgeInsets.only(bottom: 18),
        color: active ? Colors.blue : Colors.grey.shade300,
      ),
    );
  }
}

// ─── Single OTP Box ───────────────────────────────────────────────────────────

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final ValueChanged<KeyEvent> onKeyEvent;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
    required this.onKeyEvent,
  });

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: onKeyEvent,
      child: SizedBox(
        width: 56,
        height: 64,
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: hasError ? const Color(0xFFDC2626) : const Color(0xFF1A1A2E),
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: focusNode.hasFocus
                ? const Color(0xFFFFF7ED)
                : const Color(0xFFFFFFFF),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError
                    ? const Color(0xFFDC2626)
                    : controller.text.isNotEmpty
                    ? Colors.deepOrange
                    : const Color(0xFFE5E7EB),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: hasError ? const Color(0xFFDC2626) : Colors.deepOrange,
                width: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

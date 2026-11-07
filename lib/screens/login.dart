import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../i18n.dart';
import '../widgets.dart';
import 'verify.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  final _otp = TextEditingController();
  bool _otpStep = false;
  int _secs = 0;
  Timer? _timer;

  bool get _phoneOk => RegExp(r'^[6-9]\d{9}$').hasMatch(_phone.text);
  bool get _otpOk => _otp.text.length == 6;

  @override
  void initState() {
    super.initState();
    _phone.addListener(() => setState(() {}));
    _otp.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phone.dispose();
    _otp.dispose();
    super.dispose();
  }

  void _sendOtp() {
    setState(() {
      _otpStep = true;
      _secs = 30;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_secs <= 1) t.cancel();
      setState(() => _secs = _secs > 0 ? _secs - 1 : 0);
    });
  }

  void _goVerify() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const VerifyScreen()),
    );
  }

  Widget _social(IconData icon, String name) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: _goVerify,
        icon: Icon(icon, size: 22),
        label: Text(name),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          foregroundColor: context.ink,
          side: BorderSide(color: context.line),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LangBuilder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_otpStep) {
                setState(() => _otpStep = false);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${tr('hello')} 🙏',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: context.ink,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _otpStep
                      ? 'Enter the 6-digit code sent to +91 ${_phone.text}'
                      : 'Log in or sign up with your mobile number.',
                  style: TextStyle(color: context.sub, height: 1.5),
                ),
                const SizedBox(height: 28),
                if (!_otpStep) ...[
                  TextField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(fontSize: 18, letterSpacing: 1.5),
                    decoration: InputDecoration(
                      counterText: '',
                      labelText: tr('phone'),
                      prefixText: '+91  ',
                    ),
                  ),
                  const SizedBox(height: 20),
                  GradientButton(
                    label: tr('send_otp'),
                    onTap: _phoneOk ? _sendOtp : null,
                  ),
                ] else ...[
                  TextField(
                    controller: _otp,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(fontSize: 26, letterSpacing: 12),
                    decoration: const InputDecoration(counterText: ''),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _secs == 0 ? _sendOtp : null,
                      child: Text(_secs == 0 ? 'Resend OTP' : 'Resend in ${_secs}s'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GradientButton(
                    label: tr('verify_otp'),
                    onTap: _otpOk ? _goVerify : null,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Demo build: any 6-digit code works. Production sends a real SMS OTP '
                    'through your SMS gateway (MSG91 / Twilio) with rate limiting.',
                    style: TextStyle(color: context.sub, fontSize: 12, height: 1.5),
                  ),
                ],
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(child: Divider(color: context.line)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or continue with',
                          style: TextStyle(color: context.sub, fontSize: 12)),
                    ),
                    Expanded(child: Divider(color: context.line)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _social(Icons.g_mobiledata, 'Google'),
                    const SizedBox(width: 10),
                    _social(Icons.apple, 'Apple'),
                    const SizedBox(width: 10),
                    _social(Icons.facebook, 'Facebook'),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'By continuing you confirm you are 18+ and agree to our Terms and Privacy Policy.',
                  style: TextStyle(color: context.sub, fontSize: 11, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

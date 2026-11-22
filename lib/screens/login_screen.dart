import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api_service.dart';
import '../biometric_service.dart';
import '../ui_kit.dart';
import 'workspace_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final ApiService _apiService = ApiService();
  final BiometricService _biometricService = BiometricService.instance;
  final TextEditingController _emailCtrl = TextEditingController(
    text: 'customer@mdpay.mn',
  );
  final TextEditingController _passCtrl = TextEditingController(
    text: 'Demo1234!',
  );

  bool _isLoginMode = true;
  bool _obscureText = true;
  bool _biometricReady = false;

  @override
  void initState() {
    super.initState();
    _initBiometrics();
  }

  Future<void> _initBiometrics() async {
    await _biometricService.init();
    if (!mounted) return;
    setState(() {
      _biometricReady = _biometricService.biometricLoginEnabled &&
          (_biometricService.savedEmail?.isNotEmpty ?? false);
      if (_biometricReady && _biometricService.savedEmail != null) {
        _emailCtrl.text = _biometricService.savedEmail!;
      }
    });
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitAuth() async {
    final email = _emailCtrl.text.trim();
    final res = await _apiService.sendRequest('login', {
      'email': email,
      'password': _passCtrl.text.trim(),
    });

    if (!mounted) return;

    if (res['status'] == 'success') {
      HapticFeedback.lightImpact();
      await _biometricService.setLastSignedInEmail(email);
      if (!mounted) return;
      final user = Map<String, dynamic>.from(res['user'] as Map);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainWorkspaceScreen(userData: user),
        ),
      );
    } else {
      MdpFeedback.showError(
        context,
        res['message']?.toString() ?? 'Нэвтрэхэд алдаа гарлаа',
        onRetry: _submitAuth,
      );
    }
  }

  Future<void> _submitBiometricLogin() async {
    final targetEmail = _biometricService.savedEmail ?? _emailCtrl.text.trim();
    if (targetEmail.isEmpty) {
      MdpFeedback.showError(
        context,
        'Биометрикээр нэвтрэх бүртгэлтэй имэйл олдсонгүй.',
      );
      return;
    }

    final authorized = await _biometricService.authorizeAction(
      context,
      reason: 'MDPay данс руугаа нэвтрэхийн тулд хурууны хээ эсвэл Face ID ашиглана уу',
      title: 'Биометрик нэвтрэлт',
    );
    if (!mounted || !authorized) return;

    final res = await _apiService.sendRequest('login', {
      'email': targetEmail,
      'password': 'BIOMETRIC_VERIFIED',
    });

    if (!mounted) return;
    if (res['status'] == 'success') {
      HapticFeedback.lightImpact();
      final user = Map<String, dynamic>.from(res['user'] as Map);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainWorkspaceScreen(userData: user),
        ),
      );
    } else {
      MdpFeedback.showError(
        context,
        res['message']?.toString() ?? 'Биометрик нэвтрэлт амжилтгүй боллоо',
        onRetry: _submitBiometricLogin,
      );
    }
  }

  void _fillDemo(String email) {
    HapticFeedback.lightImpact();
    setState(() {
      _emailCtrl.text = email;
      _passCtrl.text = 'Demo1234!';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MdpTheme.canvas,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF131836),
                          Color(0xFF1F275C),
                          Color(0xFF101324),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: MdpTheme.hairlineStrong),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: MdpTheme.primary.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color:
                                      MdpTheme.primary.withValues(alpha: 0.45),
                                ),
                              ),
                              child: const Icon(
                                Icons.qr_code_2_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'MDpay',
                              style: TextStyle(
                                color: MdpTheme.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Санхүүгээ ухаалгаар\nудирд.',
                          style: TextStyle(
                            color: MdpTheme.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.18,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Төлбөр, нэхэмжлэл, QR шилжүүлэг — бүгд нэг системд.',
                          style: TextStyle(
                            color: MdpTheme.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  MdpCard(
                    padding: const EdgeInsets.all(22),
                    borderRadius: 26,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Тавтай морил!',
                          style: TextStyle(
                            color: MdpTheme.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Өөрийн бүртгэлээр нэвтэрч, дансаа удирдаарай.',
                          style: TextStyle(
                            color: MdpTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 18),
                        MdpSegmentedBar<bool>(
                          value: _isLoginMode,
                          items: const [
                            (id: true, label: 'Нэвтрэх'),
                            (id: false, label: 'Бүртгүүлэх'),
                          ],
                          onChanged: (val) =>
                              setState(() => _isLoginMode = val),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'И-мэйл хаяг',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _passCtrl,
                          obscureText: _obscureText,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _submitAuth(),
                          decoration: InputDecoration(
                            labelText: 'Нууц үг',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              onPressed: () =>
                                  setState(() => _obscureText = !_obscureText),
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        MdpLoadingButton(
                          label: _isLoginMode ? 'Нэвтрэх' : 'Бүртгүүлэх',
                          loadingLabel: _isLoginMode
                              ? 'Нэвтэрч байна...'
                              : 'Бүртгэж байна...',
                          icon: Icons.arrow_forward_rounded,
                          onPressed: _submitAuth,
                        ),
                        if (_isLoginMode && _biometricReady) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: _submitBiometricLogin,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: MdpTheme.textPrimary,
                                backgroundColor: MdpTheme.surfaceElevated,
                                side: BorderSide(
                                  color:
                                      MdpTheme.primary.withValues(alpha: 0.45),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(
                                Icons.fingerprint_rounded,
                                color: MdpTheme.primary,
                                size: 22,
                              ),
                              label: const Text(
                                'Биометрикээр нэвтрэх',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        Divider(color: MdpTheme.hairline, height: 1),
                        const SizedBox(height: 14),
                        const Text(
                          'Демо эрхээр турших (дарж бөглөнө):',
                          style: TextStyle(
                            color: MdpTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _DemoAccountChip(
                              icon: Icons.storefront_outlined,
                              label: 'merchant@mdpay.mn',
                              onTap: () => _fillDemo('merchant@mdpay.mn'),
                            ),
                            _DemoAccountChip(
                              icon: Icons.person_outline_rounded,
                              label: 'customer@mdpay.mn',
                              onTap: () => _fillDemo('customer@mdpay.mn'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DemoAccountChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DemoAccountChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: MdpTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MdpTheme.hairline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: MdpTheme.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: MdpTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api_service.dart';
import '../biometric_service.dart';
import '../ui_kit.dart';
import 'login_screen.dart';
import 'workspace_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();

  void _navigateToLogin() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, _, _) => const LoginScreen(),
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  Future<void> _enterDemoWorkspace() async {
    const demoEmail = 'customer@mdpay.mn';
    final res = await _apiService.sendRequest('login', {
      'email': demoEmail,
      'password': 'Demo1234!',
    });

    if (!mounted) return;

    if (res['status'] == 'success') {
      HapticFeedback.lightImpact();
      await BiometricService.instance.setLastSignedInEmail(demoEmail);
      if (!mounted) return;
      final user = Map<String, dynamic>.from(res['user'] as Map);
      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (_, _, _) => MainWorkspaceScreen(userData: user),
          transitionsBuilder: (_, animation, _, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else {
      MdpFeedback.showError(
        context,
        res['message']?.toString() ?? 'Демо эрхээр нэвтрэхэд алдаа гарлаа',
        onRetry: _enterDemoWorkspace,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MdpTheme.canvas,
      appBar: AppBar(
        backgroundColor: MdpTheme.canvas,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [MdpTheme.primaryDeep, MdpTheme.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.qr_code_2_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'MDpay',
              style: TextStyle(
                color: MdpTheme.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 20,
                letterSpacing: -0.4,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: _navigateToLogin,
              style: TextButton.styleFrom(
                foregroundColor: MdpTheme.textPrimary,
                backgroundColor: MdpTheme.surfaceElevated,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: MdpTheme.hairlineStrong),
                ),
              ),
              icon: const Icon(Icons.login_rounded, size: 16),
              label: const Text(
                'Нэвтрэх',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroCard(),
                  const SizedBox(height: 20),
                  MdpLoadingButton(
                    label: 'Эхлэх / Нэвтрэх  →',
                    loadingLabel: 'Шилжиж байна...',
                    onPressed: () async => _navigateToLogin(),
                  ),
                  const SizedBox(height: 12),
                  _DemoPreviewButton(onPressed: _enterDemoWorkspace),
                  const SizedBox(height: 28),
                  const Text(
                    'Боломжууд',
                    style: TextStyle(
                      color: MdpTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Өдөр тутмын болон бизнесийн төлбөрийг нэг дороос',
                    style: TextStyle(
                      color: MdpTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _FeatureCard(
                    icon: Icons.qr_code_scanner_rounded,
                    accent: MdpTheme.primary,
                    title: 'Dynamic & QuickPay QR төлбөр',
                    description:
                        'Үнийн дүнтэй болон дүнгүй QR код хормын дотор үүсгэж, уншуулж төлбөр хүлээн авна.',
                  ),
                  const SizedBox(height: 10),
                  const _FeatureCard(
                    icon: Icons.forward_to_inbox_rounded,
                    accent: MdpTheme.amber,
                    title: 'Имэйл нэхэмжлэл',
                    description:
                        'Харилцагч руу имэйл хаягаар нэхэмжлэл илгээж, төлбөрийн төлөвийг бодит цагаар хянана.',
                  ),
                  const SizedBox(height: 10),
                  const _FeatureCard(
                    icon: Icons.swap_horiz_rounded,
                    accent: MdpTheme.emerald,
                    title: 'Шуурхай шилжүүлэг ба хуулга',
                    description:
                        'MDPay хэрэглэгч хооронд шууд шилжүүлэг хийж, нарийвчилсан цахим баримт, хуулга шалгана.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0D1238),
            Color(0xFF28308A),
            MdpTheme.primaryDeep,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: MdpTheme.primary.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: MdpTheme.primaryDeep.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Төлбөр бүрийг илүү хялбар болгоё.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w800,
              height: 1.18,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Dynamic QR, нэхэмжлэл болон шууд шилжүүлгийг биометрик хамгаалалттайгаар хурдан гүйцэтгэнэ.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          // Утасны дэлгэц дээрх QR төлбөрийн жижиг визүал карт
          Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0B0F24).withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.14),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.qr_code_2_rounded,
                        size: 52,
                        color: Color(0xFF0D1238),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'MDpay QR Төлбөр',
                              style: TextStyle(
                                color: MdpTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    MdpTheme.emerald.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Text(
                                'Хурдан',
                                style: TextStyle(
                                  color: MdpTheme.emerald,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '125,000 ₮',
                          style: MdpTheme.tabularNumber.copyWith(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Шууд уншуулаад төлөхөд бэлэн',
                          style: TextStyle(
                            color: MdpTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoPreviewButton extends StatefulWidget {
  final Future<void> Function() onPressed;

  const _DemoPreviewButton({required this.onPressed});

  @override
  State<_DemoPreviewButton> createState() => _DemoPreviewButtonState();
}

class _DemoPreviewButtonState extends State<_DemoPreviewButton> {
  bool _busy = false;

  Future<void> _tap() async {
    if (_busy) return;
    HapticFeedback.lightImpact();
    setState(() => _busy = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: _busy ? null : _tap,
        style: OutlinedButton.styleFrom(
          foregroundColor: MdpTheme.textPrimary,
          backgroundColor: MdpTheme.surface,
          side: BorderSide(color: MdpTheme.hairlineStrong),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _busy
              ? const Row(
                  key: ValueKey('demo-busy'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: MdpTheme.primary,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Демо эрх нээж байна...',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : const Row(
                  key: ValueKey('demo-idle'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_circle_outline_rounded,
                      size: 19,
                      color: MdpTheme.emerald,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Демо эрхээр шууд үзэх',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final String description;

  const _FeatureCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return MdpCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: MdpTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: MdpTheme.textSecondary,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../biometric_service.dart';
import '../ui_kit.dart';

Future<void> showSettingsSheet(
  BuildContext context, {
  required Map<String, dynamic> currentUser,
  required VoidCallback onSecurityChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: MdpTheme.surface,
    builder: (_) => _SettingsSheetContent(
      currentUser: currentUser,
      onSecurityChanged: onSecurityChanged,
    ),
  );
}

class _SettingsSheetContent extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final VoidCallback onSecurityChanged;

  const _SettingsSheetContent({
    required this.currentUser,
    required this.onSecurityChanged,
  });

  @override
  State<_SettingsSheetContent> createState() => _SettingsSheetContentState();
}

class _SettingsSheetContentState extends State<_SettingsSheetContent> {
  final BiometricService _biometricService = BiometricService.instance;
  BiometricSupportInfo? _supportInfo;
  bool _checkingHardware = true;
  bool _togglingLogin = false;

  @override
  void initState() {
    super.initState();
    _loadHardwareInfo();
  }

  Future<void> _loadHardwareInfo() async {
    await _biometricService.init();
    final info = await _biometricService.checkSupport();
    if (!mounted) return;
    setState(() {
      _supportInfo = info;
      _checkingHardware = false;
    });
  }

  Future<void> _toggleBiometricLogin(bool nextValue) async {
    if (_togglingLogin) return;
    HapticFeedback.lightImpact();

    if (!nextValue) {
      await _biometricService.setBiometricLoginEnabled(false);
      if (!mounted) return;
      setState(() {});
      widget.onSecurityChanged();
      MdpFeedback.showInfo(context, 'Биометрик нэвтрэлт унтраалаа.');
      return;
    }

    setState(() => _togglingLogin = true);
    final authorized = await _biometricService.authorizeAction(
      context,
      reason: 'Биометрик нэвтрэлтийг идэвхжүүлэхийн тулд баталгаажуулна уу',
      title: 'Биометрик нэвтрэлт идэвхжүүлэх',
    );
    if (!mounted) return;
    setState(() => _togglingLogin = false);

    if (authorized) {
      await _biometricService.setBiometricLoginEnabled(
        true,
        activeEmail: widget.currentUser['email']?.toString(),
      );
      if (!mounted) return;
      setState(() {});
      widget.onSecurityChanged();
      MdpFeedback.showSuccess(
        context,
        'Биометрик нэвтрэлт амжилттай идэвхжлээ!',
      );
    }
  }

  Future<void> _toggleBalanceProtection(bool nextValue) async {
    HapticFeedback.lightImpact();
    if (!nextValue) {
      final authorized = await _biometricService.authorizeAction(
        context,
        reason: 'Үлдэгдлийн хамгаалалтыг унтраахын тулд баталгаажуулна уу',
        title: 'Хамгаалалт өөрчлөх',
      );
      if (!mounted || !authorized) return;
    }
    await _biometricService.setProtectBalanceEnabled(nextValue);
    if (!mounted) return;
    setState(() {});
    widget.onSecurityChanged();
  }

  Future<void> _togglePaymentProtection(bool nextValue) async {
    HapticFeedback.lightImpact();
    if (!nextValue) {
      final authorized = await _biometricService.authorizeAction(
        context,
        reason: 'Төлбөрийн хамгаалалтыг унтраахын тулд баталгаажуулна уу',
        title: 'Хамгаалалт өөрчлөх',
      );
      if (!mounted || !authorized) return;
    }
    await _biometricService.setProtectPaymentEnabled(nextValue);
    if (!mounted) return;
    setState(() {});
    widget.onSecurityChanged();
  }

  Future<void> _testBiometrics() async {
    final ok = await _biometricService.authorizeAction(
      context,
      reason: 'Хурууны хээ болон Face ID таних шалгалт',
      title: 'Биометрик шалгалт',
    );
    if (!mounted) return;
    if (ok) {
      MdpFeedback.showSuccess(context, 'Биометрик баталгаажуулалт амжилттай!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.currentUser['name']?.toString() ?? 'Хэрэглэгч';
    final userEmail = widget.currentUser['email']?.toString() ?? '';
    final walletId = widget.currentUser['wallet_id']?.toString() ?? '';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Тохиргоо',
                    style: TextStyle(
                      color: MdpTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.close_rounded,
                    color: MdpTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            MdpCard(
              backgroundColor: MdpTheme.surfaceElevated,
              padding: const EdgeInsets.all(14),
              borderRadius: 18,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: MdpTheme.primary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: MdpTheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: MdpTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$userEmail · $walletId',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: MdpTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Аюулгүй байдал ба Биометрик',
              style: TextStyle(
                color: MdpTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            MdpCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              borderRadius: 20,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(
                          (_supportInfo?.hasFaceId ?? false)
                              ? Icons.face_rounded
                              : Icons.fingerprint_rounded,
                          color: (_supportInfo?.hasAnyAuth ?? false)
                              ? MdpTheme.emerald
                              : MdpTheme.amber,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _checkingHardware
                                ? 'Төхөөрөмжийн биометрик шалгаж байна...'
                                : (_supportInfo?.summaryLabel ??
                                    'Төхөөрөмж шалгагдлаа'),
                            style: const TextStyle(
                              color: MdpTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: MdpTheme.hairline, height: 1),
                  _SettingsSwitchTile(
                    icon: Icons.fingerprint_rounded,
                    iconColor: MdpTheme.primary,
                    title: 'Биометрик нэвтрэлт',
                    subtitle: 'Хурууны хээ болон Face ID ашиглан нэвтрэх',
                    value: _biometricService.biometricLoginEnabled,
                    onChanged: _togglingLogin ? null : _toggleBiometricLogin,
                  ),
                  Divider(color: MdpTheme.hairline, height: 1),
                  _SettingsSwitchTile(
                    icon: Icons.visibility_off_outlined,
                    iconColor: MdpTheme.emerald,
                    title: 'Үлдэгдэл харах хамгаалалт',
                    subtitle: 'Нуусан үлдэгдлийг ил гаргахад Face ID / хурууны хээ шаардана',
                    value: _biometricService.protectBalanceEnabled,
                    onChanged: _toggleBalanceProtection,
                  ),
                  Divider(color: MdpTheme.hairline, height: 1),
                  _SettingsSwitchTile(
                    icon: Icons.verified_user_outlined,
                    iconColor: MdpTheme.amber,
                    title: 'Төлбөрийн баталгаажуулалт',
                    subtitle: 'QR төлбөр болон шилжүүлэг хийхэд биометрик шаардана',
                    value: _biometricService.protectPaymentEnabled,
                    onChanged: _togglePaymentProtection,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            MdpLoadingButton(
              label: 'Биометрик баталгаажуулалт турших',
              loadingLabel: 'Шалгаж байна...',
              icon: Icons.security_rounded,
              onPressed: _testBiometrics,
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: MdpTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: MdpTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            activeTrackColor: MdpTheme.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

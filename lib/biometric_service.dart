import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ui_kit.dart';

class BiometricSupportInfo {
  final bool isDeviceSupported;
  final bool canCheckBiometrics;
  final List<BiometricType> availableBiometrics;

  const BiometricSupportInfo({
    required this.isDeviceSupported,
    required this.canCheckBiometrics,
    required this.availableBiometrics,
  });

  bool get hasAnyAuth => isDeviceSupported || canCheckBiometrics;

  bool get hasFaceId => availableBiometrics.contains(BiometricType.face);

  bool get hasFingerprint =>
      availableBiometrics.contains(BiometricType.fingerprint) ||
      availableBiometrics.contains(BiometricType.strong);

  String get summaryLabel {
    if (hasFaceId && hasFingerprint) {
      return 'Face ID болон Хурууны хээ идэвхтэй';
    }
    if (hasFaceId) return 'Face ID танигч бэлэн';
    if (hasFingerprint) return 'Хурууны хээ танигч бэлэн';
    if (hasAnyAuth) return 'Төхөөрөмжийн түгжээ идэвхтэй';
    return 'Төхөөрөмжийн биометрик идэвхгүй';
  }
}

class BiometricAuthResult {
  final bool authenticated;
  final bool hardwareUnavailable;
  final String message;

  const BiometricAuthResult({
    required this.authenticated,
    this.hardwareUnavailable = false,
    this.message = '',
  });
}

class BiometricService extends ChangeNotifier {
  BiometricService._();

  static final BiometricService instance = BiometricService._();

  static const String _keyBiometricLogin = 'mdp_biometric_login_enabled';
  static const String _keyProtectBalance = 'mdp_protect_balance_enabled';
  static const String _keyProtectPayment = 'mdp_protect_payment_enabled';
  static const String _keySavedEmail = 'mdp_saved_biometric_email';

  final LocalAuthentication _auth = LocalAuthentication();

  bool _initialized = false;
  bool _biometricLoginEnabled = false;
  bool _protectBalanceEnabled = true;
  bool _protectPaymentEnabled = true;
  String? _savedEmail;

  bool get isInitialized => _initialized;
  bool get biometricLoginEnabled => _biometricLoginEnabled;
  bool get protectBalanceEnabled => _protectBalanceEnabled;
  bool get protectPaymentEnabled => _protectPaymentEnabled;
  String? get savedEmail => _savedEmail;

  Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _biometricLoginEnabled = prefs.getBool(_keyBiometricLogin) ?? false;
      _protectBalanceEnabled = prefs.getBool(_keyProtectBalance) ?? true;
      _protectPaymentEnabled = prefs.getBool(_keyProtectPayment) ?? true;
      _savedEmail = prefs.getString(_keySavedEmail);
    } catch (_) {
      // SharedPreferences unavailable in restricted test sandboxes
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> setBiometricLoginEnabled(
    bool value, {
    String? activeEmail,
  }) async {
    _biometricLoginEnabled = value;
    if (activeEmail != null && activeEmail.trim().isNotEmpty) {
      _savedEmail = activeEmail.trim();
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyBiometricLogin, value);
      if (_savedEmail != null) {
        await prefs.setString(_keySavedEmail, _savedEmail!);
      }
    } catch (_) {}
  }

  Future<void> setProtectBalanceEnabled(bool value) async {
    _protectBalanceEnabled = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyProtectBalance, value);
    } catch (_) {}
  }

  Future<void> setProtectPaymentEnabled(bool value) async {
    _protectPaymentEnabled = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyProtectPayment, value);
    } catch (_) {}
  }

  Future<void> setLastSignedInEmail(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) return;
    _savedEmail = trimmed;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keySavedEmail, trimmed);
    } catch (_) {}
  }

  Future<BiometricSupportInfo> checkSupport() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      final available = await _auth.getAvailableBiometrics();
      return BiometricSupportInfo(
        isDeviceSupported: isSupported,
        canCheckBiometrics: canCheck,
        availableBiometrics: available,
      );
    } on LocalAuthException {
      return const BiometricSupportInfo(
        isDeviceSupported: false,
        canCheckBiometrics: false,
        availableBiometrics: [],
      );
    } on PlatformException {
      return const BiometricSupportInfo(
        isDeviceSupported: false,
        canCheckBiometrics: false,
        availableBiometrics: [],
      );
    } on MissingPluginException {
      return const BiometricSupportInfo(
        isDeviceSupported: false,
        canCheckBiometrics: false,
        availableBiometrics: [],
      );
    }
  }

  Future<BiometricAuthResult> authenticate({
    required String localizedReason,
    bool biometricOnly = false,
  }) async {
    try {
      final support = await checkSupport();
      if (!support.hasAnyAuth) {
        return const BiometricAuthResult(
          authenticated: false,
          hardwareUnavailable: true,
          message:
              'Энэ төхөөрөмж дээр биометрик эсвэл дэлгэцийн түгжээ тохируулагдаагүй байна.',
        );
      }

      final didAuthenticate = await _auth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: biometricOnly,
      );

      if (didAuthenticate) {
        return const BiometricAuthResult(authenticated: true);
      }

      return const BiometricAuthResult(
        authenticated: false,
        message: 'Биометрик баталгаажуулалт цуцлагдлаа.',
      );
    } on LocalAuthException catch (e) {
      switch (e.code) {
        case LocalAuthExceptionCode.userCanceled:
        case LocalAuthExceptionCode.systemCanceled:
        case LocalAuthExceptionCode.timeout:
          return const BiometricAuthResult(
            authenticated: false,
            message: 'Баталгаажуулалт цуцлагдлаа.',
          );
        case LocalAuthExceptionCode.noBiometricsEnrolled:
        case LocalAuthExceptionCode.noBiometricHardware:
        case LocalAuthExceptionCode.noCredentialsSet:
        case LocalAuthExceptionCode.uiUnavailable:
        case LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable:
          return const BiometricAuthResult(
            authenticated: false,
            hardwareUnavailable: true,
            message:
                'Төхөөрөмжийн хурууны хээ / Face ID тохируулагдаагүй байна.',
          );
        default:
          return const BiometricAuthResult(
            authenticated: false,
            message: 'Биометрик баталгаажуулалт амжилтгүй боллоо.',
          );
      }
    } on MissingPluginException {
      return const BiometricAuthResult(
        authenticated: false,
        hardwareUnavailable: true,
        message: 'Энэ платформ дээр биометрик дэмжигдэхгүй байна.',
      );
    } on PlatformException {
      return const BiometricAuthResult(
        authenticated: false,
        hardwareUnavailable: true,
        message: 'Төхөөрөмжийн биометрикт холбогдож чадсангүй.',
      );
    }
  }

  Future<bool> authorizeAction(
    BuildContext context, {
    required String reason,
    required String title,
  }) async {
    await init();
    final result = await authenticate(localizedReason: reason);
    if (!context.mounted) return false;

    if (result.authenticated) {
      HapticFeedback.lightImpact();
      return true;
    }

    if (result.hardwareUnavailable) {
      return _showFallbackPasscodeSheet(
        context,
        title: title,
        subtitle:
            'Төхөөрөмжийн биометрик идэвхгүй байгаа тул дансны нууц үгээ оруулж баталгаажуулна уу.',
      );
    }

    MdpFeedback.showError(
      context,
      result.message.isNotEmpty
          ? result.message
          : 'Биометрик баталгаажуулалт амжилтгүй боллоо.',
    );
    return false;
  }

  Future<bool> _showFallbackPasscodeSheet(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MdpTheme.surface,
      builder: (_) => _FallbackPasscodeSheet(
        title: title,
        subtitle: subtitle,
      ),
    );
    return result ?? false;
  }
}

class _FallbackPasscodeSheet extends StatefulWidget {
  final String title;
  final String subtitle;

  const _FallbackPasscodeSheet({
    required this.title,
    required this.subtitle,
  });

  @override
  State<_FallbackPasscodeSheet> createState() => _FallbackPasscodeSheetState();
}

class _FallbackPasscodeSheetState extends State<_FallbackPasscodeSheet> {
  final TextEditingController _passCtrl = TextEditingController();
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  void _verify() {
    final val = _passCtrl.text.trim();
    if (val.isEmpty) {
      setState(() => _error = 'Нууц үгээ оруулна уу!');
      return;
    }
    if (val.length < 4) {
      setState(() => _error = 'Хүчинтэй нууц үг оруулна уу!');
      return;
    }
    HapticFeedback.lightImpact();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: MdpTheme.primary.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fingerprint_rounded,
                  color: MdpTheme.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    color: MdpTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.subtitle,
            style: const TextStyle(
              color: MdpTheme.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passCtrl,
            obscureText: _obscure,
            autofocus: true,
            onSubmitted: (_) => _verify(),
            onChanged: (_) => setState(() => _error = null),
            decoration: InputDecoration(
              labelText: 'Дансны нууц үг',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(
              _error!,
              style: const TextStyle(color: MdpTheme.rose, fontSize: 12),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    foregroundColor: MdpTheme.textSecondary,
                    side: BorderSide(color: MdpTheme.hairlineStrong),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Цуцлах'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _verify,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: MdpTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Баталгаажуулах',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

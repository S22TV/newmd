import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../api_service.dart';
import '../currency_utils.dart';
import '../modals/payment_sheets.dart';
import '../ui_kit.dart';

class QrSystemTab extends StatefulWidget {
  final ApiService apiService;
  final double balance;
  final Future<void> Function() onRefresh;

  const QrSystemTab({
    super.key,
    required this.apiService,
    required this.balance,
    required this.onRefresh,
  });

  @override
  State<QrSystemTab> createState() => _QrSystemTabState();
}

class _QrSystemTabState extends State<QrSystemTab>
    with SingleTickerProviderStateMixin {
  String _qrType = 'DYNAMIC';
  final TextEditingController _qrAmountCtrl = TextEditingController(
    text: '125,000',
  );
  final TextEditingController _qrDescCtrl = TextEditingController(
    text: 'Бараа бүтээгдэхүүний төлбөр',
  );
  String _generatedQrCode = 'MDPAY_DYN_101_125000';
  String _generatedStatusLabel = 'Хүлээгдэж буй';

  late final AnimationController _scanAnimCtrl;

  @override
  void initState() {
    super.initState();
    _scanAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanAnimCtrl.dispose();
    _qrAmountCtrl.dispose();
    _qrDescCtrl.dispose();
    super.dispose();
  }

  Future<void> _generateQr() async {
    final rawAmount =
        _qrType == 'DYNAMIC' ? CurrencyUtils.stripDigits(_qrAmountCtrl.text) : '0';

    final res = await widget.apiService.sendRequest('generate_qr', {
      'qr_type': _qrType,
      'amount': rawAmount,
      'description': _qrDescCtrl.text.trim(),
    });

    if (!mounted) return;
    if (res['status'] == 'success') {
      HapticFeedback.lightImpact();
      setState(() {
        _generatedQrCode = res['qr_code'].toString();
        _generatedStatusLabel = 'Хүлээгдэж буй';
      });
      MdpFeedback.showSuccess(context, 'QR Код амжилттай үүслээ!');
    } else {
      MdpFeedback.showError(
        context,
        res['message']?.toString() ?? 'QR үүсгэхэд алдаа гарлаа',
        onRetry: _generateQr,
      );
    }
  }

  void _copyQrCode() {
    HapticFeedback.lightImpact();
    Clipboard.setData(ClipboardData(text: _generatedQrCode));
    MdpFeedback.showInfo(context, 'QR код хуулагдлаа: $_generatedQrCode');
  }

  void _shareQrSummary() {
    HapticFeedback.lightImpact();
    final amountText = _qrType == 'DYNAMIC'
        ? CurrencyUtils.formatDynamic(_qrAmountCtrl.text)
        : 'Нээлттэй дүн (QuickPay)';
    final shareText =
        'MDPay Төлбөрийн QR\nКод: $_generatedQrCode\nДүн: $amountText\nУтга: ${_qrDescCtrl.text.trim()}';
    Clipboard.setData(ClipboardData(text: shareText));
    MdpFeedback.showSuccess(
      context,
      'Төлбөрийн мэдээлэл хуваалцахад бэлэн хуулагдлаа!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final parsedAmount = CurrencyUtils.parseMnt(_qrAmountCtrl.text);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
      children: [
        const Text(
          'QR Төлбөр ба Уншигч',
          style: TextStyle(
            color: MdpTheme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Dynamic QR (үнийн дүнтэй) болон QuickPay (үнийн дүнгүй) төлбөр.',
          style: TextStyle(color: MdpTheme.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF0E1328),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: MdpTheme.primary.withValues(alpha: 0.28),
            ),
          ),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner_rounded,
                    color: MdpTheme.primary,
                    size: 19,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'MDPay Камерын QR Уншигч',
                    style: TextStyle(
                      color: MdpTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 6,
                  width: double.infinity,
                  child: AnimatedBuilder(
                    animation: _scanAnimCtrl,
                    builder: (context, _) {
                      return LinearProgressIndicator(
                        value: _scanAnimCtrl.value,
                        color: MdpTheme.emerald,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: MdpTheme.primary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        showPaymentConfirmSheet(
                          context,
                          apiService: widget.apiService,
                          availableBalance: widget.balance,
                          qrCode: _generatedQrCode,
                          qrType: 'DYNAMIC',
                          presetAmount: parsedAmount > 0 ? parsedAmount : 125000,
                          description: _qrDescCtrl.text.trim().isEmpty
                              ? 'Бараа бүтээгдэхүүний төлбөр'
                              : _qrDescCtrl.text.trim(),
                          onSuccessRefresh: () async {
                            await widget.onRefresh();
                            if (mounted) {
                              setState(
                                () => _generatedStatusLabel = 'Төлөгдсөн',
                              );
                            }
                          },
                        );
                      },
                      icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                      label: const Text(
                        'Dynamic QR Унших',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: MdpTheme.emerald,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13),
                        ),
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        showPaymentConfirmSheet(
                          context,
                          apiService: widget.apiService,
                          availableBalance: widget.balance,
                          qrCode: 'MDPAY_QUICK_OPEN',
                          qrType: 'QUICK',
                          presetAmount: 0,
                          description: 'QuickPay Шууд Төлбөр',
                          onSuccessRefresh: widget.onRefresh,
                        );
                      },
                      icon: const Icon(Icons.flash_on_rounded, size: 18),
                      label: const Text(
                        'QuickPay Унших',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        MdpCard(
          padding: const EdgeInsets.all(20),
          borderRadius: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'API-аар QR Код Үүсгэх',
                style: TextStyle(
                  color: MdpTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Вэбсайт болон мерчант төлбөр хүлээн авах карт',
                style: TextStyle(color: MdpTheme.textSecondary, fontSize: 12),
              ),
              const SizedBox(height: 14),
              MdpSegmentedBar<String>(
                value: _qrType,
                items: const [
                  (id: 'DYNAMIC', label: 'Dynamic QR (Дүнтэй)'),
                  (id: 'QUICK', label: 'QuickPay (Дүнгүй)'),
                ],
                onChanged: (type) {
                  setState(() {
                    _qrType = type;
                    _generatedStatusLabel = 'Хүлээгдэж буй';
                    if (type == 'DYNAMIC' &&
                        CurrencyUtils.parseMnt(_qrAmountCtrl.text) <= 0) {
                      _qrAmountCtrl.text = '125,000';
                    }
                  });
                },
              ),
              const SizedBox(height: 14),
              if (_qrType == 'DYNAMIC') ...[
                TextField(
                  controller: _qrAmountCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [MntCurrencyInputFormatter()],
                  onChanged: (_) => setState(() {}),
                  style: MdpTheme.tabularNumber.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Үнийн дүн',
                    prefixIcon: Icon(Icons.payments_outlined),
                    suffixText: '₮',
                  ),
                ),
                const SizedBox(height: 10),
                MdpQuickAmountChips(
                  controller: _qrAmountCtrl,
                  onSelected: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),
              ],
              TextField(
                controller: _qrDescCtrl,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Гүйлгээний утга / Барааны нэр',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 16),
              MdpLoadingButton(
                label: 'Шинэ QR Код Үүсгэх',
                loadingLabel: 'QR үүсгэж байна...',
                icon: Icons.qr_code_rounded,
                onPressed: _generateQr,
              ),
              const SizedBox(height: 22),
              _PremiumQrCard(
                qrCode: _generatedQrCode,
                qrType: _qrType,
                amountText: _qrType == 'DYNAMIC'
                    ? CurrencyUtils.formatDynamic(_qrAmountCtrl.text)
                    : 'Дүн оруулж төлөх',
                description: _qrDescCtrl.text.trim(),
                statusLabel: _generatedStatusLabel,
                onCopy: _copyQrCode,
                onShare: _shareQrSummary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PremiumQrCard extends StatelessWidget {
  final String qrCode;
  final String qrType;
  final String amountText;
  final String description;
  final String statusLabel;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _PremiumQrCard({
    required this.qrCode,
    required this.qrType,
    required this.amountText,
    required this.description,
    required this.statusLabel,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isPaid = statusLabel == 'Төлөгдсөн';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF151B34),
            Color(0xFF1D2448),
            Color(0xFF111528),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: MdpTheme.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.qr_code_2_rounded,
                    color: MdpTheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'MDpay QR',
                    style: TextStyle(
                      color: MdpTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              isPaid ? MdpStatusBadge.paid() : MdpStatusBadge.pending(),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            amountText,
            style: MdpTheme.tabularNumber.copyWith(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: MdpTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: MdpTheme.primary.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: QrImageView(
              data: qrCode,
              version: QrVersions.auto,
              size: 168,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF0D1238),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF141830),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              qrCode,
              style: MdpTheme.tabularNumber.copyWith(
                color: MdpTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCopy,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: MdpTheme.textPrimary,
                    side: BorderSide(color: MdpTheme.hairlineStrong),
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text(
                    'Код хуулах',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onShare,
                  style: FilledButton.styleFrom(
                    backgroundColor: MdpTheme.surfaceElevated,
                    foregroundColor: MdpTheme.textPrimary,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: MdpTheme.hairlineStrong),
                    ),
                  ),
                  icon: const Icon(Icons.ios_share_rounded, size: 16),
                  label: const Text(
                    'Хуваалцах',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
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

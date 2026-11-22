import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api_service.dart';
import '../biometric_service.dart';
import '../currency_utils.dart';
import '../ui_kit.dart';

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const dashSpace = 5.0;
        final count = (constraints.maxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            count,
            (_) => Container(
              width: dashWidth,
              height: 1,
              color: MdpTheme.hairlineStrong,
            ),
          ),
        );
      },
    );
  }
}

Future<void> showDigitalReceiptSheet(
  BuildContext context, {
  required String title,
  required num amount,
  required String counterparty,
  required String date,
  required String method,
  required bool isIncome,
  String? referenceId,
}) {
  HapticFeedback.lightImpact();
  final formattedAmount = CurrencyUtils.formatMnt(amount);
  final signedAmount = '${isIncome ? '+' : '-'}$formattedAmount';
  final methodLabel = CurrencyUtils.formatMethodLabel(method);
  final refCode = referenceId ?? 'TX-${date.hashCode.abs()}';

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: MdpTheme.surface,
    builder: (sheetCtx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _SheetHandle(),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: (isIncome ? MdpTheme.emerald : MdpTheme.primary)
                      .withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: (isIncome ? MdpTheme.emerald : MdpTheme.primary)
                        .withValues(alpha: 0.35),
                  ),
                ),
                child: Icon(
                  isIncome ? Icons.south_west_rounded : Icons.check_rounded,
                  color: isIncome ? MdpTheme.emerald : MdpTheme.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 14),
              MdpStatusBadge.success(),
              const SizedBox(height: 12),
              Text(
                signedAmount,
                style: MdpTheme.tabularNumber.copyWith(
                  color: isIncome ? MdpTheme.emerald : MdpTheme.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: MdpTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),
              const _DashedDivider(),
              const SizedBox(height: 18),
              _ReceiptRow(label: 'Гүйлгээний дугаар', value: refCode),
              _ReceiptRow(label: 'Огноо', value: date),
              _ReceiptRow(label: 'Харилцагч / Код', value: counterparty),
              _ReceiptRow(label: 'Хэлбэр', value: methodLabel),
              _ReceiptRow(
                label: 'Төрөл',
                value: isIncome ? 'Орлого' : 'Зарлага',
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        final summary =
                            'MDPay Цахим баримт\nДугаар: $refCode\nДүн: $signedAmount\nУтга: $title\nХарилцагч: $counterparty\nХэлбэр: $methodLabel\nОгноо: $date';
                        Clipboard.setData(ClipboardData(text: summary));
                        Navigator.pop(sheetCtx);
                        MdpFeedback.showInfo(
                          context,
                          'Цахим баримтын мэдээлэл хуулагдлаа!',
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        foregroundColor: MdpTheme.textPrimary,
                        side: BorderSide(color: MdpTheme.hairlineStrong),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text('Баримт хуулах'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(sheetCtx),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: MdpTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Болсон',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReceiptRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: MdpTheme.textMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: MdpTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showPaymentConfirmSheet(
  BuildContext context, {
  required ApiService apiService,
  required double availableBalance,
  required String qrCode,
  required String qrType,
  required double presetAmount,
  required String description,
  int? invoiceId,
  required Future<void> Function() onSuccessRefresh,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: MdpTheme.surface,
    builder: (_) => _PaymentConfirmSheetContent(
      parentContext: context,
      apiService: apiService,
      availableBalance: availableBalance,
      qrCode: qrCode,
      qrType: qrType,
      presetAmount: presetAmount,
      description: description,
      invoiceId: invoiceId,
      onSuccessRefresh: onSuccessRefresh,
    ),
  );
}

class _PaymentConfirmSheetContent extends StatefulWidget {
  final BuildContext parentContext;
  final ApiService apiService;
  final double availableBalance;
  final String qrCode;
  final String qrType;
  final double presetAmount;
  final String description;
  final int? invoiceId;
  final Future<void> Function() onSuccessRefresh;

  const _PaymentConfirmSheetContent({
    required this.parentContext,
    required this.apiService,
    required this.availableBalance,
    required this.qrCode,
    required this.qrType,
    required this.presetAmount,
    required this.description,
    this.invoiceId,
    required this.onSuccessRefresh,
  });

  @override
  State<_PaymentConfirmSheetContent> createState() =>
      _PaymentConfirmSheetContentState();
}

class _PaymentConfirmSheetContentState
    extends State<_PaymentConfirmSheetContent> {
  late final TextEditingController _amountCtrl;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    _amountCtrl = TextEditingController(
      text: widget.qrType == 'DYNAMIC' && widget.presetAmount > 0
          ? CurrencyUtils.formatMnt(widget.presetAmount, withSymbol: false)
          : '',
    );
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitPayment() async {
    setState(() => _inlineError = null);
    final rawAmount = CurrencyUtils.stripDigits(_amountCtrl.text);
    final parsedAmount = CurrencyUtils.parseMnt(_amountCtrl.text);

    if (parsedAmount <= 0) {
      setState(() => _inlineError = 'Төлөх үнийн дүн 0-ээс их байх ёстой!');
      return;
    }

    if (BiometricService.instance.protectPaymentEnabled) {
      final authorized = await BiometricService.instance.authorizeAction(
        context,
        reason:
            'Төлбөрийг баталгаажуулахын тулд хурууны хээ эсвэл Face ID ашиглана уу',
        title: 'Төлбөр баталгаажуулах',
      );
      if (!mounted) return;
      if (!authorized) {
        setState(
          () => _inlineError =
              'Төлбөрийн биометрик баталгаажуулалт цуцлагдлаа.',
        );
        return;
      }
    }

    final res = await widget.apiService.sendRequest('pay_qr_or_invoice', {
      'amount': rawAmount,
      'description': widget.description,
      'counterparty': widget.qrCode,
      'method': widget.qrType,
      'invoice_id': widget.invoiceId,
    });

    if (!mounted) return;

    if (res['status'] == 'success') {
      await widget.onSuccessRefresh();
      if (!mounted) return;
      Navigator.pop(context);
      final tx = res['transaction'] as Map<String, dynamic>?;
      if (widget.parentContext.mounted) {
        await showDigitalReceiptSheet(
          widget.parentContext,
          title: widget.description,
          amount: parsedAmount,
          counterparty: widget.qrCode,
          date: tx?['date']?.toString() ?? 'Саяхан',
          method: widget.qrType,
          isIncome: false,
          referenceId: tx?['id'] != null ? 'TX-${tx!['id']}' : null,
        );
      }
    } else {
      setState(
        () => _inlineError =
            res['message']?.toString() ?? 'Төлбөр гүйцэтгэхэд алдаа гарлаа.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDynamic = widget.qrType == 'DYNAMIC';
    final enteredAmount = CurrencyUtils.parseMnt(_amountCtrl.text);
    final insufficient = enteredAmount > widget.availableBalance;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    isDynamic ? 'Dynamic QR Төлбөр' : 'QuickPay Шууд Төлбөр',
                    style: const TextStyle(
                      color: MdpTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                MdpStatusBadge(
                  label: isDynamic ? 'Дүн түгжигдсэн' : 'Нээлттэй дүн',
                  color: isDynamic ? MdpTheme.primary : MdpTheme.emerald,
                  icon: isDynamic ? Icons.lock_outline : Icons.flash_on_rounded,
                ),
              ],
            ),
            const SizedBox(height: 16),
            MdpCard(
              backgroundColor: MdpTheme.surfaceElevated,
              padding: const EdgeInsets.all(14),
              borderRadius: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.qr_code_2_rounded,
                        size: 18,
                        color: MdpTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.qrCode,
                          style: const TextStyle(
                            color: MdpTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: const TextStyle(
                      color: MdpTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Боломжит үлдэгдэл: ${CurrencyUtils.formatMnt(widget.availableBalance)}',
                    style: MdpTheme.tabularNumber.copyWith(
                      color: insufficient ? MdpTheme.rose : MdpTheme.emerald,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountCtrl,
              readOnly: isDynamic,
              keyboardType: TextInputType.number,
              inputFormatters: [MntCurrencyInputFormatter()],
              onChanged: (_) => setState(() => _inlineError = null),
              style: MdpTheme.tabularNumber.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: MdpTheme.textPrimary,
              ),
              decoration: InputDecoration(
                labelText: isDynamic
                    ? 'Төлөх дүн (API-аас ирсэн дүн)'
                    : 'Төлөх үнийн дүнгээ оруулна уу',
                prefixIcon: const Icon(Icons.payments_outlined),
                suffixText: '₮',
                suffixStyle: const TextStyle(
                  color: MdpTheme.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (!isDynamic) ...[
              const SizedBox(height: 12),
              MdpQuickAmountChips(
                controller: _amountCtrl,
                onSelected: (_) => setState(() => _inlineError = null),
              ),
            ],
            if (_inlineError != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: MdpTheme.rose.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: MdpTheme.rose.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: MdpTheme.rose,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _inlineError!,
                        style: const TextStyle(
                          color: MdpTheme.textPrimary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _submitPayment,
                      child: const Text(
                        'Дахин оролдох',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (BiometricService.instance.protectPaymentEnabled) ...[
              Row(
                children: const [
                  Icon(
                    Icons.fingerprint_rounded,
                    size: 16,
                    color: MdpTheme.emerald,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Хурууны хээ / Face ID баталгаажуулалт шаардана',
                      style: TextStyle(
                        color: MdpTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            MdpLoadingButton(
              label: 'Төлбөр баталгаажуулах',
              loadingLabel: 'Гүйлгээ хийгдэж байна...',
              icon: Icons.verified_user_outlined,
              onPressed: _submitPayment,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showTopUpSheet(
  BuildContext context, {
  required ApiService apiService,
  required Future<void> Function() onSuccessRefresh,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: MdpTheme.surface,
    builder: (_) => _TopUpSheetContent(
      parentContext: context,
      apiService: apiService,
      onSuccessRefresh: onSuccessRefresh,
    ),
  );
}

class _TopUpSheetContent extends StatefulWidget {
  final BuildContext parentContext;
  final ApiService apiService;
  final Future<void> Function() onSuccessRefresh;

  const _TopUpSheetContent({
    required this.parentContext,
    required this.apiService,
    required this.onSuccessRefresh,
  });

  @override
  State<_TopUpSheetContent> createState() => _TopUpSheetContentState();
}

class _TopUpSheetContentState extends State<_TopUpSheetContent> {
  final TextEditingController _amountCtrl = TextEditingController(
    text: '500,000',
  );
  String? _inlineError;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitTopUp() async {
    setState(() => _inlineError = null);
    final rawAmount = CurrencyUtils.stripDigits(_amountCtrl.text);
    final parsed = CurrencyUtils.parseMnt(_amountCtrl.text);
    if (parsed <= 0) {
      setState(() => _inlineError = 'Цэнэглэх дүнгээ оруулна уу!');
      return;
    }

    final res = await widget.apiService.sendRequest('top_up', {
      'amount': rawAmount,
    });

    if (!mounted) return;
    if (res['status'] == 'success') {
      await widget.onSuccessRefresh();
      if (!mounted) return;
      Navigator.pop(context);
      if (widget.parentContext.mounted) {
        MdpFeedback.showSuccess(
          widget.parentContext,
          'Данс ${CurrencyUtils.formatMnt(parsed)}-өөр амжилттай цэнэглэгдлээ!',
        );
      }
    } else {
      setState(
        () => _inlineError =
            res['message']?.toString() ?? 'Цэнэглэхэд алдаа гарлаа.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const Text(
              'Данс цэнэглэх',
              style: TextStyle(
                color: MdpTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Банкны API холболтоор MDPay хэтэвчээ шууд цэнэглэнэ.',
              style: TextStyle(color: MdpTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [MntCurrencyInputFormatter()],
              onChanged: (_) => setState(() => _inlineError = null),
              style: MdpTheme.tabularNumber.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                labelText: 'Цэнэглэх дүн',
                prefixIcon: Icon(Icons.add_card_rounded),
                suffixText: '₮',
              ),
            ),
            const SizedBox(height: 12),
            MdpQuickAmountChips(
              controller: _amountCtrl,
              amounts: const [10000, 50000, 100000, 500000],
              onSelected: (_) => setState(() => _inlineError = null),
            ),
            if (_inlineError != null) ...[
              const SizedBox(height: 12),
              Text(
                _inlineError!,
                style: const TextStyle(color: MdpTheme.rose, fontSize: 13),
              ),
            ],
            const SizedBox(height: 20),
            MdpLoadingButton(
              label: 'Данс цэнэглэх',
              loadingLabel: 'Цэнэглэж байна...',
              icon: Icons.account_balance_rounded,
              backgroundColor: MdpTheme.emerald,
              onPressed: _submitTopUp,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showDirectTransferSheet(
  BuildContext context, {
  required ApiService apiService,
  required double availableBalance,
  required Future<void> Function() onSuccessRefresh,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: MdpTheme.surface,
    builder: (_) => _DirectTransferSheetContent(
      parentContext: context,
      apiService: apiService,
      availableBalance: availableBalance,
      onSuccessRefresh: onSuccessRefresh,
    ),
  );
}

class _DirectTransferSheetContent extends StatefulWidget {
  final BuildContext parentContext;
  final ApiService apiService;
  final double availableBalance;
  final Future<void> Function() onSuccessRefresh;

  const _DirectTransferSheetContent({
    required this.parentContext,
    required this.apiService,
    required this.availableBalance,
    required this.onSuccessRefresh,
  });

  @override
  State<_DirectTransferSheetContent> createState() =>
      _DirectTransferSheetContentState();
}

class _DirectTransferSheetContentState
    extends State<_DirectTransferSheetContent> {
  final TextEditingController _receiverCtrl = TextEditingController(
    text: 'friend@mdpay.mn',
  );
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController(
    text: 'Мөнгөн шилжүүлэг',
  );
  String? _inlineError;

  @override
  void dispose() {
    _receiverCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitTransfer() async {
    setState(() => _inlineError = null);
    final receiver = _receiverCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final rawAmount = CurrencyUtils.stripDigits(_amountCtrl.text);
    final parsed = CurrencyUtils.parseMnt(_amountCtrl.text);

    if (receiver.isEmpty || parsed <= 0) {
      setState(
        () => _inlineError =
            'Хүлээн авагчийн имэйл болон шилжүүлэх дүнгээ оруулна уу!',
      );
      return;
    }

    if (BiometricService.instance.protectPaymentEnabled) {
      final authorized = await BiometricService.instance.authorizeAction(
        context,
        reason:
            'Мөнгөн шилжүүлгийг баталгаажуулахын тулд хурууны хээ эсвэл Face ID ашиглана уу',
        title: 'Шилжүүлэг баталгаажуулах',
      );
      if (!mounted) return;
      if (!authorized) {
        setState(
          () => _inlineError =
              'Шилжүүлгийн биометрик баталгаажуулалт цуцлагдлаа.',
        );
        return;
      }
    }

    final res = await widget.apiService.sendRequest('pay_qr_or_invoice', {
      'amount': rawAmount,
      'description': desc.isEmpty ? 'Мөнгөн шилжүүлэг' : desc,
      'counterparty': receiver,
      'method': 'TRANSFER',
    });

    if (!mounted) return;
    if (res['status'] == 'success') {
      await widget.onSuccessRefresh();
      if (!mounted) return;
      Navigator.pop(context);
      final tx = res['transaction'] as Map<String, dynamic>?;
      if (widget.parentContext.mounted) {
        await showDigitalReceiptSheet(
          widget.parentContext,
          title: desc.isEmpty ? 'Мөнгөн шилжүүлэг' : desc,
          amount: parsed,
          counterparty: receiver,
          date: tx?['date']?.toString() ?? 'Саяхан',
          method: 'TRANSFER',
          isIncome: false,
          referenceId: tx?['id'] != null ? 'TX-${tx!['id']}' : null,
        );
      }
    } else {
      setState(
        () => _inlineError =
            res['message']?.toString() ?? 'Шилжүүлэг амжилтгүй боллоо.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const Text(
              'Мөнгөн шилжүүлэг',
              style: TextStyle(
                color: MdpTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Боломжит үлдэгдэл: ${CurrencyUtils.formatMnt(widget.availableBalance)}',
              style: MdpTheme.tabularNumber.copyWith(
                color: MdpTheme.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _receiverCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Хүлээн авагчийн имэйл',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [MntCurrencyInputFormatter()],
              onChanged: (_) => setState(() => _inlineError = null),
              style: MdpTheme.tabularNumber.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                labelText: 'Шилжүүлэх дүн',
                prefixIcon: Icon(Icons.payments_outlined),
                suffixText: '₮',
              ),
            ),
            const SizedBox(height: 10),
            MdpQuickAmountChips(
              controller: _amountCtrl,
              onSelected: (_) => setState(() => _inlineError = null),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Гүйлгээний утга',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            if (_inlineError != null) ...[
              const SizedBox(height: 12),
              Text(
                _inlineError!,
                style: const TextStyle(color: MdpTheme.rose, fontSize: 13),
              ),
            ],
            const SizedBox(height: 16),
            if (BiometricService.instance.protectPaymentEnabled) ...[
              Row(
                children: const [
                  Icon(
                    Icons.fingerprint_rounded,
                    size: 16,
                    color: MdpTheme.emerald,
                  ),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Хурууны хээ / Face ID баталгаажуулалт шаардана',
                      style: TextStyle(
                        color: MdpTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            MdpLoadingButton(
              label: 'Шилжүүлэх',
              loadingLabel: 'Шилжүүлж байна...',
              icon: Icons.send_rounded,
              onPressed: _submitTransfer,
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> showCreateInvoiceSheet(
  BuildContext context, {
  required ApiService apiService,
  required String senderEmail,
  required Future<void> Function() onSuccessRefresh,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: MdpTheme.surface,
    builder: (_) => _CreateInvoiceSheetContent(
      parentContext: context,
      apiService: apiService,
      senderEmail: senderEmail,
      onSuccessRefresh: onSuccessRefresh,
    ),
  );
}

class _CreateInvoiceSheetContent extends StatefulWidget {
  final BuildContext parentContext;
  final ApiService apiService;
  final String senderEmail;
  final Future<void> Function() onSuccessRefresh;

  const _CreateInvoiceSheetContent({
    required this.parentContext,
    required this.apiService,
    required this.senderEmail,
    required this.onSuccessRefresh,
  });

  @override
  State<_CreateInvoiceSheetContent> createState() =>
      _CreateInvoiceSheetContentState();
}

class _CreateInvoiceSheetContentState
    extends State<_CreateInvoiceSheetContent> {
  final TextEditingController _emailCtrl = TextEditingController(
    text: 'customer@mdpay.mn',
  );
  final TextEditingController _amountCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  String? _inlineError;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitInvoice() async {
    setState(() => _inlineError = null);
    final rawAmount = CurrencyUtils.stripDigits(_amountCtrl.text);

    final res = await widget.apiService.sendRequest('create_invoice', {
      'sender_email': widget.senderEmail,
      'receiver_email': _emailCtrl.text.trim(),
      'amount': rawAmount,
      'description': _descCtrl.text.trim(),
    });

    if (!mounted) return;
    if (res['status'] == 'success') {
      await widget.onSuccessRefresh();
      if (!mounted) return;
      Navigator.pop(context);
      if (widget.parentContext.mounted) {
        MdpFeedback.showSuccess(
          widget.parentContext,
          res['message']?.toString() ?? 'Нэхэмжлэл амжилттай илгээгдлээ!',
        );
      }
    } else {
      setState(
        () => _inlineError =
            res['message']?.toString() ?? 'Нэхэмжлэл үүсгэхэд алдаа гарлаа.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetHandle(),
            const Text(
              'Имэйлээр нэхэмжлэл үүсгэх',
              style: TextStyle(
                color: MdpTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Хэрэглэгчийн имэйл рүү төлбөрийн нэхэмжлэл шууд илгээх.',
              style: TextStyle(color: MdpTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Төлөгчийн и-мэйл хаяг',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [MntCurrencyInputFormatter()],
              onChanged: (_) => setState(() => _inlineError = null),
              style: MdpTheme.tabularNumber.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              decoration: const InputDecoration(
                labelText: 'Нэхэмжлэх дүн',
                prefixIcon: Icon(Icons.payments_outlined),
                suffixText: '₮',
              ),
            ),
            const SizedBox(height: 10),
            MdpQuickAmountChips(
              controller: _amountCtrl,
              onSelected: (_) => setState(() => _inlineError = null),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Нэхэмжлэлийн утга',
                prefixIcon: Icon(Icons.description_outlined),
              ),
            ),
            if (_inlineError != null) ...[
              const SizedBox(height: 12),
              Text(
                _inlineError!,
                style: const TextStyle(color: MdpTheme.rose, fontSize: 13),
              ),
            ],
            const SizedBox(height: 20),
            MdpLoadingButton(
              label: 'Нэхэмжлэл илгээх',
              loadingLabel: 'Илгээж байна...',
              icon: Icons.forward_to_inbox_rounded,
              onPressed: _submitInvoice,
            ),
          ],
        ),
      ),
    );
  }
}

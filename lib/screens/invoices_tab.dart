import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api_service.dart';
import '../currency_utils.dart';
import '../modals/payment_sheets.dart';
import '../ui_kit.dart';

class InvoicesTab extends StatefulWidget {
  final ApiService apiService;
  final Map<String, dynamic> currentUser;
  final double balance;
  final List<Map<String, dynamic>> invoices;
  final Future<void> Function() onRefresh;

  const InvoicesTab({
    super.key,
    required this.apiService,
    required this.currentUser,
    required this.balance,
    required this.invoices,
    required this.onRefresh,
  });

  @override
  State<InvoicesTab> createState() => _InvoicesTabState();
}

class _InvoicesTabState extends State<InvoicesTab> {
  String _statusFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.invoices.where((inv) {
      if (_statusFilter == 'ALL') return true;
      return inv['status'] == _statusFilter;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Нэхэмжлэлүүд',
                          style: TextStyle(
                            color: MdpTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Имэйлээр ирсэн болон үүсгэсэн нэхэмжлэл',
                          style: TextStyle(
                            color: MdpTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: MdpTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      showCreateInvoiceSheet(
                        context,
                        apiService: widget.apiService,
                        senderEmail:
                            widget.currentUser['email']?.toString() ?? '',
                        onSuccessRefresh: widget.onRefresh,
                      );
                    },
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text(
                      'Шинэ',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              MdpSegmentedBar<String>(
                value: _statusFilter,
                items: const [
                  (id: 'ALL', label: 'Бүгд'),
                  (id: 'PENDING', label: 'Хүлээгдэж буй'),
                  (id: 'PAID', label: 'Төлөгдсөн'),
                ],
                onChanged: (val) => setState(() => _statusFilter = val),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            color: MdpTheme.primary,
            backgroundColor: MdpTheme.surfaceElevated,
            onRefresh: widget.onRefresh,
            child: filtered.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 80),
                      MdpEmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: 'Нэхэмжлэл олдсонгүй',
                        subtitle:
                            'Сонгосон шүүлтүүрт тохирох нэхэмжлэл одоогоор алга.',
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final inv = filtered[index];
                      final isPaid = inv['status'] == 'PAID';
                      final amountNum =
                          num.tryParse(inv['amount'].toString()) ?? 0;
                      final desc = inv['description']?.toString() ?? '';
                      final sender = inv['sender_email']?.toString() ?? '';
                      final receiver = inv['receiver_email']?.toString() ?? '';
                      final date = inv['date']?.toString() ?? '';
                      final qrCode = inv['qr_code']?.toString() ?? '';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: MdpCard(
                          padding: const EdgeInsets.all(16),
                          borderRadius: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  isPaid
                                      ? MdpStatusBadge.paid()
                                      : MdpStatusBadge.pending(),
                                  Text(
                                    date,
                                    style: const TextStyle(
                                      color: MdpTheme.textMuted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                desc,
                                style: const TextStyle(
                                  color: MdpTheme.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Илгээгч: $sender · Төлөгч: $receiver',
                                style: const TextStyle(
                                  color: MdpTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Divider(color: MdpTheme.hairline, height: 1),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    CurrencyUtils.formatMnt(amountNum),
                                    style: MdpTheme.tabularNumber.copyWith(
                                      color: MdpTheme.textPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  if (isPaid)
                                    OutlinedButton.icon(
                                      onPressed: () => showDigitalReceiptSheet(
                                        context,
                                        title: desc,
                                        amount: amountNum,
                                        counterparty: sender,
                                        date: date,
                                        method: inv['qr_type']?.toString() ??
                                            'DYNAMIC',
                                        isIncome: false,
                                        referenceId: 'INV-${inv['id']}',
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: MdpTheme.textPrimary,
                                        side: BorderSide(
                                          color: MdpTheme.hairlineStrong,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(11),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.receipt_outlined,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        'Баримт',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    )
                                  else
                                    FilledButton.icon(
                                      onPressed: () {
                                        HapticFeedback.lightImpact();
                                        showPaymentConfirmSheet(
                                          context,
                                          apiService: widget.apiService,
                                          availableBalance: widget.balance,
                                          qrCode: qrCode,
                                          qrType: 'DYNAMIC',
                                          presetAmount: amountNum.toDouble(),
                                          description: desc,
                                          invoiceId: inv['id'] as int?,
                                          onSuccessRefresh: widget.onRefresh,
                                        );
                                      },
                                      style: FilledButton.styleFrom(
                                        backgroundColor: MdpTheme.primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(11),
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.payment_rounded,
                                        size: 16,
                                      ),
                                      label: const Text(
                                        'Төлөх',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
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
                  ),
          ),
        ),
      ],
    );
  }
}

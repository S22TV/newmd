import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../biometric_service.dart';
import '../currency_utils.dart';
import '../modals/payment_sheets.dart';
import '../ui_kit.dart';

class DashboardTab extends StatelessWidget {
  final Map<String, dynamic> currentUser;
  final double balance;
  final bool hideBalance;
  final int pendingInvoicesCount;
  final List<Map<String, dynamic>> transactions;
  final VoidCallback onToggleHideBalance;
  final Future<void> Function() onRefresh;
  final ValueChanged<int> onNavigateTab;
  final VoidCallback onOpenTopUp;
  final VoidCallback onOpenTransfer;

  const DashboardTab({
    super.key,
    required this.currentUser,
    required this.balance,
    required this.hideBalance,
    required this.pendingInvoicesCount,
    required this.transactions,
    required this.onToggleHideBalance,
    required this.onRefresh,
    required this.onNavigateTab,
    required this.onOpenTopUp,
    required this.onOpenTransfer,
  });

  @override
  Widget build(BuildContext context) {
    final walletId = currentUser['wallet_id']?.toString() ?? 'MDP-99887766';
    final userName = currentUser['name']?.toString() ?? 'Хэрэглэгч';
    final recentItems = transactions.take(5).toList();

    return RefreshIndicator(
      color: MdpTheme.primary,
      backgroundColor: MdpTheme.surfaceElevated,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          Text(
            'Сайн байна уу, $userName',
            style: const TextStyle(
              color: MdpTheme.textPrimary,
              fontSize: 21,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Таны MDPay хэтэвчний өнөөдрийн тойм',
            style: TextStyle(
              color: MdpTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          _HeroBalanceCard(
            balance: balance,
            hideBalance: hideBalance,
            walletId: walletId,
            onToggleHideBalance: () {
              HapticFeedback.lightImpact();
              onToggleHideBalance();
            },
            onCopyWallet: () {
              HapticFeedback.lightImpact();
              Clipboard.setData(ClipboardData(text: walletId));
              MdpFeedback.showInfo(context, 'Дансны дугаар хуулагдлаа!');
            },
            onTapTopUp: onOpenTopUp,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _QuickActionItem(
                  icon: Icons.qr_code_scanner_rounded,
                  label: 'QR Төлбөр',
                  color: MdpTheme.primary,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onNavigateTab(1);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionItem(
                  icon: Icons.send_rounded,
                  label: 'Шилжүүлэг',
                  color: const Color(0xFF38BDF8),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onOpenTransfer();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionItem(
                  icon: Icons.add_card_rounded,
                  label: 'Цэнэглэх',
                  color: MdpTheme.emerald,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onOpenTopUp();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickActionItem(
                  icon: Icons.receipt_long_rounded,
                  label: 'Нэхэмжлэл',
                  color: MdpTheme.amber,
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onNavigateTab(2);
                  },
                ),
              ),
            ],
          ),
          if (pendingInvoicesCount > 0) ...[
            const SizedBox(height: 18),
            MdpCard(
              onTap: () {
                HapticFeedback.lightImpact();
                onNavigateTab(2);
              },
              backgroundColor: MdpTheme.amber.withValues(alpha: 0.08),
              borderColor: MdpTheme.amber.withValues(alpha: 0.28),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              borderRadius: 16,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: MdpTheme.amber.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.schedule_rounded,
                      color: MdpTheme.amber,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$pendingInvoicesCount хүлээгдэж буй нэхэмжлэл',
                          style: const TextStyle(
                            color: MdpTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Дарж нэхэмжлэлээ шалгаад төлнө үү',
                          style: TextStyle(
                            color: MdpTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: MdpTheme.amber,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Сүүлийн гүйлгээнүүд',
                style: TextStyle(
                  color: MdpTheme.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onNavigateTab(3);
                },
                child: const Text(
                  'Бүгдийг харах',
                  style: TextStyle(
                    color: MdpTheme.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (recentItems.isEmpty)
            const MdpEmptyState(
              icon: Icons.receipt_outlined,
              title: 'Гүйлгээ хараахан алга',
              subtitle: 'Таны хийсэн бүх орлого, зарлага энд харагдана.',
            )
          else
            ...recentItems.map((tx) {
              final isIncome = tx['type'] == 'INCOME';
              final amountNum = num.tryParse(tx['amount'].toString()) ?? 0;
              final title = tx['title']?.toString() ?? 'Гүйлгээ';
              final counterparty = tx['counterparty']?.toString() ?? '';
              final date = tx['date']?.toString() ?? '';
              final method = tx['method']?.toString() ?? 'QR_PAYMENT';

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: MdpCard(
                  onTap: () => showDigitalReceiptSheet(
                    context,
                    title: title,
                    amount: amountNum,
                    counterparty: counterparty,
                    date: date,
                    method: method,
                    isIncome: isIncome,
                    referenceId: tx['id'] != null ? 'TX-${tx['id']}' : null,
                  ),
                  padding: const EdgeInsets.all(14),
                  borderRadius: 18,
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: (isIncome ? MdpTheme.emerald : MdpTheme.rose)
                              .withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(13),
                        ),
                        child: Icon(
                          isIncome
                              ? Icons.south_west_rounded
                              : Icons.north_east_rounded,
                          color: isIncome ? MdpTheme.emerald : MdpTheme.rose,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: MdpTheme.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '$counterparty · $date',
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
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isIncome ? '+' : '-'}${CurrencyUtils.formatMnt(amountNum)}',
                            style: MdpTheme.tabularNumber.copyWith(
                              color: isIncome
                                  ? MdpTheme.emerald
                                  : MdpTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            CurrencyUtils.formatMethodLabel(method),
                            style: const TextStyle(
                              color: MdpTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _HeroBalanceCard extends StatelessWidget {
  final double balance;
  final bool hideBalance;
  final String walletId;
  final VoidCallback onToggleHideBalance;
  final VoidCallback onCopyWallet;
  final VoidCallback onTapTopUp;

  const _HeroBalanceCard({
    required this.balance,
    required this.hideBalance,
    required this.walletId,
    required this.onToggleHideBalance,
    required this.onCopyWallet,
    required this.onTapTopUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1A2044),
            Color(0xFF28306E),
            Color(0xFF141830),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: MdpTheme.primary.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: MdpTheme.primaryDeep.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                color: MdpTheme.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Үндсэн дансны үлдэгдэл',
                  style: TextStyle(
                    color: MdpTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (hideBalance && BiometricService.instance.protectBalanceEnabled)
                Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: MdpTheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: MdpTheme.primary.withValues(alpha: 0.35),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.fingerprint_rounded,
                        size: 13,
                        color: MdpTheme.textPrimary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Түгжээтэй',
                        style: TextStyle(
                          color: MdpTheme.textPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              IconButton(
                onPressed: onToggleHideBalance,
                visualDensity: VisualDensity.compact,
                tooltip: hideBalance ? 'Үлдэгдэл харуулах' : 'Үлдэгдэл нуух',
                icon: Icon(
                  hideBalance
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: MdpTheme.textPrimary,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Text(
              hideBalance ? '•••••••• ₮' : CurrencyUtils.formatMnt(balance),
              key: ValueKey<bool>(hideBalance),
              style: MdpTheme.tabularNumber.copyWith(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onCopyWallet,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$walletId · MNT',
                        style: MdpTheme.tabularNumber.copyWith(
                          color: MdpTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.copy_rounded,
                        size: 14,
                        color: MdpTheme.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTapTopUp,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 16, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'Цэнэглэх',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            color: MdpTheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: MdpTheme.hairline),
          ),
          child: Column(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: color, size: 21),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: MdpTheme.textPrimary,
                  fontSize: 11,
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

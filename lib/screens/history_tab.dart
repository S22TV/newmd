import 'package:flutter/material.dart';

import '../currency_utils.dart';
import '../modals/payment_sheets.dart';
import '../ui_kit.dart';

class HistorySearchTab extends StatefulWidget {
  final List<Map<String, dynamic>> transactions;
  final Future<void> Function() onRefresh;

  const HistorySearchTab({
    super.key,
    required this.transactions,
    required this.onRefresh,
  });

  @override
  State<HistorySearchTab> createState() => _HistorySearchTabState();
}

class _HistorySearchTabState extends State<HistorySearchTab> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchText = '';
  String _typeFilter = 'ALL';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.transactions.where((tx) {
      final matchesType = _typeFilter == 'ALL' || tx['type'] == _typeFilter;
      final q = _searchText.trim().toLowerCase();
      if (q.isEmpty) return matchesType;
      final matchesSearch =
          tx['title'].toString().toLowerCase().contains(q) ||
          tx['counterparty'].toString().toLowerCase().contains(q) ||
          tx['amount'].toString().contains(q);
      return matchesType && matchesSearch;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Гүйлгээний хуулга & Хайлт',
                style: TextStyle(
                  color: MdpTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _searchCtrl,
                onChanged: (val) => setState(() => _searchText = val),
                decoration: InputDecoration(
                  hintText: 'Утга, имэйл эсвэл үнийн дүнгээр хайх...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchText.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchText = '');
                          },
                          icon: const Icon(Icons.close_rounded, size: 18),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              MdpSegmentedBar<String>(
                value: _typeFilter,
                items: const [
                  (id: 'ALL', label: 'Бүгд'),
                  (id: 'INCOME', label: 'Орлого'),
                  (id: 'EXPENSE', label: 'Зарлага'),
                ],
                onChanged: (val) => setState(() => _typeFilter = val),
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
                    children: [
                      const SizedBox(height: 80),
                      MdpEmptyState(
                        icon: Icons.manage_search_rounded,
                        title: 'Гүйлгээ олдсонгүй',
                        subtitle: 'Хайлтын үг болон шүүлтүүрээ өөрчлөөд үзээрэй.',
                        actionLabel:
                            _searchText.isNotEmpty || _typeFilter != 'ALL'
                                ? 'Шүүлтүүр цэвэрлэх'
                                : null,
                        onAction: () {
                          _searchCtrl.clear();
                          setState(() {
                            _searchText = '';
                            _typeFilter = 'ALL';
                          });
                        },
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final tx = filtered[index];
                      final isIncome = tx['type'] == 'INCOME';
                      final amountNum =
                          num.tryParse(tx['amount'].toString()) ?? 0;
                      final title = tx['title']?.toString() ?? 'Гүйлгээ';
                      final counterparty =
                          tx['counterparty']?.toString() ?? '';
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
                            referenceId:
                                tx['id'] != null ? 'TX-${tx['id']}' : null,
                          ),
                          padding: const EdgeInsets.all(14),
                          borderRadius: 18,
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: (isIncome
                                          ? MdpTheme.emerald
                                          : MdpTheme.rose)
                                      .withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Icon(
                                  isIncome
                                      ? Icons.south_west_rounded
                                      : Icons.north_east_rounded,
                                  color: isIncome
                                      ? MdpTheme.emerald
                                      : MdpTheme.rose,
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
                                          : MdpTheme.rose,
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
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

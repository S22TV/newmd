import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api_service.dart';
import '../biometric_service.dart';
import '../modals/payment_sheets.dart';
import '../modals/settings_sheet.dart';
import '../ui_kit.dart';
import 'dashboard_tab.dart';
import 'history_tab.dart';
import 'invoices_tab.dart';
import 'login_screen.dart';
import 'qr_tab.dart';

class MainWorkspaceScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const MainWorkspaceScreen({super.key, required this.userData});

  @override
  State<MainWorkspaceScreen> createState() => _MainWorkspaceScreenState();
}

class _MainWorkspaceScreenState extends State<MainWorkspaceScreen> {
  final ApiService _apiService = ApiService();
  int _selectedIndex = 0;

  final BiometricService _biometricService = BiometricService.instance;
  double _balance = 0;
  bool _hideBalance = true;
  int _pendingInvoicesCount = 0;
  List<Map<String, dynamic>> _invoices = [];
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _initSecurityAndLoad();
  }

  Future<void> _initSecurityAndLoad() async {
    await _biometricService.init();
    await _biometricService.setLastSignedInEmail(
      widget.userData['email']?.toString() ?? '',
    );
    if (mounted) {
      setState(() {
        _hideBalance = _biometricService.protectBalanceEnabled;
      });
    }
    await _loadDashboard();
  }

  Future<void> _toggleHideBalance() async {
    if (!_hideBalance) {
      setState(() => _hideBalance = true);
      return;
    }
    if (_biometricService.protectBalanceEnabled) {
      final authorized = await _biometricService.authorizeAction(
        context,
        reason:
            'Үндсэн дансны үлдэгдлийг харахын тулд хурууны хээ эсвэл Face ID ашиглана уу',
        title: 'Үлдэгдэл харах баталгаажуулалт',
      );
      if (!mounted || !authorized) return;
    }
    setState(() => _hideBalance = false);
  }

  Future<void> _loadDashboard({bool showLoader = true}) async {
    if (showLoader && _transactions.isEmpty && _invoices.isEmpty) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    } else {
      setState(() => _loadError = null);
    }

    final res = await _apiService.sendRequest('get_dashboard', {
      'email': widget.userData['email'],
    });

    if (!mounted) return;

    if (res['status'] == 'success') {
      setState(() {
        _balance = double.tryParse(res['balance'].toString()) ?? 0;
        _pendingInvoicesCount = (res['pending_invoices_count'] as int?) ?? 0;
        _invoices = (res['invoices'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _transactions = (res['transactions'] as List<dynamic>? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _isLoading = false;
        _loadError = null;
      });
    } else {
      final errMsg =
          res['message']?.toString() ?? 'Мэдээлэл татахад алдаа гарлаа.';
      setState(() {
        _isLoading = false;
        _loadError = errMsg;
      });
      MdpFeedback.showError(
        context,
        errMsg,
        onRetry: () => _loadDashboard(showLoader: true),
      );
    }
  }

  void _onNavTap(int index) {
    if (index == _selectedIndex) return;
    HapticFeedback.lightImpact();
    setState(() => _selectedIndex = index);
  }

  void _openTopUp() {
    HapticFeedback.lightImpact();
    showTopUpSheet(
      context,
      apiService: _apiService,
      onSuccessRefresh: () => _loadDashboard(showLoader: false),
    );
  }

  void _openTransfer() {
    HapticFeedback.lightImpact();
    showDirectTransferSheet(
      context,
      apiService: _apiService,
      availableBalance: _balance,
      onSuccessRefresh: () => _loadDashboard(showLoader: false),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MdpTheme.canvas,
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: MdpTheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
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
          IconButton(
            tooltip: 'Данс цэнэглэх',
            onPressed: _openTopUp,
            icon: const Icon(
              Icons.add_card_rounded,
              color: MdpTheme.primary,
            ),
          ),
          IconButton(
            tooltip: 'Шинэчлэх',
            onPressed: () {
              HapticFeedback.lightImpact();
              _loadDashboard(showLoader: true);
            },
            icon: const Icon(
              Icons.refresh_rounded,
              color: MdpTheme.textSecondary,
            ),
          ),
          IconButton(
            tooltip: 'Тохиргоо',
            onPressed: () {
              HapticFeedback.lightImpact();
              showSettingsSheet(
                context,
                currentUser: widget.userData,
                onSecurityChanged: () {
                  if (mounted) {
                    setState(() {
                      if (_biometricService.protectBalanceEnabled) {
                        _hideBalance = true;
                      }
                    });
                  }
                },
              );
            },
            icon: const Icon(
              Icons.settings_outlined,
              color: MdpTheme.textSecondary,
            ),
          ),
          IconButton(
            tooltip: 'Гарах',
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            icon: const Icon(
              Icons.logout_rounded,
              color: MdpTheme.rose,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const MdpShimmerDashboard()
          : _loadError != null && _transactions.isEmpty && _invoices.isEmpty
              ? MdpEmptyState(
                  icon: Icons.cloud_off_rounded,
                  title: 'Холболтын алдаа гарлаа',
                  subtitle: _loadError!,
                  actionLabel: 'Дахин оролдох',
                  onAction: () => _loadDashboard(showLoader: true),
                )
              : IndexedStack(
                  index: _selectedIndex,
                  children: [
                    DashboardTab(
                      currentUser: widget.userData,
                      balance: _balance,
                      hideBalance: _hideBalance,
                      pendingInvoicesCount: _pendingInvoicesCount,
                      transactions: _transactions,
                      onToggleHideBalance: _toggleHideBalance,
                      onRefresh: () => _loadDashboard(showLoader: false),
                      onNavigateTab: _onNavTap,
                      onOpenTopUp: _openTopUp,
                      onOpenTransfer: _openTransfer,
                    ),
                    QrSystemTab(
                      apiService: _apiService,
                      balance: _balance,
                      onRefresh: () => _loadDashboard(showLoader: false),
                    ),
                    InvoicesTab(
                      apiService: _apiService,
                      currentUser: widget.userData,
                      balance: _balance,
                      invoices: _invoices,
                      onRefresh: () => _loadDashboard(showLoader: false),
                    ),
                    HistorySearchTab(
                      transactions: _transactions,
                      onRefresh: () => _loadDashboard(showLoader: false),
                    ),
                  ],
                ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: MdpTheme.hairline)),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onNavTap,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Хяналт',
            ),
            const NavigationDestination(
              icon: Icon(Icons.qr_code_scanner_rounded),
              selectedIcon: Icon(Icons.qr_code_2_rounded),
              label: 'QR Төлбөр',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: _pendingInvoicesCount > 0,
                label: Text('$_pendingInvoicesCount'),
                backgroundColor: MdpTheme.amber,
                textColor: Colors.black,
                child: const Icon(Icons.receipt_long_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: _pendingInvoicesCount > 0,
                label: Text('$_pendingInvoicesCount'),
                backgroundColor: MdpTheme.amber,
                textColor: Colors.black,
                child: const Icon(Icons.receipt_long_rounded),
              ),
              label: 'Нэхэмжлэл',
            ),
            const NavigationDestination(
              icon: Icon(Icons.manage_search_rounded),
              selectedIcon: Icon(Icons.manage_search_rounded),
              label: 'Түүх & Хайлт',
            ),
          ],
        ),
      ),
    );
  }
}

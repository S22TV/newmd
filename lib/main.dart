import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MDPay - Төлбөрийн Платформ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
        primaryColor: const Color(0xFF3B41E3),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B41E3),
          primary: const Color(0xFF3B41E3),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

// ============================================================================
// 1-Р ХУУДАС: НЭВТРЭХ & БҮРТГҮҮЛЭХ ХУУДАС
// ============================================================================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State createState() => _LoginScreenState();
}

class _LoginScreenState extends State {
  final ApiService _apiService = ApiService();
  final TextEditingController _emailCtrl = TextEditingController(
    text: "customer@mdpay.mn",
  );
  final TextEditingController _passCtrl = TextEditingController(
    text: "Demo1234!",
  );

  bool _isLoginMode = true;
  bool _obscureText = true;
  bool _isLoading = false;

  Future _submitAuth() async {
    setState(() => _isLoading = true);

    final res = await _apiService.sendRequest("login", {
      "email": _emailCtrl.text.trim(),
      "password": _passCtrl.text.trim(),
    });

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (res["status"] == "success") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainWorkspaceScreen(userData: res["user"]),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res["message"] ?? "Алдаа гарлаа"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 36),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0D1238), Color(0xFF3942E6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(36),
                  bottomRight: Radius.circular(36),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.qr_code_2,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "MDpay",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "● MDPAY FINANCIAL PLATFORM",
                    style: TextStyle(
                      color: Color(0xFF8C9EFF),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Санхүүгээ ухаалгаар\nудирд.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Төлбөр, нэхэмжлэл, шилжүүлэг — бүгд нэг системд.",
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "MDPAY ACCOUNT",
                      style: TextStyle(
                        color: Color(0xFF3B41E3),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Тавтай морил!",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Өөрийн бүртгэлээр нэвтэрч, дансаа удирдаарай.",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F4F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isLoginMode = true),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _isLoginMode
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  "Нэвтрэх",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _isLoginMode = false),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: !_isLoginMode
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  "Бүртгүүлэх",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: "И-мэйл хаяг",
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passCtrl,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        labelText: "Нууц үг",
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureText
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () =>
                              setState(() => _obscureText = !_obscureText),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B41E3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _isLoading ? null : _submitAuth,
                        child: _isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isLoginMode ? "Нэвтрэх  →" : "Бүртгүүлэх  →",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Демо эрхээр турших (Дарж автоматаар бөглөнө):",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: [
                              ActionChip(
                                avatar: const Icon(Icons.store, size: 16),
                                label: const Text(
                                  "merchant@mdpay.mn",
                                  style: TextStyle(fontSize: 12),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _emailCtrl.text = "merchant@mdpay.mn";
                                    _passCtrl.text = "Demo1234!";
                                  });
                                },
                              ),
                              ActionChip(
                                avatar: const Icon(Icons.person, size: 16),
                                label: const Text(
                                  "customer@mdpay.mn",
                                  style: TextStyle(fontSize: 12),
                                ),
                                onPressed: () {
                                  setState(() {
                                    _emailCtrl.text = "customer@mdpay.mn";
                                    _passCtrl.text = "Demo1234!";
                                  });
                                },
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
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ҮНДСЭН WORKSPACE БОЛОН 4 ЦЭС УДИРДАХ ХУУДАС
// ============================================================================
class MainWorkspaceScreen extends StatefulWidget {
  final Map userData;
  const MainWorkspaceScreen({super.key, required this.userData});

  @override
  State createState() => _MainWorkspaceScreenState();
}

class _MainWorkspaceScreenState extends State {
  final ApiService _apiService = ApiService();
  int _selectedIndex = 0;

  double _balance = 0;
  bool _hideBalance = false;
  int _pendingInvoicesCount = 0;
  int _recentTxCount = 0;
  List _invoices = [];
  List _transactions = [];
  bool _isLoading = true;

  String _qrType = "DYNAMIC";
  final TextEditingController _qrAmountCtrl = TextEditingController(
    text: "125000",
  );
  final TextEditingController _qrDescCtrl = TextEditingController(
    text: "Бараа бүтээгдэхүүний төлбөр",
  );
  String _generatedQrCode = "MDPAY_DYN_101_125000";

  String _searchText = "";
  String _typeFilter = "ALL";

  Map get currentUser {
    final widgetObj = widget as MainWorkspaceScreen;
    return widgetObj.userData;
  }

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future _loadDashboard() async {
    setState(() => _isLoading = true);
    final res = await _apiService.sendRequest("get_dashboard", {
      "email": currentUser["email"],
    });
    if (res["status"] == "success") {
      setState(() {
        _balance = double.tryParse(res["balance"].toString()) ?? 0;
        _pendingInvoicesCount = res["pending_invoices_count"] ?? 0;
        _recentTxCount = res["recent_transactions_count"] ?? 0;
        _invoices = List.from(res["invoices"] ?? []);
        _transactions = List.from(res["transactions"] ?? []);
        _isLoading = false;
      });
    }
  }

  void _onNavTap(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final List screens = [
      _buildDashboardTab(),
      _buildQrSystemTab(),
      _buildInvoicesTab(),
      _buildHistorySearchTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF3B41E3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.account_balance_wallet,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              "MDpay",
              style: TextStyle(
                color: Color(0xFF1A1F36),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F4EA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "● DEMO",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: "Данс цэнэглэх",
            onPressed: _showTopUpDialog,
            icon: const Icon(Icons.add_card, color: Color(0xFF3B41E3)),
          ),
          IconButton(
            tooltip: "Шинэчлэх",
            onPressed: _loadDashboard,
            icon: const Icon(Icons.refresh, color: Colors.black87),
          ),
          IconButton(
            tooltip: "Гарах",
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            icon: const Icon(Icons.logout, color: Colors.redAccent),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTap,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF3B41E3),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: "Хяналт",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: "QR Төлбөр",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: "Нэхэмжлэл",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_search),
            label: "Түүх & Хайлт",
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 2-Р ХУУДАС: ХЯНАЛТЫН САМБАР
  // ==========================================================================
  Widget _buildDashboardTab() {
    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "● ТАНЫ САНХҮҮГИЙН ТОЙМ",
              style: TextStyle(
                color: Color(0xFF3B41E3),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Сайн байна уу, ${currentUser['name']}! ✳",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Таны MDPay дансны өнөөдрийн мэдээлэл.",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3942E6), Color(0xFF5A62F5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.white70,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Үндсэн дансны үлдэгдэл",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () =>
                            setState(() => _hideBalance = !_hideBalance),
                        icon: Icon(
                          _hideBalance
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text(
                      _hideBalance
                          ? "•••••••• ₮"
                          : "${_balance.toStringAsFixed(0)} ₮",
                      key: ValueKey(_hideBalance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "● Туршилтын данс (MNT)",
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 12,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(
                            ClipboardData(
                              text: currentUser["wallet_id"] ?? "MDP-998877",
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Дансны дугаар хуулагдлаа!"),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              currentUser["wallet_id"] ?? "MDP-998877",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.copy,
                              color: Colors.white70,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: "Хүлээгдэж буй нэхэмжлэл",
                    count: _pendingInvoicesCount.toString().padLeft(2, '0'),
                    linkText: "Нэхэмжлэл харах ↗",
                    icon: Icons.receipt_outlined,
                    onTap: () => _onNavTap(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: "Сүүлийн гүйлгээ",
                    count: _recentTxCount.toString().padLeft(2, '0'),
                    linkText: "Түүх харах ↗",
                    icon: Icons.trending_up,
                    onTap: () => _onNavTap(3),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              "Шуурхай үйлдлүүд",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildActionRow(
              icon: Icons.qr_code_scanner,
              title: "QR Код үүсгэх & Уншуулах",
              sub: "Dynamic QR (дүнтэй) болон QuickPay (дүнгүй)",
              onTap: () => _onNavTap(1),
            ),
            _buildActionRow(
              icon: Icons.forward_to_inbox,
              title: "Имэйлээр нэхэмжлэл үүсгэх",
              sub: "Хэрэглэгч рүү нэхэмжлэл илгээх ба төлөх",
              onTap: () => _onNavTap(2),
            ),
            _buildActionRow(
              icon: Icons.currency_exchange,
              title: "Мөнгөн шилжүүлэг хийх",
              sub: "MDPay хэрэглэгч рүү шууд мөнгө шилжүүлэх",
              onTap: _showDirectTransferSheet,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String count,
    required String linkText,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF0FF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: const Color(0xFF3B41E3), size: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              count,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              linkText,
              style: const TextStyle(
                color: Color(0xFF3B41E3),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow({
    required IconData icon,
    required String title,
    required String sub,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFEDF0FF),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF3B41E3)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          sub,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      ),
    );
  }

  // ==========================================================================
  // 3-Р ХУУДАС: QR СИСТЕМ (Dynamic QR ба QuickPay QR)
  // ==========================================================================
  Widget _buildQrSystemTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "QR Код Үүсгэгч & Уншигч",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Dynamic QR (үнийн дүнтэй) болон QuickPay (үнийн дүнгүй) систем.",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F143A),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white70,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "MDPay Камерын QR Уншигч",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const LinearProgressIndicator(
                  color: Colors.greenAccent,
                  backgroundColor: Colors.white12,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B41E3),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _openModernPayBottomSheet(
                          qrCode: _generatedQrCode,
                          qrType: "DYNAMIC",
                          presetAmount:
                              double.tryParse(_qrAmountCtrl.text) ?? 125000,
                          description: _qrDescCtrl.text,
                        ),
                        icon: const Icon(Icons.qr_code_scanner, size: 18),
                        label: const Text(
                          "Dynamic QR Унших",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => _openModernPayBottomSheet(
                          qrCode: "MDPAY_QUICK_OPEN",
                          qrType: "QUICK",
                          presetAmount: 0,
                          description: "QuickPay Шууд Төлбөр",
                        ),
                        icon: const Icon(Icons.flash_on, size: 18),
                        label: const Text(
                          "QuickPay Унших",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "API-аар QR Код Үүсгэх (Вэбсайт / Мерчант)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text("Dynamic QR (Дүнтэй)"),
                        selected: _qrType == "DYNAMIC",
                        onSelected: (_) => setState(() {
                          _qrType = "DYNAMIC";
                          _qrAmountCtrl.text = "125000";
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text("QuickPay (Дүнгүй)"),
                        selected: _qrType == "QUICK",
                        onSelected: (_) => setState(() {
                          _qrType = "QUICK";
                          _qrAmountCtrl.text = "0";
                        }),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_qrType == "DYNAMIC") ...[
                  TextField(
                    controller: _qrAmountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Үнийн дүн (₮)",
                      prefixIcon: const Icon(Icons.payments_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: _qrDescCtrl,
                  decoration: InputDecoration(
                    labelText: "Гүйлгээний утга / Барааны нэр",
                    prefixIcon: const Icon(Icons.notes),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B41E3),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () async {
                      final res = await _apiService.sendRequest("generate_qr", {
                        "qr_type": _qrType,
                        "amount": _qrAmountCtrl.text,
                        "description": _qrDescCtrl.text,
                      });
                      if (!mounted) return;
                      if (res["status"] == "success") {
                        setState(() => _generatedQrCode = res["qr_code"]);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("QR Код амжилттай үүслээ!"),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(res["message"] ?? ""),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.qr_code),
                    label: const Text("Шинэ QR Код Үүсгэх"),
                  ),
                ),
                const Divider(height: 30, thickness: 1),
                Center(
                  child: Container(
                    width: 240,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF3B41E3),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "● MDpay QR",
                          style: TextStyle(
                            color: Color(0xFF3B41E3),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _qrType == "DYNAMIC"
                              ? "${_qrAmountCtrl.text} ₮"
                              : "Дүн оруулж төлөх",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Icon(
                          Icons.qr_code_2,
                          size: 130,
                          color: Color(0xFF1A1F36),
                        ),
                        Text(
                          _generatedQrCode,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openModernPayBottomSheet({
    required String qrCode,
    required String qrType,
    required double presetAmount,
    required String description,
    int? invoiceId,
  }) {
    final TextEditingController payAmountCtrl = TextEditingController(
      text: qrType == "DYNAMIC" ? presetAmount.toStringAsFixed(0) : "",
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    qrType == "DYNAMIC"
                        ? "Dynamic QR Төлбөр"
                        : "QuickPay Шууд Төлбөр",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Chip(
                    label: Text(qrType),
                    backgroundColor: const Color(0xFFEDF0FF),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "QR код: $qrCode",
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                "Гүйлгээний утга: $description",
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                "Боломжит үлдэгдэл: ${_balance.toStringAsFixed(0)} ₮",
                style: const TextStyle(
                  color: Color(0xFF3B41E3),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: payAmountCtrl,
                readOnly: qrType == "DYNAMIC",
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: qrType == "DYNAMIC"
                      ? "Төлөх дүн (API-аас ирсэн дүн)"
                      : "Төлөх үнийн дүнгээ оруулна уу (₮)",
                  prefixIcon: const Icon(Icons.payments_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B41E3),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    final res = await _apiService.sendRequest(
                      "pay_qr_or_invoice",
                      {
                        "amount": payAmountCtrl.text.trim(),
                        "description": description,
                        "counterparty": qrCode,
                        "method": qrType,
                        "invoice_id": invoiceId,
                      },
                    );

                    if (!mounted) return;
                    if (res["status"] == "success") {
                      await _loadDashboard();
                      _showSuccessReceiptDialog(
                        amount: payAmountCtrl.text.trim(),
                        desc: description,
                        code: qrCode,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(res["message"] ?? "Алдаа гарлаа"),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Төлбөр баталгаажуулах",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessReceiptDialog({
    required String amount,
    required String desc,
    required String code,
  }) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: Color(0xFFE6F4EA),
              child: Icon(Icons.check_circle, color: Colors.green, size: 44),
            ),
            const SizedBox(height: 12),
            const Text(
              "Амжилттай төлөгдлөө!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              "$amount ₮",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B41E3),
              ),
            ),
            const Divider(height: 24),
            Text("Утга: $desc", textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              "Код: $code",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Болсон"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTopUpDialog() {
    final amountCtrl = TextEditingController(text: "500000");
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Данс цэнэглэх (Банкны API)"),
        content: TextField(
          controller: amountCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Цэнэглэх дүн (₮)",
            prefixIcon: Icon(Icons.add_card),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Болих"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final res = await _apiService.sendRequest("top_up", {
                "amount": amountCtrl.text.trim(),
              });
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(res["message"] ?? ""),
                  backgroundColor: Colors.green,
                ),
              );
              _loadDashboard();
            },
            child: const Text("Цэнэглэх"),
          ),
        ],
      ),
    );
  }

  void _showDirectTransferSheet() {
    final receiverCtrl = TextEditingController(text: "friend@mdpay.mn");
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController(text: "Мөнгөн шилжүүлэг");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Мөнгө шилжүүлэх"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: receiverCtrl,
                decoration: const InputDecoration(
                  labelText: "Хүлээн авагчийн имэйл",
                ),
              ),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Дүн (₮)"),
              ),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(labelText: "Гүйлгээний утга"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Болих"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final res = await _apiService.sendRequest("pay_qr_or_invoice", {
                "amount": amountCtrl.text.trim(),
                "description": descCtrl.text.trim(),
                "counterparty": receiverCtrl.text.trim(),
                "method": "TRANSFER",
              });
              if (!mounted) return;
              if (res["status"] == "success") {
                await _loadDashboard();
                _showSuccessReceiptDialog(
                  amount: amountCtrl.text.trim(),
                  desc: descCtrl.text.trim(),
                  code: receiverCtrl.text.trim(),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(res["message"] ?? ""),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text("Шилжүүлэх"),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 4-Р ХУУДАС: НЭХЭМЖЛЭЛ ҮҮСГЭХ БА ТӨЛӨХ
  // ==========================================================================
  void _showCreateInvoiceDialog() {
    final emailCtrl = TextEditingController(text: "customer@mdpay.mn");
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Имэйлээр нэхэмжлэл үүсгэх"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: "Төлөгчийн И-мэйл хаяг",
                  prefixIcon: Icon(Icons.alternate_email),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Нэхэмжлэх дүн (₮)",
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descCtrl,
                decoration: const InputDecoration(
                  labelText: "Нэхэмжлэлийн утга",
                  prefixIcon: Icon(Icons.description_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Болих"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B41E3),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              final res = await _apiService.sendRequest("create_invoice", {
                "sender_email": currentUser["email"],
                "receiver_email": emailCtrl.text.trim(),
                "amount": amountCtrl.text.trim(),
                "description": descCtrl.text.trim(),
              });
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(res["message"] ?? ""),
                  backgroundColor: res["status"] == "success"
                      ? Colors.green
                      : Colors.redAccent,
                ),
              );
              if (res["status"] == "success") {
                _loadDashboard();
              }
            },
            child: const Text("Илгээх"),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoicesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Нэхэмжлэлүүд",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Имэйлээр ирсэн болон үүсгэсэн нэхэмжлэл",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B41E3),
                  foregroundColor: Colors.white,
                ),
                onPressed: _showCreateInvoiceDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text("Нэхэмжлэл"),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: ListView.builder(
              itemCount: _invoices.length,
              itemBuilder: (context, index) {
                final inv = _invoices[index];
                final bool isPaid = inv["status"] == "PAID";

                return Card(
                  elevation: 0,
                  color: Colors.white,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(14),
                    leading: CircleAvatar(
                      backgroundColor: isPaid
                          ? const Color(0xFFE6F4EA)
                          : const Color(0xFFFFF3E0),
                      child: Icon(
                        isPaid ? Icons.check_circle : Icons.schedule,
                        color: isPaid ? Colors.green : Colors.orange,
                      ),
                    ),
                    title: Text(
                      inv["description"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Илгээгч: ${inv['sender_email']}\nТөлөгч: ${inv['receiver_email']}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "${inv['amount']} ₮",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        isPaid
                            ? const Text(
                                "ТӨЛӨГДСӨН",
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : SizedBox(
                                height: 28,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF3B41E3),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                  ),
                                  onPressed: () => _openModernPayBottomSheet(
                                    qrCode: inv["qr_code"],
                                    qrType: "DYNAMIC",
                                    presetAmount:
                                        double.tryParse(
                                          inv["amount"].toString(),
                                        ) ??
                                        0,
                                    description: inv["description"],
                                    invoiceId: inv["id"],
                                  ),
                                  child: const Text(
                                    "Төлөх",
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // 5-Р ХУУДАС: ГҮЙЛГЭЭНИЙ ТҮҮХ БА ОЛОН ТӨРЛӨӨР ХАЙЛТ
  // ==========================================================================
  Widget _buildHistorySearchTab() {
    final filtered = _transactions.where((tx) {
      final matchesType = _typeFilter == "ALL" || tx["type"] == _typeFilter;
      final q = _searchText.toLowerCase();
      final matchesSearch =
          tx["title"].toString().toLowerCase().contains(q) ||
          tx["counterparty"].toString().toLowerCase().contains(q) ||
          tx["amount"].toString().contains(q);
      return matchesType && matchesSearch;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Гүйлгээний хуулга & Хайлт",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (val) => setState(() => _searchText = val),
            decoration: InputDecoration(
              hintText: "Утга, имэйл эсвэл үнийн дүнгээр хайх...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ChoiceChip(
                label: const Text("Бүгд"),
                selected: _typeFilter == "ALL",
                onSelected: (_) => setState(() => _typeFilter = "ALL"),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text("Орлого"),
                selected: _typeFilter == "INCOME",
                onSelected: (_) => setState(() => _typeFilter = "INCOME"),
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text("Зарлага"),
                selected: _typeFilter == "EXPENSE",
                onSelected: (_) => setState(() => _typeFilter = "EXPENSE"),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text("Хайлтад тохирох гүйлгээ олдсонгүй"))
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final tx = filtered[index];
                      final bool isIncome = tx["type"] == "INCOME";

                      return Card(
                        elevation: 0,
                        color: Colors.white,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isIncome
                                ? const Color(0xFFE6F4EA)
                                : const Color(0xFFFCE8E6),
                            child: Icon(
                              isIncome ? Icons.south_west : Icons.north_east,
                              color: isIncome ? Colors.green : Colors.redAccent,
                            ),
                          ),
                          title: Text(
                            tx["title"],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${tx['counterparty']} • ${tx['date']}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Text(
                            "${isIncome ? '+' : '-'}${tx['amount']} ₮",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isIncome ? Colors.green : Colors.redAccent,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

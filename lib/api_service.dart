import 'dart:async';

class ApiService {
  // Таны Backend-ийн нэгдсэн 1 URL (Нэг route рүү бүх params явна)
  static const String baseUrl = "http://127.0.0.1:8000/api/mdpay/";

  static double _demoBalance = 1850000.0;

  static final List _demoInvoices = [
    {
      "id": 101,
      "sender_email": "merchant@mdpay.mn",
      "receiver_email": "customer@mdpay.mn",
      "amount": 125000,
      "description": "Мандах ИС - Сургалтын төлбөр",
      "qr_type": "DYNAMIC",
      "qr_code": "MDPAY_DYN_101_125000",
      "status": "PENDING",
      "date": "2026-11-16 10:30",
    },
    {
      "id": 102,
      "sender_email": "coffee@mdpay.mn",
      "receiver_email": "customer@mdpay.mn",
      "amount": 18500,
      "description": "Caffe Bene - Захиалга #402",
      "qr_type": "DYNAMIC",
      "qr_code": "MDPAY_DYN_102_18500",
      "status": "PENDING",
      "date": "2026-11-16 11:15",
    },
    {
      "id": 103,
      "sender_email": "customer@mdpay.mn",
      "receiver_email": "friend@mdpay.mn",
      "amount": 45000,
      "description": "Өдрийн хоолны тооцоо",
      "qr_type": "QUICK",
      "qr_code": "MDPAY_QUICK_103_0",
      "status": "PAID",
      "date": "2026-11-15 14:20",
    },
  ];

  static final List _demoTransactions = [
    {
      "id": 501,
      "title": "Банкны данснаас цэнэглэлт",
      "counterparty": "Хаан Банк - 5000123456",
      "amount": 1900000,
      "type": "INCOME",
      "method": "BANK_API",
      "date": "2026-11-14 09:00",
    },
    {
      "id": 502,
      "title": "Өдрийн хоолны тооцоо",
      "counterparty": "friend@mdpay.mn",
      "amount": 45000,
      "type": "EXPENSE",
      "method": "DYNAMIC_QR",
      "date": "2026-11-15 14:20",
    },
    {
      "id": 503,
      "title": "Номын сангийн хураамж",
      "counterparty": "merchant@mdpay.mn",
      "amount": 5000,
      "type": "EXPENSE",
      "method": "QUICK_QR",
      "date": "2026-11-15 16:45",
    },
  ];

  // Бүх хүсэлтийг 1 URL руу action болон params-аар илгээх үндсэн функц
  Future sendRequest(String action, Map params) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _handleAction(action, params);
  }

  Map _handleAction(String action, Map params) {
    switch (action) {
      case "login":
        String email = (params["email"] ?? "").toString().trim();
        String password = (params["password"] ?? "").toString().trim();

        if (email.isEmpty || password.isEmpty) {
          return {
            "status": "error",
            "message": "Имэйл хаяг болон нууц үгээ бүрэн оруулна уу!",
          };
        }
        return {
          "status": "success",
          "user": {
            "name": email.contains("merchant")
                ? "Мерчант Байгууллага"
                : "Bumanhuslen Erdenebaatar",
            "email": email,
            "wallet_id": "MDP-99887766",
            "balance": _demoBalance,
          },
        };

      case "get_dashboard":
        int pendingCount = _demoInvoices
            .where((inv) => inv["status"] == "PENDING")
            .length;
        return {
          "status": "success",
          "balance": _demoBalance,
          "pending_invoices_count": pendingCount,
          "recent_transactions_count": _demoTransactions.length,
          "invoices": List.from(_demoInvoices),
          "transactions": List.from(_demoTransactions),
        };

      case "generate_qr":
        String qrType = (params["qr_type"] ?? "DYNAMIC").toString();
        double amount = double.tryParse(params["amount"].toString()) ?? 0;
        String desc = (params["description"] ?? "MDPay QR Төлбөр").toString();
        int nextId = 100 + _demoInvoices.length + 1;

        if (qrType == "DYNAMIC" && amount <= 0) {
          return {
            "status": "error",
            "message": "Dynamic QR үүсгэхийн тулд үнийн дүн оруулна уу!",
          };
        }

        String qrCode = qrType == "DYNAMIC"
            ? "MDPAY_DYN_${nextId}_${amount.toInt()}"
            : "MDPAY_QUICK_${nextId}_OPEN";

        return {
          "status": "success",
          "qr_code": qrCode,
          "qr_type": qrType,
          "amount": amount,
          "description": desc,
        };

      case "create_invoice":
        String receiver = (params["receiver_email"] ?? "").toString().trim();
        double amount = double.tryParse(params["amount"].toString()) ?? 0;
        String desc = (params["description"] ?? "").toString().trim();

        if (receiver.isEmpty || amount <= 0 || desc.isEmpty) {
          return {
            "status": "error",
            "message": "Имэйл, үнийн дүн болон утгыг бүрэн оруулна уу!",
          };
        }

        int newId = 100 + _demoInvoices.length + 1;
        Map newInv = {
          "id": newId,
          "sender_email": params["sender_email"] ?? "customer@mdpay.mn",
          "receiver_email": receiver,
          "amount": amount.toInt(),
          "description": desc,
          "qr_type": "DYNAMIC",
          "qr_code": "MDPAY_DYN_${newId}_${amount.toInt()}",
          "status": "PENDING",
          "date": "2026-11-16 15:10",
        };
        _demoInvoices.insert(0, newInv);

        return {
          "status": "success",
          "message": "$receiver хаяг руу нэхэмжлэл амжилттай илгээгдлээ!",
          "invoice": newInv,
        };

      case "pay_qr_or_invoice":
        double amount = double.tryParse(params["amount"].toString()) ?? 0;
        String desc = (params["description"] ?? "QR Төлбөр").toString();
        String counterparty = (params["counterparty"] ?? "MDPay Мерчант")
            .toString();
        var invoiceId = params["invoice_id"];

        if (amount <= 0) {
          return {
            "status": "error",
            "message": "Төлөх үнийн дүн 0-ээс их байх ёстой!",
          };
        }

        if (amount > _demoBalance) {
          return {
            "status": "error",
            "message":
                "Гүйлгээ амжилтгүй: Дансны үлдэгдэл хүрэлцэхгүй байна! (${_demoBalance.toInt()}₮)",
          };
        }

        _demoBalance -= amount;

        if (invoiceId != null) {
          for (var inv in _demoInvoices) {
            if (inv["id"] == invoiceId) {
              inv["status"] = "PAID";
            }
          }
        }

        _demoTransactions.insert(0, {
          "id": 500 + _demoTransactions.length + 1,
          "title": desc,
          "counterparty": counterparty,
          "amount": amount.toInt(),
          "type": "EXPENSE",
          "method": params["method"] ?? "QR_PAYMENT",
          "date": "2026-11-16 15:25",
        });

        return {
          "status": "success",
          "message": "Гүйлгээ амжилттай хийгдлээ!",
          "new_balance": _demoBalance,
        };

      case "top_up":
        double amount = double.tryParse(params["amount"].toString()) ?? 0;
        if (amount <= 0) {
          return {"status": "error", "message": "Цэнэглэх дүнгээ оруулна уу!"};
        }
        _demoBalance += amount;
        _demoTransactions.insert(0, {
          "id": 500 + _demoTransactions.length + 1,
          "title": "Банкны API-аар данс цэнэглэлт",
          "counterparty": "Банкны апп холболт",
          "amount": amount.toInt(),
          "type": "INCOME",
          "method": "BANK_API",
          "date": "2026-11-16 15:30",
        });
        return {
          "status": "success",
          "message": "Данс ${amount.toInt()}₮-өөр амжилттай цэнэглэгдлээ!",
          "new_balance": _demoBalance,
        };

      default:
        return {"status": "error", "message": "Тодорхойгүй үйлдэл: $action"};
    }
  }
}

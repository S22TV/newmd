import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyUtils {
  static final NumberFormat _mntFormatter = NumberFormat('#,##0', 'en_US');

  static String formatMnt(num value, {bool withSymbol = true}) {
    final formatted = _mntFormatter.format(value.round());
    return withSymbol ? '$formatted ₮' : formatted;
  }

  static String formatDynamic(dynamic raw, {bool withSymbol = true}) {
    final parsed = parseMnt(raw?.toString() ?? '0');
    return formatMnt(parsed, withSymbol: withSymbol);
  }

  static double parseMnt(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }

  static String stripDigits(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9]'), '');
    return cleaned.isEmpty ? '0' : cleaned;
  }

  static String formatMethodLabel(String? method) {
    switch ((method ?? '').toUpperCase()) {
      case 'BANK_API':
        return 'Банкны API';
      case 'DYNAMIC_QR':
      case 'DYNAMIC':
        return 'Dynamic QR';
      case 'QUICK_QR':
      case 'QUICK':
        return 'QuickPay QR';
      case 'TRANSFER':
        return 'Шууд шилжүүлэг';
      case 'QR_PAYMENT':
        return 'QR Төлбөр';
      default:
        return 'MDPay систем';
    }
  }
}

class MntCurrencyInputFormatter extends TextInputFormatter {
  static final NumberFormat _formatter = NumberFormat('#,##0', 'en_US');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final limitedDigits =
        digitsOnly.length > 11 ? digitsOnly.substring(0, 11) : digitsOnly;
    final number = int.tryParse(limitedDigits) ?? 0;
    final formatted = _formatter.format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

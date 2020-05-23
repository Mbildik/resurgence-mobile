import 'package:intl/intl.dart';

class Money {
  static String format(number) {
    return NumberFormat.simpleCurrency(
      name: '₺',
      decimalDigits: 0,
    ).format(number);
  }
}

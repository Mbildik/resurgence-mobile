import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Money {
  static String format(number) {
    return NumberFormat.simpleCurrency(
      name: '₺',
      decimalDigits: 0,
    ).format(number);
  }
}

class MoneyWidget extends StatelessWidget {
  final int number;

  const MoneyWidget(this.number, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(Money.format(number));
  }
}

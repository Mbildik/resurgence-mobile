import 'package:flutter/material.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/network/error.dart';

class ErrorHandler {
  static Future<T> showError<T>(BuildContext context, e) {
    if (e is ApiError) {
      return _abstractDialog(context, Text(e.message));
    }
    return _abstractDialog(context, Text(e.toString()));
  }

  static Future<T> _abstractDialog<T>(BuildContext context, Widget content) {
    return showDialog<T>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            S.errorOccurred,
            style: TextStyle(color: Colors.red),
          ),
          content: content,
        );
      },
    );
  }
}

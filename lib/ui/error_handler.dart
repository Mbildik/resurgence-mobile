import 'package:flutter/material.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/network/error.dart';

class ErrorHandler {
  // to fix [ERROR:flutter/lib/ui/ui_dart_state.cc(X)] Unhandled Exception:
  //  type 'Future<dynamic>' is not a subtype of type 'FutureOr<X<dynamic>>'
  //  error please provide T value as Null. ex: showError<Null>(context, e)
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

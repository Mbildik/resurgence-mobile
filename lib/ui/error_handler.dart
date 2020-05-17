import 'package:flutter/material.dart';
import 'package:resurgence/network/error.dart';

class ErrorHandler {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showError(
    BuildContext context,
    e,
  ) {
    // todo add more error handler much as possible
    if (e is ApiError) {
      return Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
        ),
      );
    } else {
      // default error handling method
      return Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }
}

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:resurgence/constants.dart';

typedef OnConfirm = Future Function();

class LoadingWidget extends StatelessWidget {
  const LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class RefreshOnErrorWidget extends StatelessWidget {
  final VoidCallback onPressed;

  RefreshOnErrorWidget({
    Key key,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            S.errorOccurred,
            style: Theme.of(context).textTheme.headline6,
          ),
          Tooltip(
            message: S.refresh,
            child: IconButton(
              icon: Icon(Icons.refresh),
              onPressed: onPressed,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyDataWidget extends StatelessWidget {
  const EmptyDataWidget({Key key, this.text}) : super(key: key);

  factory EmptyDataWidget.noData() {
    return EmptyDataWidget(text: S.noData);
  }

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: Theme.of(context).textTheme.headline6,
        textAlign: TextAlign.center,
      ),
    );
  }
}

class LoadingFutureBuilder<T> extends StatelessWidget {
  const LoadingFutureBuilder({
    Key key,
    @required this.future,
    @required this.builder,
    @required this.onError,
    this.onEmpty,
    this.onLoading = const LoadingWidget(),
    this.disableLoading = false,
  }) : super(key: key);

  final Future<T> future;
  final Function onError;
  final AsyncWidgetBuilder<T> builder;
  final Widget onEmpty;
  final Widget onLoading;
  final bool disableLoading;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        var data = snapshot.data;
        if (snapshot.connectionState == ConnectionState.waiting) {
          if (!disableLoading) return onLoading;
        } else if (snapshot.hasError) {
          log('loading future error', error: snapshot.error);
          return RefreshOnErrorWidget(
            onPressed: onError,
          );
        } else if (data is Iterable && data.isEmpty) {
          return onEmpty ?? EmptyDataWidget.noData();
        }

        return builder(context, snapshot);
      },
    );
  }
}

Future<bool> showConfirmationDialog(
  BuildContext context,
  String title,
  String content,
  String confirmText,
  String cancelText,
  OnConfirm onConfirm,
) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          FlatButton(
              onPressed: () =>
                  onConfirm().then((value) => Navigator.pop(context, true)),
              child: Text(confirmText)),
          FlatButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
        ],
      );
    },
  );
}

Future showInformationDialog(
  BuildContext context,
  String content, {
  String title,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          title ?? S.info,
          style: Theme.of(context)
              .primaryTextTheme
              .headline6
              .copyWith(color: Colors.green),
        ),
        content: Text(content),
      );
    },
  );
}

Future showErrorDialog(
  BuildContext context,
  String content, {
  String title,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          title ?? S.errorOccurred,
          style: TextStyle(color: Colors.red),
        ),
        content: Text(content),
      );
    },
  );
}

Future showHelpDialog({
  @required BuildContext context,
  String title,
  String content,
}) {
  return showDialog(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: Text(title),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        children: [
          Text(content),
        ],
      );
    },
  );
}

class OneClickTooltip extends StatelessWidget {
  const OneClickTooltip({
    Key key,
    @required this.message,
    @required this.child,
  }) : super(key: key);

  final Widget child;
  final String message;

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<State<Tooltip>>();
    return Tooltip(
      key: key,
      message: message,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onTap(key),
        child: child,
      ),
    );
  }

  void _onTap(GlobalKey key) {
    final dynamic tooltip = key.currentState;
    tooltip?.ensureTooltipVisible();
    Timer(Duration(seconds: 1), () => tooltip?.deactivate());
  }
}

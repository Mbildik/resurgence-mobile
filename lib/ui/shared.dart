import 'package:flutter/material.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/ui/button.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: const CircularProgressIndicator(),
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
        children: [
          Button(child: Text(S.reload), onPressed: onPressed),
          Text(S.errorOccurred),
        ],
      ),
    );
  }
}

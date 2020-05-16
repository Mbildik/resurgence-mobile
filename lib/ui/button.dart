import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final VoidCallback onPressed;
  final bool enabled;
  final Widget child;

  const Button({
    Key key,
    @required this.onPressed,
    @required this.child,
    this.enabled: true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      onPressed: enabled ? onPressed : null,
      child: child,
    );
  }
}

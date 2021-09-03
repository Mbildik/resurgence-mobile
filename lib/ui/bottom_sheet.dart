import 'package:flutter/material.dart';

class BottomSheetHolder extends StatelessWidget {
  const BottomSheetHolder({Key key, this.children}) : super(key: key);

  final Widget children;

  @override
  Widget build(BuildContext context) {
    return Column(children: [BottomSheetPin(), children]);
  }
}

class BottomSheetPin extends StatelessWidget {
  const BottomSheetPin({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      height: 4.0,
      width: 64.0,
      decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(16.0),
            right: Radius.circular(16.0),
          )),
    );
  }
}

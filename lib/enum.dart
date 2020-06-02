import 'package:flutter/material.dart';

class AbstractEnum {
  String key;
  String value;

  AbstractEnum({this.key, this.value});

  AbstractEnum.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['key'] = this.key;
    data['value'] = this.value;
    return data;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AbstractEnum &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;
}

class EnumWidget extends StatelessWidget {
  final AbstractEnum _enum;
  final Color color;

  const EnumWidget(
      this._enum, {
        Key key,
        @required this.color,
      }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: this.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(4.0),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(4.0),
        child: Text(_enum.value),
      ),
    );
  }
}

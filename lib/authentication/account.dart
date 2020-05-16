import 'package:resurgence/enum.dart';

class Account {
  String email;
  Status status;

  Account({this.email, this.status});

  Account.fromJson(Map<String, dynamic> json) {
    email = json['email'];
    status = json['status'] != null ? Status.fromJson(json['status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['email'] = this.email;
    if (this.status != null) {
      data['status'] = this.status.toJson();
    }
    return data;
  }
}

class Status extends AbstractEnum {
  bool enabled;

  Status({this.enabled, key, value}) : super(key: key, value: value);

  Status.fromJson(Map<String, dynamic> json) {
    enabled = json['enabled'];
    var abstractEnum = AbstractEnum.fromJson(json);
    key = abstractEnum.key;
    value = abstractEnum.value;
  }

  Map<String, dynamic> toJson() {
    var data = super.toJson();
    data['enabled'] = this.enabled;
    return data;
  }
}

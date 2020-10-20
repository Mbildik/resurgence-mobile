import 'package:resurgence/constants.dart';

class Message {
  final String from;
  final String content;
  final int sequence;

  Message(this.from, this.content, this.sequence);

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      json['from'],
      json['content'],
      json['sequence'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          sequence == other.sequence;

  @override
  int get hashCode => sequence.hashCode;
}

class Subscription {
  final String topic;
  final String _name;
  Message lastMessage;

  Subscription(this.topic, this._name, {this.lastMessage});

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      json['topic'],
      json['name'],
      lastMessage: json['last_message'] == null
          ? null
          : Message.fromJson(json['last_message']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Subscription &&
          runtimeType == other.runtimeType &&
          topic == other.topic;

  @override
  int get hashCode => topic.hashCode;

  bool isGroup() => topic.startsWith('grp');


  String get name {
    if (this.isGroup()) {
      return S.groupName(this._name);
    }
    return _name;
  }

  @override
  String toString() => topic;
}

class Topic {}

import 'dart:convert';

import 'package:resurgence/chat/shared_messages.dart';

abstract class ServerMessage {
  String id;

  ServerMessage();

  factory ServerMessage.parse(String payload) {
    Map<String, dynamic> json = jsonDecode(payload);

    if (json.keys.length != 1) {
      throw Exception('Malformed server message: $payload');
    }

    var key = json.keys.first;
    switch (key) {
      case 'data':
        return Data.fromJson(json['data']);
      case 'ctrl':
        return Ctrl.fromJson(json['ctrl']);
      case 'meta':
        return Meta.fromJson(json['meta']);
      case 'pres':
        return Pres.fromJson(json['pres']);
      case 'info':
        return Info.fromJson(json['info']);
      default:
        throw Exception('Unknown server message key: $key, message: $payload');
    }
  }
}

class Data extends ServerMessage {
  Data({
    this.topic,
    this.from,
    this.head,
    this.ts,
    this.seq,
    this.content,
  });

  final String topic;
  final String from;
  final Map<String, dynamic> head;
  final DateTime ts;
  final int seq;
  final String content;

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      topic: json["topic"] == null ? null : json["topic"],
      from: json["from"] == null ? null : json["from"],
      head: json["head"] == null ? null : json["head"],
      ts: json["ts"] == null ? null : DateTime.parse(json["ts"]),
      seq: json["seq"] == null ? null : json["seq"],
      // todo content may map
      content: json["content"] == null ? null : json["content"],
    );
  }

  @override
  String toString() {
    return 'Data{topic: $topic, from: $from, head: $head, ts: $ts, seq: $seq, content: $content}';
  }
}

class Ctrl extends ServerMessage {
  Ctrl({
    this.id,
    this.topic,
    this.code,
    this.text,
    this.params,
    this.ts,
  });

  final String id;
  final String topic;
  final int code;
  final String text;
  final Map<String, dynamic> params;
  final DateTime ts;

  factory Ctrl.fromJson(Map<String, dynamic> json) {
    return Ctrl(
      id: json["id"] == null ? null : json["id"],
      topic: json["topic"] == null ? null : json["topic"],
      code: json["code"] == null ? null : json["code"],
      text: json["text"] == null ? null : json["text"],
      params: json["params"] == null ? null : json["params"],
      ts: json["ts"] == null ? null : DateTime.parse(json["ts"]),
    );
  }

  @override
  String toString() {
    return 'Ctrl{id: $id, topic: $topic, code: $code, text: $text, params: $params, ts: $ts}';
  }
}

class Meta extends ServerMessage {
  Meta({
    this.id,
    this.topic,
    this.ts,
    this.desc,
    this.sub,
    this.tags,
    this.cred,
    this.del,
  });

  final String id;
  final String topic;
  final DateTime ts;
  final Desc desc;
  final List<Sub> sub;
  final List<String> tags;
  final List<Cred> cred;
  final _Del del;

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      id: json["id"] == null ? null : json["id"],
      topic: json["topic"] == null ? null : json["topic"],
      ts: json["ts"] == null ? null : DateTime.parse(json["ts"]),
      desc: json["desc"] == null ? null : Desc.fromJson(json["desc"]),
      sub: json["sub"] == null
          ? null
          : List<Sub>.from(json["sub"].map((x) => Sub.fromJson(x))),
      tags: json["tags"] == null
          ? null
          : List<String>.from(json["tags"].map((x) => x)),
      cred: json["cred"] == null
          ? null
          : List<Cred>.from(json["cred"].map((x) => Cred.fromJson(x))),
      del: json["del"] == null ? null : _Del.fromJson(json["del"]),
    );
  }

  @override
  String toString() {
    return 'Meta{id: $id, topic: $topic, ts: $ts, desc: $desc, sub: $sub, tags: $tags, cred: $cred, del: $del}';
  }
}

class Pres extends ServerMessage {
  Pres({
    this.topic,
    this.src,
    this.what,
    this.seq,
    this.clear,
    this.delseq,
    this.ua,
    this.act,
    this.tgt,
    this.acs,
  });

  final String topic;
  final String src;
  final String what;
  final int seq;
  final int clear;
  final List<Delseq> delseq;
  final String ua;
  final String act;
  final String tgt;
  final Acs acs;

  factory Pres.fromJson(Map<String, dynamic> json) {
    return Pres(
      topic: json["topic"] == null ? null : json["topic"],
      src: json["src"] == null ? null : json["src"],
      what: json["what"] == null ? null : json["what"],
      seq: json["seq"] == null ? null : json["seq"],
      clear: json["clear"] == null ? null : json["clear"],
      delseq: json["delseq"] == null
          ? null
          : List<Delseq>.from(json["delseq"].map((x) => Delseq.fromJson(x))),
      ua: json["ua"] == null ? null : json["ua"],
      act: json["act"] == null ? null : json["act"],
      tgt: json["tgt"] == null ? null : json["tgt"],
      acs: json["acs"] == null ? null : Acs.fromJson(json["acs"]),
    );
  }

  @override
  String toString() {
    return 'Pres{topic: $topic, src: $src, what: $what, seq: $seq, clear: $clear, delseq: $delseq, ua: $ua, act: $act, tgt: $tgt, acs: $acs}';
  }
}

class Info extends ServerMessage {
  Info({
    this.topic,
    this.from,
    this.what,
    this.seq,
  });

  final String topic;
  final String from;
  final String what;
  final int seq;

  factory Info.fromJson(Map<String, dynamic> json) {
    return Info(
      topic: json["topic"] == null ? null : json["topic"],
      from: json["from"] == null ? null : json["from"],
      what: json["what"] == null ? null : json["what"],
      seq: json["seq"] == null ? null : json["seq"],
    );
  }

  @override
  String toString() {
    return 'Info{topic: $topic, from: $from, what: $what, seq: $seq}';
  }
}

class _Del {
  _Del({
    this.clear,
    this.delseq,
  });

  final int clear;
  final List<Delseq> delseq;

  factory _Del.fromJson(Map<String, dynamic> json) {
    return _Del(
      clear: json["clear"] == null ? null : json["clear"],
      delseq: json["delseq"] == null
          ? null
          : List<Delseq>.from(json["delseq"].map((x) => Delseq.fromJson(x))),
    );
  }

  @override
  String toString() {
    return 'Del{clear: $clear, delseq: $delseq}';
  }
}

class Sub {
  Sub({
    this.user,
    this.updated,
    this.touched,
    this.acs,
    this.read,
    this.recv,
    this.clear,
    this.public,
//    this.private,
    this.online,
    this.topic,
    this.seq,
    this.seen,
  });

  final String user;
  final DateTime updated;
  final DateTime touched;
  final Acs acs;
  int read;
  final int recv;
  final int clear;
  final Public public;
//  final Private private;
  final bool online;
  String topic;
  final Seen seen;
  int seq;

  factory Sub.fromJson(Map<String, dynamic> json) {
    return Sub(
      user: json["user"] == null ? null : json["user"],
      updated: json["updated"] == null ? null : DateTime.parse(json["updated"]),
      touched: json["touched"] == null ? null : DateTime.parse(json["touched"]),
      acs: json["acs"] == null ? null : Acs.fromJson(json["acs"]),
      read: json["read"] == null ? 0 : json["read"],
      recv: json["recv"] == null ? 0 : json["recv"],
      clear: json["clear"] == null ? 0 : json["clear"],
      public: json["public"] == null ? null : Public.fromJson(json["public"]),
//      private:
//          json["private"] == null ? null : Private.fromJson(json["private"]),
      online: json["online"] == null ? false : json["online"],
      topic: json["topic"] == null ? null : json["topic"],
      seq: json["seq"] == null ? 0 : json["seq"],
      seen: json["seen"] == null ? null : Seen.fromJson(json["seen"]),
    );
  }

  @override
  String toString() {
    return 'Sub{user: $user, updated: $updated, touched: $touched, acs: $acs, read: $read, recv: $recv, clear: $clear, public: $public, online: $online, topic: $topic, seq: $seq, seen: $seen}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Sub && runtimeType == other.runtimeType && topic == other.topic;

  @override
  int get hashCode => topic.hashCode;
}

class Seen {
  Seen({
    this.when,
    this.ua,
  });

  final DateTime when;
  final String ua;

  factory Seen.fromJson(Map<String, dynamic> json) {
    return Seen(
      when: json["when"] == null ? null : DateTime.parse(json["when"]),
      ua: json["ua"] == null ? null : json["ua"],
    );
  }

  @override
  String toString() {
    return 'Seen{when: $when, ua: $ua}';
  }
}

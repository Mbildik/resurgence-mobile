import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:resurgence/chat/shared_messages.dart';
import 'package:resurgence/constants.dart';

String _hashUsername(String username) {
  var digest = sha1.convert(utf8.encode(username));
  var hash = digest.toString().substring(0, 15);
  return 's$hash';
}

String _generateUniqueKey() {
  Random random;
  try {
    random = Random.secure();
  } catch (e) {
    random = Random();
  }
  return base64Encode(List<int>.generate(9, (i) => random.nextInt(256)));
}

abstract class ClientMessage {
  static String _uniqueKey = _generateUniqueKey();
  static int _seq = 0;

  String id;

  String json() {
    var body = toJson();
    body.removeWhere((key, value) => value == null);

    if (this is! Note) {
      body['id'] = id = "${runtimeType}__${_uniqueKey}__${_seq++}";
    }

    return jsonEncode({name(): body});
  }

  String name();

  Map<String, dynamic> toJson();

  @override
  String toString() => '{$runtimeType: ${toJson()} ';
}

class Hi extends ClientMessage {
  Hi({
    this.ver,
    this.ua,
    this.dev,
    this.platf,
    this.lang,
  });

  final String ver;
  final String ua;
  final String dev;
  final String platf;
  final String lang;

  Map<String, dynamic> toJson() {
    return {
      "id": id == null ? null : id,
      "ver": ver == null ? S.version : ver,
      "ua": ua == null ? S.userAgent : ua,
      "dev": dev == null ? null : dev,
      "platf": platf == null ? Platform.operatingSystem : platf,
      "lang": lang == null ? null : lang,
    };
  }

  @override
  String name() => 'hi';
}

class Acc extends ClientMessage {
  Acc({
    this.user,
    this.token,
    this.status,
    this.scheme,
    this.secret,
    this.login,
    this.tags,
    this.cred,
    this.desc,
  });

  final String user;
  final String token;
  final String status;
  final String scheme;
  final String secret;
  final bool login;
  final List<String> tags;
  final List<Cred> cred;
  final Desc desc;

  factory Acc.basic(String username, String password) {
    String hashedUsername = _hashUsername(username);
    return Acc(
      scheme: 'basic',
      secret: base64Encode(utf8.encode('$hashedUsername:$password')),
      user: 'new',
      login: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id == null ? null : id,
      "user": user == null ? null : user,
      "token": token == null ? null : token,
      "status": status == null ? null : status,
      "scheme": scheme == null ? null : scheme,
      "secret": secret == null ? null : secret,
      "login": login == null ? null : login,
      "tags": tags == null ? null : List<dynamic>.from(tags.map((x) => x)),
      "cred":
          cred == null ? null : List<dynamic>.from(cred.map((x) => x.toJson())),
      "desc": desc == null ? null : desc.toJson(),
    };
  }

  @override
  String name() => 'acc';
}

class Login extends ClientMessage {
  Login({
    this.scheme,
    this.secret,
    this.cred,
  });

  final String scheme;
  final String secret;
  final List<Cred> cred;

  factory Login.basic(String username, String password) {
    String hashedUsername = _hashUsername(username);
    return Login(
      scheme: 'basic',
      secret: base64Encode(utf8.encode('$hashedUsername:$password')),
    );
  }

  factory Login.token(String token) => Login(scheme: 'token', secret: token);

  Map<String, dynamic> toJson() {
    return {
      "id": id == null ? null : id,
      "scheme": scheme == null ? null : scheme,
      "secret": secret == null ? null : secret,
      "cred":
          cred == null ? null : List<dynamic>.from(cred.map((x) => x.toJson())),
    };
  }

  @override
  String name() => 'login';
}

class Sub extends ClientMessage {
  Sub({
    this.topic,
    this.bkg,
    this.subSet,
    this.subGet,
  });

  final String topic;
  final bool bkg;
  final Set subSet;
  final Get subGet;

  Map<String, dynamic> toJson() {
    return {
      "id": id == null ? null : id,
      "topic": topic == null ? null : topic,
      "bkg": bkg == null ? null : bkg,
      "set": subSet == null ? null : subSet.toJson(),
      "get": subGet == null ? null : subGet.toJson(),
    };
  }

  @override
  String name() => 'sub';
}

class Leave extends ClientMessage {
  Leave({
    this.topic,
    this.unsub,
  });

  final String topic;
  final bool unsub;

  Map<String, dynamic> toJson() {
    return {
      "id": id == null ? null : id,
      "topic": topic == null ? null : topic,
      "unsub": unsub == null ? null : unsub,
    };
  }

  @override
  String name() => 'leave';
}

class Pub extends ClientMessage {
  Pub({
    this.topic,
    this.noecho,
    this.head,
    this.content,
  });

  final String topic;
  final bool noecho;
  final Map<String, dynamic> head;
  final String content;

  Map<String, dynamic> toJson() {
    return {
      "id": id == null ? null : id,
      "topic": topic == null ? null : topic,
      "noecho": noecho == null ? null : noecho,
      "head": head == null ? null : head,
      "content": content == null ? null : content,
    };
  }

  @override
  String name() => 'pub';
}

class Get extends ClientMessage {
  Get({
    this.topic,
    this.what,
    this.desc,
    this.sub,
    this.data,
    this.del,
  });

  final String topic;
  final String what;
  final Desc desc;
  final GetSub sub;
  final Data data;
  final Data del;

  Map<String, dynamic> toJson() {
    return {
      "id": id == null ? null : id,
      "topic": topic == null ? null : topic,
      "what": what == null ? null : what,
      "desc": desc == null ? null : desc.toJson(),
      "sub": sub == null ? null : sub.toJson(),
      "data": data == null ? null : data.toJson(),
      "del": del == null ? null : del.toJson(),
    };
  }

  @override
  String name() => 'get';
}

class Set extends ClientMessage {
  Set({
    this.topic,
    this.desc,
    this.sub,
    this.tags,
    this.cred,
  });

  final String topic;
  final SetDesc desc;
  final SetSub sub;
  final List<String> tags;
  final Cred cred;

  Map<String, dynamic> toJson() {
    return {
      "id": id == null ? null : id,
      "topic": topic == null ? null : topic,
      "desc": desc == null ? null : desc.toJson(),
      "sub": sub == null ? null : sub.toJson(),
      "tags": tags == null ? null : List<dynamic>.from(tags.map((x) => x)),
      "cred": cred == null ? null : cred.toJson(),
    };
  }

  @override
  String name() => 'set';
}

class Del extends ClientMessage {
  Del({
    this.topic,
    this.what,
    this.hard,
    this.delseq,
    this.user,
    this.cred,
  });

  final String topic;
  final String what;
  final bool hard;
  final List<Delseq> delseq;
  final String user;
  final Cred cred;

  Map<String, dynamic> toJson() {
    return {
      "id": id == null ? null : id,
      "topic": topic == null ? null : topic,
      "what": what == null ? null : what,
      "hard": hard == null ? null : hard,
      "delseq": delseq == null
          ? null
          : List<dynamic>.from(delseq.map((x) => x.toJson())),
      "user": user == null ? null : user,
      "cred": cred == null ? null : cred.toJson(),
    };
  }

  @override
  String name() => 'del';
}

class Note extends ClientMessage {
  Note({
    this.topic,
    this.what,
    this.seq,
    this.unread,
  });

  final String topic;
  final String what;
  final int seq;
  final int unread;

  Map<String, dynamic> toJson() {
    return {
      "topic": topic == null ? null : topic,
      "what": what == null ? null : what,
      "seq": seq == null ? null : seq,
      "unread": unread == null ? null : unread,
    };
  }

  @override
  String name() => 'note';
}

// data classes

class Data {
  Data({
    this.since,
    this.before,
    this.limit,
  });

  final int since;
  final int before;
  final int limit;

  Map<String, dynamic> toJson() {
    var json = {
      "since": since == null ? null : since,
      "before": before == null ? null : before,
      "limit": limit == null ? null : limit,
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }
}

class GetSub {
  GetSub({
    this.ims,
    this.user,
    this.topic,
    this.limit,
  });

  final DateTime ims;
  final String user;
  final String topic;
  final int limit;

  Map<String, dynamic> toJson() {
    var json = {
      "ims": ims == null ? null : ims.toIso8601String(),
      "user": user == null ? null : user,
      "topic": topic == null ? null : topic,
      "limit": limit == null ? null : limit,
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }
}

class SetDesc {
  SetDesc({
    this.defacs,
    this.public,
    this.publicString,
    this.private,
  });

  final Defacs defacs;
  final Public public;
  final String publicString;
  final Private private;

  Map<String, dynamic> toJson() {
    var json = {
      "defacs": defacs == null ? null : defacs.toJson(),
      "public": public == null ? publicString : public.toJson(),
      "private": private == null ? null : private.toJson(),
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }
}

class SetSub {
  SetSub({
    this.mode,
  });

  final String mode;

  Map<String, dynamic> toJson() {
    var json = {
      "mode": mode == null ? null : mode,
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }
}


class Public {
  Public({
    this.fn,
    this.n,
    this.org,
    this.title,
    this.tel,
    this.email,
    this.impp,
    this.photo,
  });

  final String fn;
  final N n;
  final String org;
  final String title;
  final List<Email> tel;
  final List<Email> email;
  final List<Email> impp;
  final Photo photo;

  factory Public.fromJson(Map<String, dynamic> json) {
    return Public(
      fn: json["fn"] == null ? null : json["fn"],
      n: json["n"] == null ? null : N.fromJson(json["n"]),
      org: json["org"] == null ? null : json["org"],
      title: json["title"] == null ? null : json["title"],
      tel: json["tel"] == null
          ? null
          : List<Email>.from(json["tel"].map((x) => Email.fromJson(x))),
      email: json["email"] == null
          ? null
          : List<Email>.from(json["email"].map((x) => Email.fromJson(x))),
      impp: json["impp"] == null
          ? null
          : List<Email>.from(json["impp"].map((x) => Email.fromJson(x))),
      photo: json["photo"] == null ? null : Photo.fromJson(json["photo"]),
    );
  }

  Map<String, dynamic> toJson() {
    var json = {
      "fn": fn == null ? null : fn,
      "n": n == null ? null : n.toJson(),
      "org": org == null ? null : org,
      "title": title == null ? null : title,
      "tel": tel == null ? null : tel.map((e) => e.toJson()).toList(),
      "email": email == null ? null : email.map((e) => e.toJson()).toList(),
      "impp": impp == null ? null : impp.map((e) => e.toJson()).toList(),
      "photo": photo == null ? null : photo.toJson(),
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }

  @override
  String toString() {
    return 'Public{fn: $fn, n: $n, org: $org, title: $title, tel: $tel, email: $email, impp: $impp, photo: $photo}';
  }
}

class Email {
  Email({
    this.type,
    this.uri,
  });

  final String type;
  final String uri;

  factory Email.fromJson(Map<String, dynamic> json) {
    return Email(
      type: json["type"] == null ? null : json["type"],
      uri: json["uri"] == null ? null : json["uri"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type == null ? null : type,
      "uri": uri == null ? null : uri,
    };
  }

  @override
  String toString() {
    return 'Email{type: $type, uri: $uri}';
  }
}

class N {
  N({
    this.surname,
    this.given,
    this.additional,
    this.prefix,
    this.suffix,
  });

  final String surname;
  final String given;
  final String additional;
  final String prefix;
  final String suffix;

  factory N.fromJson(Map<String, dynamic> json) {
    return N(
      surname: json["surname"] == null ? null : json["surname"],
      given: json["given"] == null ? null : json["given"],
      additional: json["additional"] == null ? null : json["additional"],
      prefix: json["prefix"] == null ? null : json["prefix"],
      suffix: json["suffix"] == null ? null : json["suffix"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "surname": surname == null ? null : surname,
      "given": given == null ? null : given,
      "additional": additional == null ? null : additional,
      "prefix": prefix == null ? null : prefix,
      "suffix": suffix == null ? null : suffix,
    };
  }

  @override
  String toString() {
    return 'N{surname: $surname, given: $given, additional: $additional, prefix: $prefix, suffix: $suffix}';
  }
}

class Photo {
  Photo({
    this.type,
    this.data,
  });

  final String type;
  final String data;

  factory Photo.fromJson(Map<String, dynamic> json) {
    return Photo(
      type: json["type"] == null ? null : json["type"],
      data: json["data"] == null ? null : json["data"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type == null ? null : type,
      "given": data == null ? null : data,
    };
  }

  @override
  String toString() {
    return 'Photo{type: $type, data: $data}';
  }
}

class Private {
  Private({
    this.comment,
    this.arch,
    this.accepted,
  });

  final String comment;
  final bool arch;
  final String accepted;

  factory Private.fromJson(Map<String, dynamic> json) {
    return Private(
      comment: json["comment"] == null ? null : json["comment"],
      arch: json["arch"] == null ? null : json["arch"],
      accepted: json["accepted"] == null ? null : json["accepted"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "comment": comment == null ? null : comment,
      "arch": arch == null ? null : arch,
      "accepted": accepted == null ? null : accepted,
    };
  }

  @override
  String toString() {
    return 'Private{comment: $comment, arch: $arch, accepted: $accepted}';
  }
}

class Defacs {
  Defacs({
    this.auth,
    this.anon,
  });

  final String auth;
  final String anon;

  factory Defacs.fromJson(Map<String, dynamic> json) {
    return Defacs(
      auth: json["auth"] == null ? null : json["auth"],
      anon: json["anon"] == null ? null : json["anon"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "auth": auth == null ? null : auth,
      "anon": anon == null ? null : anon,
    };
  }

  @override
  String toString() {
    return 'Defacs{auth: $auth, anon: $anon}';
  }
}

class Delseq {
  Delseq({
    this.low,
    this.hi,
  });

  final int low;
  final int hi;

  factory Delseq.fromJson(Map<String, dynamic> json) {
    return Delseq(
      low: json["low"] == null ? null : json["low"],
      hi: json["hi"] == null ? null : json["hi"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "low": low == null ? null : low,
      "hi": hi == null ? null : hi,
    };
  }

  @override
  String toString() {
    return 'Delseq{low: $low, hi: $hi}';
  }
}

class Desc {
  Desc({
    this.created,
    this.updated,
    this.status,
    this.defacs,
    this.acs,
    this.seq,
    this.read,
    this.recv,
    this.clear,
    this.public,
    this.private,
    this.ims,
  });

  final DateTime created;
  final DateTime updated;
  final String status;
  final Defacs defacs;
  final Acs acs;
  final int seq;
  final int read;
  final int recv;
  final int clear;
  final Public public;
  final Private private;
  final DateTime ims;

  factory Desc.fromJson(Map<String, dynamic> json) {
    return Desc(
      created: json["created"] == null ? null : DateTime.parse(json["created"]),
      updated: json["updated"] == null ? null : DateTime.parse(json["updated"]),
      status: json["status"] == null ? null : json["status"],
      defacs: json["defacs"] == null ? null : Defacs.fromJson(json["defacs"]),
      acs: json["acs"] == null ? null : Acs.fromJson(json["acs"]),
      seq: json["seq"] == null ? null : json["seq"],
      read: json["read"] == null ? null : json["read"],
      recv: json["recv"] == null ? null : json["recv"],
      clear: json["clear"] == null ? null : json["clear"],
      public: json["public"] == null ? null : Public.fromJson(json["public"]),
      private:
          json["private"] == null ? null : Private.fromJson(json["private"]),
      ims: json["ims"] == null ? null : DateTime.parse(json["ims"]),
    );
  }

  Map<String, dynamic> toJson() {
    var json = {
      "created": created == null ? null : created.toIso8601String(),
      "updated": updated == null ? null : updated.toIso8601String(),
      "status": status == null ? null : status,
      "defacs": defacs == null ? null : defacs.toJson(),
      "acs": acs == null ? null : acs.toJson(),
      "seq": seq == null ? null : seq,
      "read": read == null ? null : read,
      "recv": recv == null ? null : recv,
      "clear": clear == null ? null : clear,
      "public": public == null ? null : public.toJson(),
      "private": private == null ? null : private.toJson(),
      "ims": ims == null ? null : ims.toIso8601String(),
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }

  @override
  String toString() {
    return 'Desc{created: $created, updated: $updated, status: $status, defacs: $defacs, acs: $acs, seq: $seq, read: $read, recv: $recv, clear: $clear, public: $public, private: $private}';
  }
}

class Acs {
  Acs({
    this.want,
    this.given,
    this.mode,
  });

  final String want;
  final String given;
  final String mode;

  factory Acs.fromJson(Map<String, dynamic> json) {
    return Acs(
      want: json["want"] == null ? null : json["want"],
      given: json["given"] == null ? null : json["given"],
      mode: json["mode"] == null ? null : json["mode"],
    );
  }

  Map<String, dynamic> toJson() {
    var json = {
      "want": want == null ? null : want,
      "given": given == null ? null : given,
      "mode": mode == null ? null : mode,
    };
    json.removeWhere((key, value) => value == null);
    return json;
  }

  @override
  String toString() {
    return 'Acs{want: $want, given: $given, mode: $mode}';
  }
}

class Cred {
  Cred({
    this.meth,
    this.val,
    this.resp,
    this.params,
    this.done,
  });

  final String meth;
  final String val;
  final String resp;
  final Map<String, dynamic> params;
  final bool done;

  factory Cred.fromJson(Map<String, dynamic> json) {
    return Cred(
      meth: json["meth"] == null ? null : json["meth"],
      val: json["val"] == null ? null : json["val"],
      resp: json["resp"] == null ? null : json["resp"],
      params: json["params"] == null ? null : json["params"],
      done: json["done"] == null ? null : json["done"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "meth": meth == null ? null : meth,
      "val": val == null ? null : val,
      "resp": resp == null ? null : resp,
      "params": params == null ? null : params,
      "done": done == null ? null : done,
    };
  }

  @override
  String toString() => '{$runtimeType: ${toJson()} ';
}

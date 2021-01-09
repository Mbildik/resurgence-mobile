import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart' as mime;
import 'package:path/path.dart' as path;
import 'package:resurgence/enum.dart';
import 'package:resurgence/network/client.dart';
import 'package:resurgence/player/player.dart';
import 'package:resurgence/player/skills.dart';

class PlayerService {
  final _PlayerClient _client;

  PlayerService(Client client) : _client = _PlayerClient(client);

  Future<Player> info({String player}) => _client.info(player: player);

  Future<Player> create(String nickname, AbstractEnum race) {
    return _client.create(nickname, race).then((player) async {
      await _client.refreshToken();
      return player;
    });
  }

  Future<Player> editImage(File file) =>
      _client.editImage(file).then((_) => this.info());

  Future<List<Skill>> skills() => _client.skills();
}

class _PlayerClient {
  final Client _client;

  _PlayerClient(this._client);

  Future<void> refreshToken() => _client.refreshToken();

  Future<Player> info({String player}) {
    var path = 'player';
    if (player != null) path += '/$player';

    return _client.get(path).then((response) => Player.fromJson(response.data));
  }

  Future<Player> create(String nickname, AbstractEnum race) {
    return _client.post(
      'player',
      data: {'name': nickname, 'race': race.key},
    ).then((response) => Player.fromJson(response.data));
  }

  Future<void> editImage(File file) async {
    var filename = path.basename(file.path);
    var mimeType = mime.lookupMimeType(file.path);

    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
        filename: filename,
        contentType: MediaType.parse(mimeType),
      ),
    });
    return _client.post('player/image', data: formData);
  }

  Future<List<Skill>> skills() =>
      _client.get('skill').then((response) => (response.data as List)
          .map((e) => Skill.fromJson(e))
          .toList(growable: false));
}

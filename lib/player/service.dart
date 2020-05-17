import 'package:resurgence/enum.dart';
import 'package:resurgence/network/client.dart';
import 'package:resurgence/player/player.dart';

class PlayerService {
  final _PlayerClient _client;

  PlayerService(Client client) : _client = _PlayerClient(client);

  Future<Player> info() {
    return _client.info();
  }

  Future<Player> create(String nickname, AbstractEnum race) {
    return _client.create(nickname, race);
  }

  Future<List<AbstractEnum>> races() {
    return _client.races();
  }
}

class _PlayerClient {
  final Client _client;

  _PlayerClient(this._client);

  Future<Player> info() {
    return _client
        .get('player')
        .then((response) => Player.fromJson(response.data));
  }

  Future<Player> create(String nickname, AbstractEnum race) {
    return _client.post(
      'player',
      data: {'name': nickname, 'race': race.key},
    ).then((response) => Player.fromJson(response.data));
  }

  Future<List<AbstractEnum>> races() {
    return _client.get('player/races').then((response) {
      return (response.data as List)
          .map((e) => AbstractEnum.fromJson(e))
          .toList(growable: false);
    });
  }
}

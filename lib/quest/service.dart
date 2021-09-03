import 'package:resurgence/network/client.dart';
import 'package:resurgence/quest/quest.dart';

class QuestService {
  final _QuestClient _client;

  QuestService(Client client) : _client = _QuestClient(client);

  Future<List<QuestResponse>> all() => _client.all();

  Future<void> perform(int id) => _client.perform(id);
}

class _QuestClient {
  final Client _client;

  _QuestClient(this._client);

  Future<List<QuestResponse>> all() {
    return _client.get('quest').then((response) => (response.data as List)
        .map((e) => QuestResponse.fromJson(e))
        .toList(growable: false));
  }

  Future<void> perform(int id) => _client.post('quest', queryParameters: {'id': id});

}

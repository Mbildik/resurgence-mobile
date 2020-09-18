import 'package:resurgence/item/item.dart';
import 'package:resurgence/multiplayer-task/data.dart';
import 'package:resurgence/network/client.dart';

class MultiplayerService {
  final _MultiplayerClient _client;

  MultiplayerService(Client client) : _client = _MultiplayerClient(client);

  Future<List<MultiplayerTask>> all() => _client.allMultiplayer();

  Future<Plan> organize(MultiplayerTask task, List<PlayerItem> selectedItems) =>
      _client.organize(task, selectedItems);

  Future<Plan> plan() => _client.plan();

  Future<void> leave() => _client.leave();

  Future<List<MultiplayerTaskResult>> perform() => _client.perform();

  Future<void> add(Position position, String member) =>
      _client.add(position, member);

  Future<void> remove(String member) => _client.remove(member);

  Future<void> ready(List<PlayerItem> selectedItems) =>
      _client.ready(selectedItems);
}

class _MultiplayerClient {
  final Client _client;

  _MultiplayerClient(this._client);

  Future<List<MultiplayerTask>> allMultiplayer() {
    return _client.get('multiplayer-task').then((response) =>
        (response.data as List)
            .map((e) => MultiplayerTask.fromJson(e))
            .toList(growable: false));
  }

  Future<Plan> plan() => _client.get('plan').then((r) => Plan.fromJson(r.data));

  Future<Plan> organize(MultiplayerTask task, List<PlayerItem> selectedItems) {
    return _client.post('plan/${task.key}', data: {
      'selected_items':
          selectedItems.map((e) => e.toJson()).toList(growable: false),
    }).then((r) {
      return Plan.fromJson(r.data);
    });
  }

  Future<void> leave() => _client.delete('plan');

  Future<List<MultiplayerTaskResult>> perform() =>
      _client.post('plan').then((response) => (response.data as List)
          .map((e) => MultiplayerTaskResult.fromJson(e))
          .toList(growable: false));

  Future<void> add(Position position, String member) =>
      _client.post('plan/${position.key}/$member');

  Future<void> remove(String member) => _client.delete('plan/$member');

  Future<void> ready(List<PlayerItem> selectedItems) =>
      _client.patch('plan/ready', data: {
        'selected_items':
            selectedItems.map((e) => e.toJson()).toList(growable: false),
      });
}

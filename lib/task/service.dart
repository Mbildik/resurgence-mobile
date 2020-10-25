import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:resurgence/item/item.dart';
import 'package:resurgence/network/client.dart';
import 'package:resurgence/task/model.dart';

class TaskService {
  final _TaskClient _client;
  final FirebaseAnalytics analytics;

  TaskService(Client client, {this.analytics}) : _client = _TaskClient(client);

  Future<List<Task>> allTask() {
    return _client.allTask();
  }

  Future<TaskResult> perform(
    Task task, [
    List<PlayerItem> selectedItems = const [],
  ]) {
    return _client.perform(task.key, selectedItems).then((value) {
      analytics?.logEvent(name: 'perform_task', parameters: {'task': task.key});
      return value;
    });
  }
}

class _TaskClient {
  final Client _client;

  _TaskClient(this._client);

  Future<List<Task>> allTask() {
    return _client.get('task').then((response) => (response.data as List)
        .map((e) => Task.fromJson(e))
        .toList(growable: false));
  }

  Future<TaskResult> perform(String task, List<PlayerItem> selectedItems) {
    var selectedItemData = selectedItems
        .map((e) => {'item': e.item.key, 'quantity': e.quantity})
        .toList(growable: false);
    return _client.post('task/$task', data: {
      'selected_items': selectedItemData
    }).then((response) => TaskResult.fromJson(response.data));
  }
}

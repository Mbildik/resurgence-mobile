import 'package:resurgence/network/client.dart';
import 'package:resurgence/notification/model.dart';

class MessageService {
  final _MessageClient _client;

  MessageService(Client client) : _client = _MessageClient(client);

  Future<List<Message>> messages() => _client.messages();

  Future<void> delete(int id) => _client.delete(id);
}

class _MessageClient {
  final Client _client;

  _MessageClient(this._client);

  Future<void> refreshToken() => _client.refreshToken();

  Future<List<Message>> messages() =>
      _client.get('message').then((response) => (response.data as List)
          .map((e) => Message.fromJson(e))
          .toList(growable: false));

  Future<void> delete(int id) =>
      _client.delete('message', queryParameters: {'id': id});
}

import 'package:resurgence/chat/mail.dart';
import 'package:resurgence/network/client.dart';

class MailService {
  final _MailClient _client;

  MailService(Client client) : _client = _MailClient(client);

  Future<List<Mail>> incoming() {
    return _client.incoming();
  }

  Future<List<Mail>> outgoing() {
    return _client.outgoing();
  }

  Future<void> report(int mailId) {
    return _client.report(mailId);
  }

  Future<void> read(int mailId) {
    return _client.read(mailId);
  }

  Future<void> delete(int mailId) {
    return _client.delete(mailId);
  }

  Future<void> send(String to, String content) {
    return _client.send(to, content);
  }
}

class _MailClient {
  final Client _client;

  _MailClient(this._client);

  Future<List<Mail>> incoming() {
    return _client.get('mail/incoming').then((response) =>
        (response.data as List)
            .map((e) => Mail.fromJson(e))
            .toList(growable: false));
  }

  Future<List<Mail>> outgoing() {
    return _client.get('mail/outgoing').then((response) =>
        (response.data as List)
            .map((e) => Mail.fromJson(e))
            .toList(growable: false));
  }

  Future<void> report(int mailId) {
    return _client.post('mail/report/$mailId');
  }

  Future<void> read(int mailId) {
    return _client.post('mail/read/$mailId');
  }

  Future<void> delete(int mailId) {
    return _client.delete('mail/$mailId');
  }

  Future<void> send(String to, String content) {
    return _client.post('mail/$to', data: {'content': content});
  }
}

import 'package:dio/dio.dart';
import 'package:resurgence/family/family.dart';
import 'package:resurgence/network/client.dart';

class FamilyService {
  final _FamilyClient _client;

  FamilyService(Client client) : _client = _FamilyClient(client);

  Future<List<Family>> allFamily() {
    return _client.allFamily();
  }

  Future<Family> detail(String family) {
    return _client.detail(family);
  }

  Future<Family> info() {
    return _client.info().catchError((e) {
      if (e is DioError && e.response?.statusCode == 404) {
        return null;
      }
      throw e;
    });
  }

  Future<List<Announcement>> announcement({String family}) {
    return _client.announcement(family: family);
  }

  Future<FamilyBank> bank() {
    return _client.bank();
  }

  Future<List<FamilyBankLog>> bankLog() {
    return _client.bankLog();
  }

  Future<void> withdraw(int amount) {
    return _client.withdraw(amount);
  }

  Future<void> deposit(int amount) {
    return _client.deposit(amount);
  }

  Future<void> fire(String member) => _client.fire(member);

  Future<void> fireConsultant() => _client.fireConsultant();

  Future<void> fireChief(String chief) => _client.fireChief(chief);

  Future<void> makeConsultant(String consultant) =>
      _client.makeConsultant(consultant);

  Future<void> makeChief(String chief) => _client.makeChief(chief);

  Future<List<Invitation>> invitations() => _client.invitations();

  Future<void> accept(int id) => _client.accept(id);

  Future<void> cancel(int id) => _client.cancel(id);

  Future<void> assign(String chief, String member) =>
      _client.assign(chief, member);

  Future<void> discharge(String chief, String member) =>
      _client.discharge(chief, member);

  Future<void> saveAnnouncement(String title, String content, bool secret) =>
      _client.saveAnnouncement(title, content, secret);

  Future<void> editAnnouncement(
          int id, String title, String content, bool secret) =>
      _client.editAnnouncement(id, title, content, secret);

  Future<void> deleteAnnouncement(int id) => _client.deleteAnnouncement(id);

  Future<void> destroy() => _client.destroy();

  Future<void> apply(String family) => _client.apply(family);

  Future<void> leave() => _client.leave();

  Future<void> found(String name) => _client.found(name);
}

class _FamilyClient {
  final Client _client;

  _FamilyClient(this._client);

  Future<List<Family>> allFamily() {
    return _client.get('family/all').then((response) => (response.data as List)
        .map((e) => Family.fromJson(e))
        .toList(growable: false));
  }

  Future<Family> detail(String family) {
    return _client
        .get('family/$family')
        .then((response) => Family.fromJson(response.data));
  }

  Future<Family> info() =>
      _client.get('family').then((response) => Family.fromJson(response.data));

  Future<List<Announcement>> announcement({String family}) {
    var url =
        family != null ? 'family/announcement/$family' : 'family/announcement';
    return _client.get(url).then((response) => (response.data as List)
        .map((e) => Announcement.fromJson(e))
        .toList(growable: false));
  }

  Future<FamilyBank> bank() {
    return _client
        .get('family/bank')
        .then((response) => FamilyBank.fromJson(response.data));
  }

  Future<List<FamilyBankLog>> bankLog() {
    return _client.get('family/bank/log').then((response) =>
        (response.data as List)
            .map((e) => FamilyBankLog.fromJson(e))
            .toList(growable: false));
  }

  Future<void> withdraw(int amount) {
    return _client.post('family/bank/withdraw/$amount');
  }

  Future<void> deposit(int amount) {
    return _client.post('family/bank/deposit/$amount');
  }

  Future<void> fire(String member) => _client.delete('family/hr/fire/$member');

  Future<void> fireConsultant() => _client.delete('family/consultant');

  Future<void> fireChief(String chief) => _client.delete('family/chief/$chief');

  Future<void> makeConsultant(String consultant) =>
      _client.post('family/consultant/$consultant');

  Future<void> makeChief(String chief) => _client.post('family/chief/$chief');

  Future<List<Invitation>> invitations() =>
      _client.get('family/hr').then((response) => (response.data as List)
          .map((e) => Invitation.fromJson(e))
          .toList(growable: false));

  Future<void> accept(int id) => _client.post('family/hr/accept/$id');

  Future<void> cancel(int id) => _client.delete('family/hr/cancel/$id');

  Future<void> assign(String chief, String member) =>
      _client.post('family/chief/member/$chief/$member');

  Future<void> discharge(String chief, String member) =>
      _client.delete('family/chief/member/$chief/$member');

  Future<void> saveAnnouncement(String title, String content, bool secret) =>
      _client.post('family/announcement', data: {
        'title': title,
        'content': content,
        'secret': secret,
      });

  Future<void> editAnnouncement(
          int id, String title, String content, bool secret) =>
      _client.patch('family/announcement/$id', data: {
        'title': title,
        'content': content,
        'secret': secret,
      });

  Future<void> deleteAnnouncement(int id) =>
      _client.delete('family/announcement/$id');

  Future<void> destroy() => _client.delete('family/hr/destroy');

  Future<void> apply(String family) =>
      _client.post('family/hr/application/$family');

  Future<void> leave() => _client.delete('family/hr/leave');

  Future<void> found(String name) => _client.post('family/found/$name');
}

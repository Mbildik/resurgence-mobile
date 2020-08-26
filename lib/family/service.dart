import 'package:resurgence/family/family.dart';
import 'package:resurgence/network/client.dart';

class FamilyService {
  final _FamilyClient _client;

  FamilyService(Client client) : _client = _FamilyClient(client);

  Future<List<Family>> allFamily() {
    return _client.allFamily();
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
}

class _FamilyClient {
  final Client _client;

  _FamilyClient(this._client);

  Future<List<Family>> allFamily() {
    return _client.get('family/all').then((response) => (response.data as List)
        .map((e) => Family.fromJson(e))
        .toList(growable: false));
  }

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
}

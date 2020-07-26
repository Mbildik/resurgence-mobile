import 'package:resurgence/family/family.dart';
import 'package:resurgence/network/client.dart';

class FamilyService {
  final _FamilyClient _client;

  FamilyService(Client client) : _client = _FamilyClient(client);

  Future<List<Family>> allFamily() {
    return _client.allFamily();
  }
}

class _FamilyClient {
  final Client _client;

  _FamilyClient(this._client);

  Future<List<Family>> allFamily() {
    return _client.get('family/all').then((response) =>
        (response.data as List)
            .map((e) => Family.fromJson(e))
            .toList(growable: false));
  }
}

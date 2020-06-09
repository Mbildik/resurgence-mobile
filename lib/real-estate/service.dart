import 'package:resurgence/network/client.dart';
import 'package:resurgence/real-estate/read_estate.dart';

class RealEstateService {
  final _RealEstateClient _client;

  RealEstateService(Client client) : _client = _RealEstateClient(client);

  Future<List<RealEstate>> all() {
    return _client.all();
  }

  Future<void> buy(Building building) {
    return _client.buy(building.key);
  }

  Future<void> sell(Building building) {
    return _client.sell(building.key);
  }
}

class _RealEstateClient {
  final Client _client;

  _RealEstateClient(this._client);

  Future<List<RealEstate>> all() {
    return _client.get('real-estate').then((response) => (response.data as List)
        .map((e) => RealEstate.fromJson(e))
        .toList(growable: false));
  }

  Future<void> buy(String building) {
    return _client.post('real-estate/$building');
  }

  Future<void> sell(String building) {
    return _client.delete('real-estate/$building');
  }
}

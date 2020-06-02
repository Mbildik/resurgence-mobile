import 'package:resurgence/enum.dart';
import 'package:resurgence/item/item.dart';
import 'package:resurgence/network/client.dart';

class ItemService {
  final _ItemClient _client;

  ItemService(Client client) : _client = _ItemClient(client);

  Future<List<PlayerItem>> allItem({List<AbstractEnum> categories}) {
    return _client.allItem(categories: categories);
  }
}

class _ItemClient {
  final Client _client;

  _ItemClient(this._client);

  Future<List<PlayerItem>> allItem({List<AbstractEnum> categories}) {
    var queryParameters = {
      'categories': categories.map((e) => e.key).join(',')
    };

    return _client.get('npc', queryParameters: queryParameters).then(
        (response) => (response.data as List)
            .map((e) => PlayerItem.fromJson(e))
            .toList(growable: false));
  }
}

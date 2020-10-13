import 'package:resurgence/enum.dart';
import 'package:resurgence/item/item.dart';
import 'package:resurgence/network/client.dart';

class ItemService {
  final _ItemClient _client;

  ItemService(Client client) : _client = _ItemClient(client);

  Future<List<PlayerItem>> allItem({List<AbstractEnum> categories}) {
    return _client.allItem(categories: categories);
  }

  Future<List<Item>> counter() => _client.counter();

  Future<void> buy(Map<Item, int> items) => _client.buy(items);
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

  Future<List<Item>> counter() =>
      _client.get('npc/counter').then((response) => (response.data as List)
          .map((e) => Item.fromJson(e))
          .toList(growable: false));

  Future<void> buy(Map<Item, int> items) {
    var data = [];
    items.forEach(
      (item, quantity) => data.add(
        {'item': item.key, 'quantity': quantity},
      ),
    );
    return _client.post('npc', data: data);
  }
}

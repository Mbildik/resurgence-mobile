import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/item/item.dart';
import 'package:resurgence/item/service.dart';
import 'package:resurgence/money.dart';
import 'package:resurgence/player/player.dart';
import 'package:resurgence/player/service.dart';
import 'package:resurgence/ui/error_handler.dart';
import 'package:resurgence/ui/shared.dart';

typedef OnItemTap = void Function(Item item);

class NPCCounter extends StatefulWidget {
  @override
  _NPCCounterState createState() => _NPCCounterState();
}

class _NPCCounterState extends State<NPCCounter> {
  final Map<Item, int> _basket = {};

  bool _disableLoading = false;
  bool _buying = false;
  bool _buyCompleted = false;

  Future<List<Item>> _itemsFuture;
  ItemService _service;
  Timer _timer;
  PlayerService _playerService;
  PlayerState _playerState;

  @override
  void initState() {
    super.initState();
    _service = context.read<ItemService>();
    _itemsFuture = _service.counter();
    _playerService = context.read<PlayerService>();
    _playerState = context.read<PlayerState>();
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      setState(() {
        _disableLoading = true;
        _itemsFuture = _service.counter().then((items) {
          bool isUpdated = false;
          _basket.keys.forEach((item) {
            var updated = items.firstWhere(
              (i) => i == item,
              orElse: () => null,
            );
            if (updated != null) {
              item.price = updated.price;
              isUpdated = true;
            }
          });
          if (isUpdated) setState(() {});
          return items;
        });
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.npc),
        actions: [
          Tooltip(
            message: S.help,
            child: IconButton(
              icon: Icon(Icons.help),
              onPressed: () {
                showHelpDialog(
                  context: context,
                  title: S.npc,
                  content: S.npcHelp,
                );
              },
            ),
          )
        ],
      ),
      body: LoadingFutureBuilder<List<Item>>(
        future: _itemsFuture,
        onError: _refresh,
        disableLoading: _disableLoading,
        builder: (context, snapshot) {
          var items = snapshot.data;

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: _ItemListView(items: items, onTap: _add),
                ),
              ),
              Card(
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: _BasketListView(
                          height: 50,
                          basket: _basket,
                          onTap: _remove,
                          onLongPress: _removeAll,
                        ),
                      ),
                      _buying
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            )
                          : _buyCompleted
                              ? Icon(Icons.done, color: Colors.green[700])
                              : RaisedButton(
                                  child: Text(
                                      Money.format(_price()) + '\n' + S.buy),
                                  color: Colors.green[700],
                                  onPressed: _basket.isNotEmpty ? buy : null,
                                ),
                      const SizedBox(width: 8.0),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _add(Item item) {
    var quantity = _basket[item];
    if (quantity == null) {
      _basket[item] = 1;
    } else {
      _basket[item]++;
    }
    setState(() {});
  }

  void _remove(Item item, {int amount: 1}) {
    if (_basket.containsKey(item)) {
      var quantity = _basket[item];
      if (quantity <= 1 || amount >= quantity)
        _basket.remove(item);
      else
        _basket[item] -= amount;
      setState(() {});
    }
  }

  void _removeAll(Item item) {
    var quantity = _basket[item];
    if (quantity != null) _remove(item, amount: quantity);
  }

  int _price() => _basket.entries
      .map((e) => e.key.price * e.value)
      .fold(0, (a, b) => a + b);

  void buy() {
    setState(() => _buying = true);
    _service.buy(_basket).then((_) {
      _basket.clear();
      _buyCompleted = true;
      Timer.periodic(Duration(seconds: 1), (timer) {
        timer.cancel();
        if (mounted) setState(() => _buyCompleted = false);
      });
    }).whenComplete(() {
      setState(() => _buying = false);
      _playerService.info().then((player) => _playerState.updatePlayer(player));
    }).catchError((e) => ErrorHandler.showError(context, e));
  }

  Future<List<Item>> _refresh() {
    var future = _service.counter();
    setState(() {
      _itemsFuture = future;
    });
    return future;
  }
}

class _ItemListView extends StatelessWidget {
  final List<Item> items;
  final OnItemTap onTap;

  const _ItemListView({
    Key key,
    @required this.items,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: this.items.length,
      itemBuilder: (context, index) {
        var item = this.items[index];

        return ListTile(
          leading: Image.network(
            item.image,
            height: 72,
            width: 72,
          ),
          title: Text(
            item.value,
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(color: item.quality.color(), fontSize: 16.0),
          ),
          subtitle: Text(
            item.category.map((c) => c.value).join(', '),
          ),
          trailing: Text(Money.format(item.price)),
          onTap: () => this.onTap(item),
        );
      },
    );
  }
}

class _BasketListView extends StatelessWidget {
  final double height;
  final Map<Item, int> basket;
  final OnItemTap onTap;
  final OnItemTap onLongPress;

  const _BasketListView({
    Key key,
    this.height = 50,
    @required this.basket,
    @required this.onTap,
    @required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: this.basket.length,
      shrinkWrap: true,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        var item = this.basket.keys.elementAt(index);
        var quantity = this.basket.values.elementAt(index);
        return GestureDetector(
          onTap: () => this.onTap(item),
          onLongPress: () => this.onLongPress(item),
          child: Stack(
            children: [
              Image.network(
                item.image,
                width: this.height,
                height: this.height,
              ),
              Positioned(
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Center(child: Text('$quantity')),
                  decoration: new BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class NPCCounterRoute<T> extends MaterialPageRoute<T> {
  NPCCounterRoute() : super(builder: (BuildContext context) => NPCCounter());
}

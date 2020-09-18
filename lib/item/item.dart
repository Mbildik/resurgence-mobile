import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/enum.dart';
import 'package:resurgence/item/service.dart';
import 'package:resurgence/task/task.dart';

class Item extends AbstractEnum {
  Set<AbstractEnum> category;
  int price;

  Item({String key, String value, this.category, this.price})
      : super(key: key, value: value);

  Item.fromJson(Map<String, dynamic> json) {
    var abstractEnum = AbstractEnum.fromJson(json);
    key = abstractEnum.key;
    value = abstractEnum.value;
    if (json['category'] != null) {
      category = (json['category'] as List)
          .map((e) => AbstractEnum.fromJson(e))
          .toSet();
    }
    price = json['price'];
  }
}

class PlayerItem {
  Item item;
  int quantity;

  PlayerItem({this.item, this.quantity});

  PlayerItem.fromJson(Map<String, dynamic> json) {
    item = Item.fromJson(json['item']);
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() => {
        "item": item == null ? null : item.key,
        "quantity": quantity == null ? null : quantity,
      };
}

class SelectedPlayerItemState extends ChangeNotifier {
  final Task task;
  final List<PlayerItem> playerItems;
  final Map<Item, int> _selectedPlayerItem = {};

  SelectedPlayerItemState(this.task, this.playerItems);

  void update(Item item, int quantity) {
    _selectedPlayerItem[item] = quantity;
    notifyListeners();
  }

  void remove(Item item) {
    _selectedPlayerItem.remove(item);
    notifyListeners();
  }

  List<PlayerItem> get selectedPlayerItem {
    return _selectedPlayerItem.entries
        .map((e) => PlayerItem(item: e.key, quantity: e.value))
        .toList(growable: false);
  }

  int _selectedCategoriesCount(Set<AbstractEnum> categories) {
    return categories
        .map((category) => selectedPlayerItem
            .where((playerItem) => playerItem.item.category.contains(category))
            .map((playerItem) => playerItem.quantity)
            .fold(0, (prev, curr) => prev + curr))
        .fold(0, (prev, curr) => prev + curr);
  }

  bool canAdd(Item item) {
    int neededItemCount = _needItemCount(item);
    return _selectedCategoriesCount(item.category) < neededItemCount;
  }

  int _needItemCount(Item item) {
    return item.category
        .map((category) => task.requiredItemCategory
            .where((reqItemCat) => reqItemCat.category == category)
            .map((reqItemCat) => reqItemCat.quantity)
            .fold(0, (prev, curr) => prev + curr))
        .fold(0, (prev, curr) => prev + curr);
  }

  int maxAmount(Item item) {
    int selectedCount = _selectedCategoriesCount(item.category);
    int neededCount = _needItemCount(item);
    int maxAmount = neededCount - selectedCount;
    if (maxAmount < 0) return 0;
    return maxAmount;
  }

  bool isMeet() {
    if (task.requiredItemCategory.isEmpty) return true;
    if (selectedPlayerItem.isEmpty) return false;

    var totalRequiredCategoryCount = task.requiredItemCategory
        .map((e) => e.quantity)
        .reduce((a, b) => a + b);
    var totalSelectedItemCount =
        selectedPlayerItem.map((e) => e.quantity).reduce((a, b) => a + b);

    if (totalRequiredCategoryCount != totalSelectedItemCount) return false;

    var selectedRequiredCategories = selectedPlayerItem
        .map((si) => si.item.category.map((category) =>
            RequiredItemCategory(category: category, quantity: si.quantity)))
        .expand((e) => e)
        .toList(growable: false);

    var requires = Set.of(task.requiredItemCategory);
    requires.removeWhere((req) {
      var count = selectedRequiredCategories
          .where((element) => element.category == req.category)
          .map((e) => e.quantity)
          .reduce((a, b) => a + b);

      return req.quantity == count;
    });

    return requires.isEmpty;
  }
}

class ItemListPage extends StatefulWidget {
  final Task task;

  const ItemListPage({Key key, this.task}) : super(key: key);

  @override
  _ItemListPageState createState() => _ItemListPageState();
}

class _ItemListPageState extends State<ItemListPage> {
  Future<List<PlayerItem>> playerItemFuture;

  @override
  void initState() {
    super.initState();
    playerItemFuture = retrieveItems();
  }

  Future<List<PlayerItem>> retrieveItems() =>
      context.read<ItemService>().allItem(
            categories: widget.task.requiredItemCategory
                .map((e) => e.category)
                .toList(growable: false),
          );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<PlayerItem>>(
        future: playerItemFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return _onPlayerItemFetchError();
          }

          var playerItems = snapshot.data;

          if (playerItems.isEmpty) {
            return _emptyPlayerItemWidget();
          }

          var requiredCategoryTextList = widget.task.requiredItemCategory
              .map((e) => Text('${e.category.value}: ${e.quantity}'))
              .toList(growable: false);

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.white30, width: 2.0),
              ),
              color: Colors.blueGrey,
              child: ChangeNotifierProvider(
                create: (context) => SelectedPlayerItemState(
                  widget.task,
                  playerItems,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Wrap(
                        direction: Axis.vertical,
                        children: requiredCategoryTextList,
                      ),
                    ),
                    ListView.builder(
                      primary: false,
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: playerItems.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Color(0xFF28474A),
                          child: ItemListTile(playerItems[index]),
                        );
                      },
                    ),
                    _footer(context),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _emptyPlayerItemWidget() {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.white30, width: 2.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(S.playerItemEmpty),
      ),
    );
  }

  Widget _footer(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        IconButton(
          onPressed: () => Navigator.pop<List<PlayerItem>>(
            context,
            null,
          ),
          color: Colors.red,
          icon: Icon(Icons.close),
        ),
        Builder(
          builder: (context) {
            return Consumer<SelectedPlayerItemState>(
              builder: (context, state, child) {
                if (!state.isMeet()) {
                  return IconButton(
                    onPressed: null,
                    color: Colors.green,
                    icon: Icon(Icons.done),
                  );
                }
                return child;
              },
              child: IconButton(
                onPressed: () => Navigator.pop<List<PlayerItem>>(
                  context,
                  context.read<SelectedPlayerItemState>().selectedPlayerItem,
                ),
                color: Colors.green,
                icon: Icon(Icons.done),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _onPlayerItemFetchError() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(S.errorOccurred),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () => setState(() {
                playerItemFuture = retrieveItems();
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class ItemListTile extends StatefulWidget {
  final PlayerItem playerItem;

  const ItemListTile(this.playerItem, {Key key}) : super(key: key);

  @override
  _ItemListTileState createState() => _ItemListTileState();
}

class _ItemListTileState extends State<ItemListTile> {
  int quantity = 0;
  int maxQuantity;

  @override
  void initState() {
    super.initState();
    maxQuantity = widget.playerItem.quantity ?? 0;
  }

  bool _canAdd(SelectedPlayerItemState state) {
    return quantity < maxQuantity && state.canAdd(widget.playerItem.item);
  }

  void _increase({int amount = 1}) {
    var selectedPlayerItemState = context.read<SelectedPlayerItemState>();
    if (!_canAdd(selectedPlayerItemState)) return;

    var nextQuantity = quantity + amount;
    selectedPlayerItemState.update(widget.playerItem.item, nextQuantity);
    setState(() => quantity = nextQuantity);
  }

  void _decrease() {
    var selectedPlayerItemState = context.read<SelectedPlayerItemState>();

    if (quantity <= 0) {
      selectedPlayerItemState.remove(widget.playerItem.item);
      return;
    }

    var nextQuantity = quantity - 1;
    if (nextQuantity == 0) {
      selectedPlayerItemState.remove(widget.playerItem.item);
    } else {
      selectedPlayerItemState.update(widget.playerItem.item, nextQuantity);
    }
    setState(() => quantity = nextQuantity);
  }

  @override
  Widget build(BuildContext context) {
    var item = widget.playerItem.item;
    var category = item.category;
    return ListTile(
      leading: Image.asset(A.bankLogo),
      title: Text(item.value + ' (${widget.playerItem.quantity})'),
      subtitle: Text(category.isNotEmpty ? category.first.value : 'Empty'),
      trailing: Container(
        width: 64,
        child: Row(
          children: <Widget>[
            Expanded(
              child: IconButton(
                color: Colors.red,
                padding: EdgeInsets.zero,
                icon: Icon(Icons.remove),
                onPressed: quantity > 0 ? this._decrease : null,
              ),
            ),
            Expanded(
              // todo refactor trailing. get rid of container width
              child: Center(child: FittedBox(child: Text('$quantity'))),
            ),
            Consumer<SelectedPlayerItemState>(
              builder: (context, state, child) {
                return Expanded(
                  child: GestureDetector(
                    onLongPress: () => _increase(
                        amount: state.maxAmount(widget.playerItem.item)),
                    child: IconButton(
                      color: Colors.green,
                      padding: EdgeInsets.zero,
                      icon: Icon(Icons.add),
                      onPressed: _canAdd(state) ? this._increase : null,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ItemListPageRoute<T> extends PageRouteBuilder<T> {
  final Task task;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => Colors.black38;

  ItemListPageRoute(this.task)
      : super(
            pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) =>
                new ItemListPage(task: task));

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }
}

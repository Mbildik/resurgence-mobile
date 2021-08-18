import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/enum.dart';
import 'package:resurgence/item/item.dart';
import 'package:resurgence/item/service.dart';
import 'package:resurgence/ui/shared.dart';

class Inventory extends StatefulWidget {
  const Inventory({Key key}) : super(key: key);

  @override
  _InventoryState createState() => _InventoryState();
}

class _InventoryState extends State<Inventory> {
  final allCategories = [
    // todo server side
    AbstractEnum(key: 'MELEE'),
    AbstractEnum(key: 'WEAPON'),
    AbstractEnum(key: 'VEHICLE'),
    AbstractEnum(key: 'MONEY'),
    AbstractEnum(key: 'BULLET'),
    AbstractEnum(key: 'GUARD'),
    AbstractEnum(key: 'HEALTH'),
  ];

  ItemService _itemService;
  Future<List<PlayerItem>> _items;

  @override
  void initState() {
    super.initState();
    this._itemService = context.read<ItemService>();
    this._items = this._itemService.allItem(categories: this.allCategories);
  }

  Future<List<PlayerItem>> _refresh() {
    var items = _itemService.allItem(categories: this.allCategories);
    setState(() {
      this._items = items;
    });
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inventory'),
      ),
      body: LoadingFutureBuilder<List<PlayerItem>>(
        future: this._items,
        onError: this._refresh,
        builder: (context, snapshot) {
          var items = snapshot.data;

          return Column(
            children: [
              Row(
                children: [],
              ),
              _InventoryListView(items: items, onRefresh: this._refresh),
            ],
          );
        },
      ),
    );
  }
}

class _InventoryListView extends StatelessWidget {
  _InventoryListView({
    Key key,
    @required this.items,
    @required this.onRefresh,
  }) : super(key: key);

  final List<PlayerItem> items;
  final RefreshCallback onRefresh;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: this.onRefresh,
      child: AnimatedList(
        key: _listKey,
        shrinkWrap: true,
        initialItemCount: items.length,
        itemBuilder: (context, index, animation) {
          var item = items[index];
          animation.drive(IntTween(begin: 1, end: 2));
          return _InventoryListTile(item: item, index: index);
        },
      ),
    );
  }

/*void test() {
    _listKey.currentState.insertItem(1);
    _listKey.currentState.removeItem(1, (context, animation) {
      return _InventoryListTile(item: this.items[1]);
    });
  }*/
}

class _InventoryListTile extends StatefulWidget {
  const _InventoryListTile({
    Key key,
    @required this.item,
    @required this.index,
  }) : super(key: key);

  final PlayerItem item;
  final int index;

  @override
  __InventoryListTileState createState() => __InventoryListTileState();
}

class __InventoryListTileState extends State<_InventoryListTile> {
  @override
  Widget build(BuildContext context) {
    // final onTap = widget.item.item.usable ? this._useItem : null;
    final onTap = this._showItemDetail;

    return ListTile(
      leading: _ItemImage(item: widget.item.item),
      title: Text(
        widget.item.item.value,
        style: TextStyle(color: widget.item.item.quality.color()),
      ),
      subtitle: Text(widget.item.quantity.toString()),
      trailing: Text(widget.item.item.categoryHumanReadable()),
      onTap: onTap,
    );
  }

  void _useItem() {
    var itemService = context.read<ItemService>();
    itemService.use(widget.item.item).then((iur) {
      _showItemUsedSnackbar(iur.used);
      if (iur.used) {
        setState(() {
          widget.item.quantity--;
          if (widget.item.quantity <= 0) {
            AnimatedList.of(context).removeItem(
                widget.index, (c, a) => _slideIt(c, widget.index, a));
          }
        });
      }
    });
  }

  void _showItemUsedSnackbar(bool result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: _ItemUsageContainer(
          message: result
              ? '${widget.item.item.value} kullanıldı.'
              : 'Bunu şu an kullanamazsın.',
        ),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.transparent,
      ),
    );
  }

  Widget _slideIt(BuildContext context, int index, animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1, 0),
        end: Offset(0, 0),
      ).animate(animation),
      child: this.widget,
    );
  }

  void _showItemDetail() {
    var playerItem = widget.item;
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return _ItemDescriptionView(item: playerItem);
      },
    );
/*    Scaffold.of(context).showBottomSheet((context) {
      return Container(
        child: Card(
          child: Text('Item Description'),
        ),
      );
    });*/
  }
}

class _ItemDescriptionView extends StatelessWidget {
  //todo https://tr.pinterest.com/pin/427560558347753212/visual-search/
  const _ItemDescriptionView({
    Key key,
    @required this.item,
  }) : super(key: key);

  final PlayerItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      child: Card(
        child: Column(
          children: [
            Row(
              children: [
                _ItemImage(item: item.item),
                Column(
                  children: [
                    Text(
                      item.item.value,
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ItemUsageContainer extends StatelessWidget {
  const _ItemUsageContainer({
    Key key,
    @required this.message,
  }) : super(key: key);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Card(
        child: Center(
          child: Text(this.message),
        ),
      ),
    );
  }
}

class _ItemImage extends StatelessWidget {
  const _ItemImage({
    Key key,
    @required this.item,
  }) : super(key: key);

  final Item item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        border: Border.all(color: item.quality.color(), width: 3.0),
        borderRadius: BorderRadius.circular(8.0),
        color: const Color(0xffd6bd95),
      ),
      child: Image.network(item.image, height: 64.0, width: 64.0),
    );
  }
}

/*
var children = items.map((item) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: item.item.quality.color()),
              ),
              child: Column(
                children: [
                  Image.network(
                    item.item.image,
                    height: 64.0,
                    width: 64.0,
                  ),
                  Text(item.item.value),
                  Text(item.quantity.toString()),
                  Text(item.item.categoryHumanReadable()),
                ],
              ),
            );
          }).toList(growable: false);

          return GridView.count(
            crossAxisSpacing: 4.0,
            mainAxisSpacing: 4.0,
            crossAxisCount: 2,
            children: children,
          );
 */

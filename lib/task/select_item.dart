import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/enum.dart';
import 'package:resurgence/item/item.dart';
import 'package:resurgence/item/service.dart';
import 'package:resurgence/task/model.dart';
import 'package:resurgence/task/service.dart';
import 'package:resurgence/ui/shared.dart';

class SelectedItem {
  final Item item;
  final int quantity;

  SelectedItem(this.item, this.quantity)
      : assert(item != null),
        assert(quantity > 0);

  Set<AbstractEnum> get categories {
    return item.category;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelectedItem &&
          runtimeType == other.runtimeType &&
          item == other.item &&
          quantity == other.quantity;

  @override
  int get hashCode => item.hashCode ^ quantity.hashCode;
}

class SelectItemsModal extends StatefulWidget {
  final Task task;

  const SelectItemsModal(
    this.task, {
    Key key,
  }) : super(key: key);

  @override
  _SelectItemsModalState createState() => _SelectItemsModalState();
}

class _SelectItemsModalState extends State<SelectItemsModal> {
  ItemService _service;
  List<AbstractEnum> _requiredCats;
  Future<List<PlayerItem>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _service = context.read<ItemService>();
    _requiredCats = widget.task.requiredItemCategory
        .map((e) => e.category)
        .toList(growable: false);
    _itemsFuture = _service.allItem(categories: _requiredCats);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PlayerItem>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          } else if (snapshot.hasError) {
            return _onPlayerItemFetchError();
          }

          var playerItems = snapshot.data;

          if (playerItems.isEmpty) {
            return Center(
              child: EmptyPlayerItem(
                categories: widget.task.requiredItemCategory,
              ),
            );
          }

          return SelectItems(widget.task, playerItems: playerItems);
        });
  }

  void _retrieveItems() {
    setState(() {
      _itemsFuture = _service.allItem(categories: _requiredCats);
    });
  }

  Widget _onPlayerItemFetchError() {
    return Center(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(S.errorOccurred),
              Tooltip(
                message: S.refresh,
                child: IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _retrieveItems,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectItems extends StatefulWidget {
  final Task task;
  final List<PlayerItem> playerItems;

  const SelectItems(
    this.task, {
    Key key,
    @required this.playerItems,
  })  : assert(playerItems != null && playerItems.length > 0),
        super(key: key);

  @override
  _SelectItemStates createState() => _SelectItemStates();
}

class _SelectItemStates extends State<SelectItems> {
  final Map<Item, int> _selectedItems = HashMap();
  final Map<AbstractEnum, int> _requiredCategories = HashMap();

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.task.requiredItemCategory.forEach(
      (rc) => _requiredCategories[rc.category] = rc.quantity,
    );
  }

  @override
  Widget build(BuildContext context) {
    var playerItem = widget.playerItems[_selectedIndex].item;
    return Center(
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.keyboard_arrow_left),
                onPressed: _selectedIndex > 0
                    ? () => setState(() => _selectedIndex -= 1)
                    : null,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SelectableItem(
                      playerItem,
                      quantity: _quantity(playerItem),
                      have: _have(playerItem) - _quantity(playerItem),
                      onAddPressed: this._addable(playerItem)
                          ? () => this._add(playerItem)
                          : null,
                      onAddLongPress: this._addable(playerItem)
                          ? () => this._add(playerItem, _maxAddable(playerItem))
                          : null,
                      onRemovePressed: this._removable(playerItem)
                          ? () => this._remove(playerItem)
                          : null,
                      onRemoveLongPress: this._removable(playerItem)
                          ? () => this._removeAll(playerItem)
                          : null,
                    ),
                    ..._requiredCategories.entries.map((e) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            e.key.value,
                            textAlign: TextAlign.right,
                          ),
                          Text(
                            '${this._selectedCategoryCount(e.key)}/${e.value}',
                          ),
                        ],
                      );
                    }).toList(growable: false),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MaterialButton(
                          child: Text(S.cancel),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        _PerformButton(
                          task: widget.task,
                          onPressed: this._isMeet()
                              ? () => Navigator.pop(
                                    context,
                                    _selectedItems.entries.map((e) {
                                      return PlayerItem(
                                          item: e.key, quantity: e.value);
                                    }).toList(growable: false),
                                  )
                              : null,
                          selectedItems: _selectedItems.entries
                              .map((e) => SelectedItem(e.key, e.value))
                              .toList(growable: false),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.keyboard_arrow_right),
                onPressed: _selectedIndex < widget.playerItems.length - 1
                    ? () => setState(() => _selectedIndex += 1)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _add(Item item, [int quantity = 1]) {
    if (_selectedItems.containsKey(item)) {
      _selectedItems[item] += quantity;
    } else {
      _selectedItems[item] = quantity;
    }
    setState(() {});
  }

  void _remove(Item item, [int quantity = 1]) {
    var currentItem = _selectedItems[item];
    if (currentItem != null) {
      if (currentItem == 1) {
        _selectedItems.remove(item);
      } else {
        _selectedItems[item] -= quantity;
      }
      setState(() {});
    }
  }

  void _removeAll(Item item) {
    if (_selectedItems.containsKey(item)) {
      _selectedItems.remove(item);
      setState(() {});
    }
  }

  bool _removable(Item item) {
    return _selectedItems.containsKey(item);
  }

  bool _addable(Item item) {
    if (_have(item) <= _quantity(item)) return false;

    var totalSelectedCat = item.category.map((e) {
      return _selectedCategoryCount(e);
    }).fold(0, (a, b) => a + b);

    return totalSelectedCat < _needItemCount(item);
  }

  int _quantity(Item item) {
    return _selectedItems[item] ?? 0;
  }

  int _have(Item item) {
    return widget.playerItems
        .where((e) => e.item == item)
        .map((e) => e.quantity)
        .fold(0, (a, b) => a + b);
  }

  int _maxAddable(Item item) {
    int selectedCount = item.category
        .map((e) => _selectedCategoryCount(e))
        .fold(0, (a, b) => a + b);
    int neededCount = _needItemCount(item);
    int maxAmount = neededCount - selectedCount;
    int have = _have(item);
    return have <= maxAmount ? have : maxAmount;
  }

  int _needItemCount(Item item) {
    return item.category
        .map((category) => widget.task.requiredItemCategory
            .where((reqItemCat) => reqItemCat.category == category)
            .map((reqItemCat) => reqItemCat.quantity)
            .fold(0, (prev, curr) => prev + curr))
        .fold(0, (prev, curr) => prev + curr);
  }

  int _selectedCategoryCount(AbstractEnum category) {
    int count = 0;
    _selectedItems.forEach((item, quantity) {
      if (item.category.contains(category)) count += quantity;
    });
    return count;
  }

  bool _isMeet() {
    if (widget.task.requiredItemCategory.isEmpty) return true;
    if (_selectedItems.isEmpty) return false;

    var selectedRequiredCategories = _selectedItems.entries
        .map((si) => si.key.category.map((category) =>
            RequiredItemCategory(category: category, quantity: si.value)))
        .expand((e) => e)
        .toList(growable: false);

    var requires = Set.of(widget.task.requiredItemCategory);
    requires.removeWhere((req) {
      var count = selectedRequiredCategories
          .where((element) => element.category == req.category)
          .map((e) => e.quantity)
          .fold(0, (a, b) => a + b);

      return req.quantity == count;
    });

    return requires.isEmpty;
  }
}

class SelectableItem extends StatelessWidget {
  final Item item;
  final int quantity;
  final int have;
  final Function onAddPressed;
  final Function onRemovePressed;
  final Function onAddLongPress;
  final Function onRemoveLongPress;

  const SelectableItem(
    this.item, {
    Key key,
    @required this.quantity,
    @required this.have,
    this.onAddPressed,
    this.onRemovePressed,
    this.onAddLongPress,
    this.onRemoveLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var categoriesText = item.category.map((c) => c.value).join(', ');
    return Column(
      children: [
        Text(
          item.value,
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(color: item.quality.color()),
        ),
        Text(
          categoriesText,
          style: Theme.of(context).textTheme.subtitle2,
        ),
        Text(
          S.haveItem(have),
          style: Theme.of(context).textTheme.subtitle2,
        ),
        Image.network(
          item.image,
          width: 128,
          height: 64,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            MaterialButton(
              color: Colors.white,
              shape: CircleBorder(),
              textColor: Colors.grey[800],
              child: Icon(Icons.remove),
              onPressed: onRemovePressed,
              onLongPress: onRemoveLongPress,
              minWidth: 0,
              padding: EdgeInsets.all(2.0),
            ),
            Text('$quantity', style: Theme.of(context).textTheme.headline6),
            MaterialButton(
              color: Colors.white,
              splashColor: Colors.grey,
              shape: CircleBorder(),
              textColor: Colors.grey[800],
              child: Icon(Icons.add),
              onPressed: onAddPressed,
              onLongPress: onAddLongPress,
              minWidth: 0,
              padding: EdgeInsets.all(2.0),
            ),
          ],
        ),
      ],
    );
  }
}

class SelectItemRoute<T> extends PageRouteBuilder<T> {
  final Task task;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => Colors.black54;

  SelectItemRoute(this.task)
      : super(
            pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) =>
                new SelectItemsModal(task));

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }
}

class _PerformButton extends StatefulWidget {
  const _PerformButton({
    Key key,
    @required this.task,
    @required this.onPressed,
    this.selectedItems = const [],
  }) : super(key: key);

  final Task task;
  final VoidCallback onPressed;
  final List<SelectedItem> selectedItems;

  @override
  __PerformButtonState createState() => __PerformButtonState();
}

class __PerformButtonState extends State<_PerformButton> {
  Future<SuccessRatio> _successRatio;
  TaskService _taskService;

  @override
  void initState() {
    super.initState();
    this._taskService = context.read<TaskService>();
    this._successRatio = this._taskService.successRatio(
          widget.task,
          selectedItems: widget.selectedItems,
        );
  }

  @override
  void didUpdateWidget(_PerformButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    var oldSum =
        oldWidget.selectedItems.map((e) => e.quantity).fold(0, (x, y) => x + y);
    var newSum =
        widget.selectedItems.map((e) => e.quantity).fold(0, (x, y) => x + y);

    bool isChanged = oldSum != newSum;

    if (isChanged) {
      setState(() {
        this._successRatio = this._taskService.successRatio(
              widget.task,
              selectedItems: widget.selectedItems,
            );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SuccessRatio>(
      future: this._successRatio,
      builder: (context, snapshot) {
        if (!snapshot.hasError &&
            snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          var successRatio = snapshot.data;
          return RaisedButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
            color: _buttonColor(successRatio.ratio),
            child: Text('%${successRatio.ratio}', textAlign: TextAlign.right),
            onPressed: widget.onPressed,
          );
        }

        return RaisedButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          color: Colors.green[700],
          child: Text(S.ok),
          onPressed: widget.onPressed,
        );
      },
    );
  }

  Color _buttonColor(int ratio) {
    if (ratio >= 50) {
      return Colors.green[700];
    } else if (ratio >= 25) {
      return Colors.amber[800];
    }
    return Colors.red[700];
  }
}

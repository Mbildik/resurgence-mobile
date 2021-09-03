import 'package:flutter/material.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/enum.dart';
import 'package:resurgence/task/model.dart';

class Item extends AbstractEnum {
  Set<AbstractEnum> category;
  int price;
  String image;
  Quality quality;
  bool usable;

  Item({
    String key,
    String value,
    this.category,
    this.price,
    this.image,
    this.quality,
    this.usable,
  }) : super(key: key, value: value);

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
    image = json['image'] == null
        ? S.baseUrl + "static/item/$key.png"
        : S.baseUrl + json['image'];
    quality =
        json['quality'] == null ? null : Quality.fromJson(json['quality']);
    usable = json['usable'] == null ? false : json['usable'];
  }

  String categoryHumanReadable() =>
      this.category?.map((c) => c.value)?.join(', ') ?? '';
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

class Quality extends AbstractEnum {
  int factor;

  Quality(this.factor, key, value) : super(key: key, value: value);

  Quality.fromJson(Map<String, dynamic> json) {
    var abstractEnum = AbstractEnum.fromJson(json);
    key = abstractEnum.key;
    value = abstractEnum.value;
    factor = json['factor'] == null ? null : json['factor'];
  }

  Color color() {
    switch (key) {
      case 'WORTHLESS': return Colors.grey;
      case 'COMMON': return Colors.white;
      case 'RARE': return Colors.amber;
      case 'LEGENDARY': return Colors.purple[300];
      default: return Colors.grey;
    }
  }
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
          .fold(0, (a, b) => a + b);

      return req.quantity == count;
    });

    return requires.isEmpty;
  }
}

class EmptyPlayerItem extends StatelessWidget {
  final Set<String> _categories;

  EmptyPlayerItem({
    Key key,
    Set<RequiredItemCategory> categories,
  })  : _categories = categories.map((e) => e.category.value).toSet(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(A.EMPTY_IMAGE, width: 64, height: 64),
              const SizedBox(height: 8.0),
              Text(S.playerItemEmptyCategories(_categories)),
              const SizedBox(height: 8.0),
              OutlineButton(
                child: Text(S.ok),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemUsageResponse {
  ItemUsageResponse({
    @required this.used,
  });

  final bool used;

  factory ItemUsageResponse.fromJson(Map<String, dynamic> json) => ItemUsageResponse(
    used: json["used"],
  );
}

import 'package:flutter/material.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/enum.dart';
import 'package:resurgence/item/item.dart';

class Task extends AbstractEnum {
  AbstractEnum difficulty;
  List<AbstractEnum> auxiliary;
  List<AbstractEnum> skillGain;
  int moneyGain;
  int experienceGain;
  int durationMills;
  int leftMillis;
  Set<Drop> drop;
  Set<RequiredItemCategory> requiredItemCategory;
  bool solo;
  bool smuggling;
  bool multiPlayer;
  String image;

  Task({
    this.difficulty,
    this.auxiliary,
    this.skillGain,
    this.moneyGain,
    this.experienceGain,
    this.durationMills,
    this.leftMillis,
    this.drop,
    this.requiredItemCategory,
    this.solo,
    this.smuggling,
    this.multiPlayer,
    this.image,
  });

  Task.fromJson(Map<String, dynamic> json) {
    var abstractEnum = AbstractEnum.fromJson(json);
    key = abstractEnum.key;
    value = abstractEnum.value;

    difficulty = AbstractEnum.fromJson(json['difficulty']);
    if (json['auxiliary'] != null) {
      auxiliary = List<AbstractEnum>();
      json['auxiliary'].forEach((v) {
        auxiliary.add(AbstractEnum.fromJson(v));
      });
    }
    if (json['skill_gain'] != null) {
      skillGain = List<AbstractEnum>();
      json['skill_gain'].forEach((v) {
        skillGain.add(AbstractEnum.fromJson(v));
      });
    }
    moneyGain = json['money_gain'];
    experienceGain = json['experience_gain'];
    durationMills = json['duration_mills'];
    leftMillis = json['left_millis'];
    if (json['drop'] != null) {
      drop = (json['drop'] as List).map((v) => Drop.fromJson(v)).toSet();
    }
    if (json['required_item_category'] != null) {
      requiredItemCategory = (json['required_item_category'] as List)
          .map((v) => RequiredItemCategory.fromJson(v))
          .toSet();
    }
    solo = json['solo'];
    smuggling = json['smuggling'];
    multiPlayer = json['multi_player'];
    image = json['image'] == null ? null : S.baseUrl + json['image'];
  }

  Color color() {
    var difficulty = this.difficulty.key;
    if ('EASY' == difficulty) {
      return Colors.indigoAccent[100];
    } else if ('MEDIUM' == difficulty) {
      return Colors.amber;
    }
    return Colors.red[700];
  }
}

class Drop {
  Item item;
  int quantity;

  Drop({this.item, this.quantity});

  Drop.fromJson(Map<String, dynamic> json) {
    item = Item.fromJson(json['item']);
    quantity = json['quantity'];
  }
}

class RequiredItemCategory {
  AbstractEnum category;
  int quantity;

  RequiredItemCategory({this.category, this.quantity});

  RequiredItemCategory.fromJson(Map<String, dynamic> json) {
    category = AbstractEnum.fromJson(json['category']);
    quantity = json['quantity'];
  }
}

class TaskResult {
  bool succeed;
  int experienceGain;
  int moneyGain;
  Set<AbstractEnum> skillGain;
  Set<Drop> drop;

  TaskResult({
    this.succeed,
    this.experienceGain,
    this.moneyGain,
    this.skillGain,
    this.drop,
  });

  TaskResult.fromJson(Map<String, dynamic> json) {
    succeed = json['succeed'];
    experienceGain = json['experience_gain'];
    moneyGain = json['money_gain'];
    if (json['skill_gain'] != null) {
      skillGain = (json['skill_gain'] as List)
          .map((v) => AbstractEnum.fromJson(v))
          .toSet();
    }
    if (json['drop'] != null) {
      drop = (json['drop'] as List).map((v) => Drop.fromJson(v)).toSet();
    }
  }
}

class SuccessRatio {
  final int ratio;

  SuccessRatio(this.ratio);

  factory SuccessRatio.fromJson(Map<String, dynamic> json) {
    return SuccessRatio(json['ratio']);
  }
}

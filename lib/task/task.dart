import 'dart:async';

import 'package:flutter/material.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/duration.dart';
import 'package:resurgence/enum.dart';
import 'package:resurgence/money.dart';
import 'package:resurgence/ui/button.dart';

class Task extends AbstractEnum {
  int difficulty;
  List<AbstractEnum> auxiliary;
  List<AbstractEnum> skillGain;
  int moneyGain;
  int experienceGain;
  String duration;
  String left;
  Set<Drop> drop;
  Set<RequiredItemCategory> requiredItemCategory;
  bool solo;
  bool smuggling;
  bool multiPlayer;

  Task({
    this.difficulty,
    this.auxiliary,
    this.skillGain,
    this.moneyGain,
    this.experienceGain,
    this.duration,
    this.left,
    this.drop,
    this.requiredItemCategory,
    this.solo,
    this.smuggling,
    this.multiPlayer,
  });

  Task.fromJson(Map<String, dynamic> json) {
    var abstractEnum = AbstractEnum.fromJson(json);
    key = abstractEnum.key;
    value = abstractEnum.value;

    difficulty = json['difficulty'];
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
    duration = json['duration'];
    left = json['left'];
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
  }
}

class Drop {
  Item item;
  int quantity;
  double ratio;

  Drop({this.item, this.quantity, this.ratio});

  Drop.fromJson(Map<String, dynamic> json) {
    item = Item.fromJson(json['item']);
    quantity = json['quantity'];
    ratio = json['ratio'];
  }
}

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

class RequiredItemCategory {
  AbstractEnum category;
  int quantity;

  RequiredItemCategory({this.category, this.quantity});

  RequiredItemCategory.fromJson(Map<String, dynamic> json) {
    category = AbstractEnum.fromJson(json['category']);
    quantity = json['quantity'];
  }
}

typedef PerformCallBack<T> = Future<T> Function();

class TaskWidget extends StatefulWidget {
  final Task task;
  final PerformCallBack<TaskResult> onPerform;

  const TaskWidget(this.task, {Key key, @required this.onPerform})
      : super(key: key);

  @override
  _TaskWidgetState createState() => _TaskWidgetState();
}

class TaskResult {
  bool succeed;
  int experienceGain;
  int moneyGain;
  Set<AbstractEnum> skillGain;
  Set<Drop> drop;

  TaskResult(
      {this.succeed,
      this.experienceGain,
      this.moneyGain,
      this.skillGain,
      this.drop});

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

class _TaskWidgetState extends State<TaskWidget> {
  Duration duration;
  bool finished = false;
  bool loading = false;
  Timer timer;

  @override
  void initState() {
    super.initState();
    duration = ISO8601Duration(widget.task.left).toDuration();
    if (duration.inSeconds <= 0) {
      finished = true;
    } else {
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (duration.inSeconds < 1) {
          timer.cancel();
          setState(() => finished = true);
          return;
        }
        setState(() => duration = Duration(seconds: duration.inSeconds - 1));
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (timer != null) timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 120.0,
      margin: const EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: 24.0,
      ),
      child: new Stack(
        children: <Widget>[
          taskCard(context),
          planetThumbnail(),
        ],
      ),
    );
  }

  Widget planetThumbnail() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Image.asset('assets/img/bank.png'),
    );
  }

  Widget taskCard(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 46.0),
      child: Container(
        margin: EdgeInsets.fromLTRB(64.0, 4.0, 8.0, 4.0),
        constraints: BoxConstraints.expand(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Container(height: 4.0),
            Text(
              widget.task.value,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Container(height: 4),
            Text(
              Money.format(widget.task.moneyGain),
              style: Theme.of(context).textTheme.subtitle2,
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              height: 1.0,
              color: Color(0xff00c6ff),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.timer),
                    Text(
                      ISO8601Duration(widget.task.duration).pretty(),
                    ),
                  ],
                ),
                Button(
                  enabled: !loading && finished,
                  onPressed: () {
                    setState(() => loading = true);
                    widget.onPerform().whenComplete(() {
                      setState(() => loading = false);
                    });
                  },
                  child: Text(
                    finished
                        ? S.perform
                        : ISO8601Duration.from(duration).pretty(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      decoration: new BoxDecoration(
        color: Color(0xFF133336),
        shape: BoxShape.rectangle,
        borderRadius: new BorderRadius.circular(8.0),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10.0,
            offset: new Offset(0.0, 10.0),
          ),
        ],
      ),
    );
  }

  void showTaskInfo() {
    print('show task info');
  }

  Future<void> performTask() {
    return Future.delayed(Duration(seconds: 1));
  }
}

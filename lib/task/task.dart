import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/duration.dart';
import 'package:resurgence/enum.dart';
import 'package:resurgence/item/item.dart';
import 'package:resurgence/money.dart';
import 'package:resurgence/ui/button.dart';

class Task extends AbstractEnum {
  AbstractEnum difficulty;
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

typedef PerformCallBack<T> = Future<T> Function(List<PlayerItem> selectedItems);

class TaskWidget extends StatefulWidget {
  final Task task;
  final PerformCallBack<TaskResult> onPerform;

  const TaskWidget(this.task, {Key key, @required this.onPerform})
      : super(key: key);

  @override
  _TaskWidgetState createState() => _TaskWidgetState();
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
          Hero(
            tag: 'TASK-IMAGE-${widget.task.key}',
            child: taskThumbnail(),
          ),
        ],
      ),
    );
  }

  Widget taskThumbnail() {
    return GestureDetector(
      onTap: () => Navigator.push(context, TaskDetailRoute(widget.task)),
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 16),
        child: Image.asset('assets/img/bank.png'),
      ),
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
                    var requiredItemCat = widget.task.requiredItemCategory;
                    if (requiredItemCat != null && requiredItemCat.isNotEmpty) {
                      Navigator.push<List<PlayerItem>>(
                        context,
                        ItemListPageRoute(widget.task),
                      ).then((selectedItems) {
                        // if `selectedItems` is null,
                        //  it means player canceled the task
                        if (selectedItems == null) return;
                        performTask(selectedItems);
                      });
                    } else {
                      performTask([]);
                    }
                  },
                  child: Text(
                    finished
                        ? S.perform
                        : ISO8601Duration.from(duration).pretty(
                            abbreviated: true,
                          ),
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

  void performTask(List<PlayerItem> selectedItems) {
    setState(() => loading = true);
    widget.onPerform(selectedItems).whenComplete(() {
      setState(() => loading = false);
    });
  }
}

class TaskDetailPage extends StatefulWidget {
  final Task task;

  const TaskDetailPage({Key key, this.task}) : super(key: key);

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: Stack(
          children: <Widget>[
            taskDetail(),
            taskImage(),
          ],
        ),
      ),
    );
  }

  Widget taskDetail() {
    var task = widget.task;
    return Center(
      heightFactor: 1,
      child: Container(
        child: Card(
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.white30, width: 2.0),
            borderRadius: BorderRadius.circular(16.0),
          ),
          color: Color(0xFF28474A),
          margin: EdgeInsets.only(top: 50, left: 32.0, right: 32.0),
          child: Container(
            width: 300,
            // 50.0 + 16.0 -> image + normal padding
            padding: EdgeInsets.fromLTRB(16.0, 50.0 + 16.0, 16, 16),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  DifficultyWidget(task.difficulty),
                  Divider(),
                  MoneyWidget(task.moneyGain),
                  Divider(),
                  ExperienceWidget(task.experienceGain),
                  Divider(),
                  DurationWidget(ISO8601Duration(task.duration)),
                  Divider(),
                  EnumWrapper(
                    task.auxiliary,
                    text: S.auxiliary,
                    color: Color(0xFF27671B),
                    divider: true,
                  ),
                  EnumWrapper(
                    task.skillGain,
                    text: S.skillGain,
                    color: Color(0xFF3D6538),
                    divider: true,
                  ),
                  EnumWrapper(
                    task.drop.map((e) => e.item),
                    text: S.drop,
                    color: Color(0xFF345511),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget taskImage() {
    return Hero(
      tag: 'TASK-IMAGE-${widget.task.key}',
      child: Center(
        heightFactor: 1,
        child: Image.asset(
          'assets/img/bank.png',
          height: 100,
          width: 100,
        ),
      ),
    );
  }
}

class TaskDetailRoute<T> extends PageRouteBuilder<T> {
  final Task task;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => Colors.black38;

  TaskDetailRoute(this.task)
      : super(
            pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) =>
                new TaskDetailPage(task: task));

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }
}

class DifficultyWidget extends StatelessWidget {
  final AbstractEnum difficulty;

  const DifficultyWidget(this.difficulty, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;
    switch (difficulty.key) {
      case 'EASY':
        color = Colors.green;
        icon = Icons.filter_1;
        break;
      case 'MEDIUM':
        color = Colors.yellow;
        icon = Icons.filter_2;
        break;
      case 'HARD':
      default:
        color = Colors.red;
        icon = Icons.filter_3;
    }
    return Tooltip(
      message: S.difficulty,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: color),
          Container(margin: EdgeInsets.symmetric(horizontal: 4.0)),
          Text(difficulty.value),
        ],
      ),
    );
  }
}

class ExperienceWidget extends StatelessWidget {
  final int exp;

  const ExperienceWidget(this.exp, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.star;
    Color color = Colors.yellow;
    return Tooltip(
      message: S.experience,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: color),
          Container(margin: EdgeInsets.symmetric(horizontal: 2.0)),
          Text(NumberFormat.compact().format(exp)),
        ],
      ),
    );
  }
}

class EnumWrapper extends StatelessWidget {
  final Iterable<AbstractEnum> enums;
  final String text;
  final Color color;
  final bool divider;

  const EnumWrapper(
    this.enums, {
    Key key,
    @required this.color,
    @required this.text,
    this.divider = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (enums == null || enums.isEmpty) return Container();

    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(text),
            Container(margin: EdgeInsets.symmetric(horizontal: 2.0)),
            Expanded(
              child: Wrap(
                spacing: 2.0,
                runSpacing: 2.0,
                children: enums
                    .map((e) => EnumWidget(e, color: this.color))
                    .toList(growable: false),
              ),
            ),
          ],
        ),
        if (this.divider) Divider(),
      ],
    );
  }
}

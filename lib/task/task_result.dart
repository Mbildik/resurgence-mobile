import 'package:flutter/material.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/money.dart';
import 'package:resurgence/task/task.dart';

class TaskResultPage extends StatelessWidget {
  final TaskResult result;

  const TaskResultPage(this.result, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: result.succeed ? Colors.green[300] : Colors.red[300],
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(4.0),
        ),
        color: Color(0xFF28474A),
        margin: EdgeInsets.symmetric(horizontal: 16.0),
        child: result.succeed ? succeedWidget() : failedWidget(),
      ),
    );
  }

  Widget succeedWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ExperienceWidget(result.experienceGain),
          Divider(),
          MoneyWidget(result.moneyGain),
          if (result.skillGain.isNotEmpty) Divider(),
          if (result.skillGain.isNotEmpty)
            EnumWrapper(
              result.skillGain,
              color: Colors.green,
              text: S.skillGain,
            ),
          if (result.drop.isNotEmpty) Divider(),
          if (result.drop.isNotEmpty)
            EnumWrapper(
              result.drop.map((e) => e.item).toList(growable: false),
              color: Colors.green,
              text: S.drop,
            ),
        ],
      ),
    );
  }

  Widget failedWidget() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(S.failedTaskResult),
    );
  }
}

class TaskResultRoute<T> extends PageRouteBuilder<T> {
  final TaskResult result;

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => true;

  @override
  Color get barrierColor => Colors.black38;

  TaskResultRoute(this.result)
      : super(
            pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) =>
                new TaskResultPage(result));

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(opacity: animation, child: child);
  }
}

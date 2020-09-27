import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/enum.dart';
import 'package:resurgence/money.dart';
import 'package:resurgence/task/model.dart';

class TaskResultPage extends StatelessWidget {
  final TaskResult result;

  const TaskResultPage(this.result, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return result.succeed ? TaskSucceed(result) : TaskFailed();
  }
}

class TaskSucceed extends StatelessWidget {
  final TaskResult result;

  const TaskSucceed(
    this.result, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 8.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(A.MONEY, width: 128, height: 128),
                Text(
                  Money.format(result.moneyGain),
                  style: Theme.of(context).textTheme.headline4.copyWith(
                        color: Colors.green[700],
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: Theme.of(context).textTheme.headline4.fontSize,
                    ),
                    Text(
                      NumberFormat.compact().format(
                        result.experienceGain,
                      ),
                      style: Theme.of(context).textTheme.headline4.copyWith(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0),
                if (result.skillGain.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: EnumWrapper(
                      result.skillGain,
                      color: Colors.green[700],
                      text: S.skillGained,
                    ),
                  ),
                SizedBox(height: 8.0),
                if (result.drop.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: EnumWrapper(
                      result.drop.map((e) => e.item).toList(growable: false),
                      color: Colors.blueGrey[700],
                      text: S.drop,
                    ),
                  ),
                SizedBox(height: 8.0),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Text(S.ok),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TaskFailed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        child: Card(
          margin: EdgeInsets.symmetric(horizontal: 8.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(A.BUSTED, width: 128, height: 128),
                Text(S.failedTaskResult),
                SizedBox(height: 8.0),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                  ),
                  child: Text(S.ok),
                  onPressed: () => Navigator.pop(context),
                )
              ],
            ),
          ),
        ),
      ),
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
  Color get barrierColor => Colors.black54;

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

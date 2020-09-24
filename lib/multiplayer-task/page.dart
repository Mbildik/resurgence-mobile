import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:duration/duration.dart';
import 'package:duration/locale.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/enum.dart';
import 'package:resurgence/item/item.dart';
import 'package:resurgence/multiplayer-task/data.dart';
import 'package:resurgence/multiplayer-task/service.dart';
import 'package:resurgence/player/player.dart';
import 'package:resurgence/task/task_result.dart';
import 'package:resurgence/ui/error_handler.dart';
import 'package:resurgence/ui/shared.dart';

class MultiplayerTaskPage extends StatefulWidget {
  @override
  _MultiplayerTaskPageState createState() => _MultiplayerTaskPageState();
}

class _MultiplayerTaskPageState extends State<MultiplayerTaskPage> {
  Future<List<MultiplayerTask>> _allTasks;
  MultiplayerService _service;

  @override
  void initState() {
    super.initState();
    _service = context.read<MultiplayerService>();
    _allTasks = _service.all();
  }

  void _reload() {
    setState(() {
      _allTasks = _service.all();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Plan>(
      future: _service.plan(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: W.defaultAppBar,
            body: const LoadingWidget(),
          );
        } else if (!snapshot.hasError) {
          // player have a plan
          var plan = snapshot.data;
          return _MPTaskPlanPage(
            plan: plan,
            task: plan.task,
          );
        }

        var error = snapshot.error;
        if (error is DioError && error?.response?.statusCode != 404) {
          log('plan future error', error: snapshot.error);
          return Scaffold(
            appBar: W.defaultAppBar,
            body: RefreshOnErrorWidget(
              onPressed: _reload,
            ),
          );
        }

        return Scaffold(
          appBar: W.defaultAppBar,
          body: LoadingFutureBuilder<List<MultiplayerTask>>(
            future: _allTasks,
            onError: this._reload,
            builder: (context, snapshot) {
              var tasks = snapshot.data;
              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  var task = tasks[index];

                  return _MPListTile(task: task);
                },
              );
            },
          ),
        );
      },
    );
  }
}

class _MPListTile extends StatefulWidget {
  const _MPListTile({
    Key key,
    @required this.task,
  }) : super(key: key);

  final MultiplayerTask task;

  @override
  __MPListTileState createState() => __MPListTileState();
}

class __MPListTileState extends State<_MPListTile> {
  Duration _duration;
  bool _enabled = false;
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _duration = Duration(milliseconds: widget.task.left);
    if (_duration.inMilliseconds == 0) {
      _enabled = true;
    }
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_duration.inSeconds < 1) {
        timer.cancel();
        setState(() {
          _enabled = true;
          _duration = Duration.zero;
        });
      } else {
        setState(() {
          _duration = Duration(milliseconds: _duration.inMilliseconds - 1000);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var task = widget.task;
    return ListTile(
      leading: Image.network('https://picsum.photos/150'),
      title: Text(task.value),
      subtitle: Text(
        task.positions.map((p) => p.value).join(', '),
      ),
      trailing: RaisedButton(
        child: Text(buttonText()),
        onPressed: !_enabled
            ? null
            : () {
                Navigator.push<List<PlayerItem>>(
                  context,
                  ItemListPageRoute(task.leaderTask),
                ).then((selectedItems) {
                  if (selectedItems == null) return;
                  Navigator.of(context).pushReplacement(_MPTaskPlanPageRoute(
                    task,
                    selectedItems,
                  ));
                });
              },
      ),
    );
  }

  String buttonText() {
    if (_enabled) {
      return S.organize;
    }
    return prettyDuration(
      _duration,
      locale: const TurkishDurationLocale(),
      abbreviated: true,
    );
  }
}

class _MPTaskPlanPage extends StatefulWidget {
  final Plan plan;
  final MultiplayerTask task;
  final List<PlayerItem> selectedItems;

  const _MPTaskPlanPage({
    Key key,
    this.task,
    this.selectedItems,
    this.plan,
  }) : super(key: key);

  @override
  __MPTaskPlanPageState createState() => __MPTaskPlanPageState();
}

class __MPTaskPlanPageState extends State<_MPTaskPlanPage> {
  final TextEditingController _memberController = TextEditingController();

  Future<Plan> _future;
  MultiplayerService _service;

  @override
  void initState() {
    super.initState();
    _service = context.read<MultiplayerService>();
    _future = widget.plan != null
        ? Future.value(widget.plan)
        : _service.organize(widget.task, widget.selectedItems).catchError((e) {
            Navigator.pop(context);
            ErrorHandler.showError(context, e);
          });
  }

  void _reload() {
    setState(() {
      _future = _service.plan().catchError((e) {
        if (e is DioError && e?.response?.statusCode == 404) {
          Navigator.pop(context);
          showInformationDialog(context, S.planNotFoundOrCompleted);
        }
        throw e;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.value),
        actions: [
          Tooltip(
            message: S.quit,
            child: IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () {
                showConfirmationDialog(
                    context,
                    S.planQuitConfirmationTitle,
                    S.planQuitConfirmationContent,
                    S.ok,
                    S.cancel,
                    () => _service
                        .leave()
                        .then((_) => Navigator.pop(context))
                        .catchError((e) => ErrorHandler.showError(context, e)));
              },
            ),
          ),
          Tooltip(
            message: S.refresh,
            child: IconButton(
              icon: Icon(Icons.refresh),
              onPressed: this._reload,
            ),
          ),
          Tooltip(
            message: S.help,
            child: IconButton(
              icon: Icon(Icons.help),
              onPressed: () {
                showHelpDialog(
                  context: context,
                  title: widget.task.value,
                  content: S.multiplayerTaskHelp,
                );
              },
            ),
          )
        ],
      ),
      body: LoadingFutureBuilder<Plan>(
        future: _future,
        onError: _reload,
        builder: (context, snapshot) {
          var plan = snapshot.data;

          var memberWidgets = plan.members.map((member) {
            return _PlanMemberWidget(
              member,
              onMemberRemove: (member) {
                return _service
                    .remove(member)
                    .then((_) => _reload())
                    .catchError((e) => ErrorHandler.showError(context, e));
              },
              leader: plan.leader == PlayerState.playerName,
            );
          }).toList(growable: false);

          var emptyPositions = List.from(plan.task.positions);
          plan.members
              .map((m) => m.position)
              .forEach((position) => emptyPositions.remove(position));
          var emptyPlanMembers = emptyPositions.map((p) =>
              _EmptyPlanMemberWidget(p,
                  onPressed: () => showAddMemberDialog(context, p)));
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ...memberWidgets,
                      ...emptyPlanMembers,
                    ],
                  ),
                ),
              ),
              Consumer<PlayerState>(
                builder: (context, state, child) {
                  if (state.name == plan.leader) {
                    return child;
                  }
                  var currentMember =
                      plan.members.firstWhere((m) => m.name == state.name);

                  return RaisedButton(
                    child: Text(currentMember.status == Status.ready
                        ? S.changeItem
                        : S.selectItem),
                    onPressed: () {
                      var task = currentMember.task;
                      Navigator.push<List<PlayerItem>>(
                        context,
                        ItemListPageRoute(task),
                      ).then((selectedItems) {
                        _service
                            .ready(selectedItems ?? [])
                            .then((_) => _reload())
                            .catchError(
                                (e) => ErrorHandler.showError(context, e));
                      });
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    child: Text(S.perform),
                    onPressed: () => _service.perform().then((value) {
                      print(value);

                      Navigator.pop(context);
                      value.forEach((element) {
                        Navigator.push(context, TaskResultRoute(element));
                      });

                      return value;
                    }).catchError((e) {
                      if (e is DioError && e?.response?.statusCode == 412) {
                        // preconditions failed
                        // todo add time check

                        var content = (e.response.data as List).map((e) {
                          var category = AbstractEnum.fromJson(e['category']);
                          var member = e['player'];
                          return S.planPrecondition(member, category.value);
                        }).join('\n');

                        showErrorDialog(
                          context,
                          content,
                          title: S.planPreconditionErrorTitle,
                        );
                      } else {
                        return ErrorHandler.showError(context, e);
                      }
                    }),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void showAddMemberDialog(BuildContext context, Position position) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(S.invitePlayer),
          contentPadding: EdgeInsets.all(16.0),
          children: [
            TextField(
              autofocus: true,
              controller: _memberController,
              onSubmitted: (_) => _onAdd(position),
              decoration: InputDecoration(
                hintText: position.value,
                border: InputBorder.none,
              ),
            ),
            RaisedButton(
              child: Text(S.add),
              onPressed: () => _onAdd(position),
            ),
          ],
        );
      },
    );
  }

  void _onAdd(Position position) {
    String member = _memberController.text.trim();
    if (member.isEmpty) return;

    _service.add(position, member).then((_) {
      _reload();
      Navigator.pop(context);
      _memberController.clear();
    }).catchError((e) {
      ErrorHandler.showError(context, e);
    });
  }
}

typedef OnMemberRemove = Future Function(String member);

class _PlanMemberWidget extends StatelessWidget {
  final Member member;
  final OnMemberRemove onMemberRemove;
  final bool leader;

  const _PlanMemberWidget(
    this.member, {
    Key key,
    @required this.onMemberRemove,
    @required this.leader,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var memberWidget = Container(
      margin: EdgeInsets.all(8.0),
      child: Card(
        color: member.status == Status.ready ? Colors.green : Colors.amber,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                member.position.value,
                style: Theme.of(context).textTheme.headline6,
              ),
              Text(
                member.name,
                style: Theme.of(context)
                    .textTheme
                    .headline6
                    .copyWith(color: Colors.black87, fontSize: 16.0),
              ),
              Text(
                '${member.selectedItems.length} ${S.item}',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    .copyWith(color: Colors.black87),
              ),
            ],
          ),
        ),
      ),
    );

    if (!leader) {
      return memberWidget;
    }

    return GestureDetector(
      onLongPress: () {
        return showConfirmationDialog(
          context,
          S.planRemoveMemberConfirmationTitle,
          S.planRemoveMemberConfirmationContent(member.name),
          S.ok,
          S.cancel,
          () => onMemberRemove(member.name),
        );
      },
      child: memberWidget,
    );
  }
}

class _EmptyPlanMemberWidget extends StatelessWidget {
  final Position position;
  final Function onPressed;

  const _EmptyPlanMemberWidget(
    this.position, {
    Key key,
    @required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.all(8.0),
        child: Card(
          shape: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white38),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  position.value,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MultiplayerTaskPageRoute<T> extends MaterialPageRoute<T> {
  MultiplayerTaskPageRoute()
      : super(builder: (BuildContext context) => MultiplayerTaskPage());
}

class _MPTaskPlanPageRoute<T> extends MaterialPageRoute<T> {
  final MultiplayerTask task;
  final List<PlayerItem> selectedItems;

  _MPTaskPlanPageRoute(this.task, this.selectedItems)
      : super(
            builder: (BuildContext context) =>
                _MPTaskPlanPage(task: task, selectedItems: selectedItems));
}

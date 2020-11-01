import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/item/item.dart';
import 'package:resurgence/player/player.dart';
import 'package:resurgence/player/service.dart';
import 'package:resurgence/task/model.dart';
import 'package:resurgence/task/service.dart';
import 'package:resurgence/task/task_result.dart';
import 'package:resurgence/task/ui.dart';
import 'package:resurgence/ui/error_handler.dart';
import 'package:resurgence/ui/shared.dart';

class SoloTaskPage extends StatefulWidget {
  @override
  _SoloTaskPageState createState() => _SoloTaskPageState();
}

class _SoloTaskPageState extends State<SoloTaskPage> {
  Future<List<Task>> futureTasks;
  TaskService _service;
  PlayerService _playerService;
  PlayerState _playerState;

  @override
  void initState() {
    super.initState();
    _service = context.read<TaskService>();
    _playerService = context.read<PlayerService>();
    _playerState = context.read<PlayerState>();
    futureTasks = fetchAllTasks();
  }

  Future<List<Task>> fetchAllTasks() => _service.allTask();

  Future<TaskResult> perform(Task task, List<PlayerItem> selectedItems) =>
      _service.perform(task, selectedItems);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.soloTask),
        actions: [
          Tooltip(
            message: S.help,
            child: IconButton(
              icon: Icon(Icons.help),
              onPressed: () {
                showHelpDialog(
                  context: context,
                  title: S.soloTask,
                  content: S.soloTaskHelp,
                );
              },
            ),
          )
        ],
      ),
      body: LoadingFutureBuilder<List<Task>>(
        future: futureTasks,
        onError: this._refreshTasks,
        builder: (context, snapshot) {
          var tasks = snapshot.data;
          return ListView.builder(
            primary: false,
            itemCount: tasks.length,
            itemBuilder: (BuildContext context, int index) {
              var task = tasks[index];

              return TaskListTile(
                task,
                onPerform: (selectedItems) {
                  perform(task, selectedItems)
                      .then(this.onTaskPerformed)
                      .catchError((e) => ErrorHandler.showError(context, e))
                      .whenComplete(() => _playerService
                          .info()
                          .then((player) => _playerState.updatePlayer(player)));
                },
              );
            },
          );
        },
      ),
    );
  }

  TaskResult onTaskPerformed(TaskResult result) {
    _refreshTasks();
    Navigator.push(context, TaskResultRoute(result));
    return result;
  }

  void _refreshTasks() {
    setState(() {
      futureTasks = this.fetchAllTasks();
    });
  }
}

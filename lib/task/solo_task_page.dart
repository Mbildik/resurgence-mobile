import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/item/item.dart';
import 'package:resurgence/task/service.dart';
import 'package:resurgence/task/task.dart';
import 'package:resurgence/task/task_result.dart';
import 'package:resurgence/ui/error_handler.dart';
import 'package:resurgence/ui/shared.dart';

class SoloTaskPage extends StatefulWidget {
  @override
  _SoloTaskPageState createState() => _SoloTaskPageState();
}

class _SoloTaskPageState extends State<SoloTaskPage> {
  Future<List<Task>> futureTasks;

  @override
  void initState() {
    super.initState();
    futureTasks = fetchAllTasks();
  }

  Future<List<Task>> fetchAllTasks() => context.read<TaskService>().allTask();

  Future<TaskResult> perform(String task, List<PlayerItem> selectedItems) =>
      context.read<TaskService>().perform(task, selectedItems);

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
              return TaskWidget(
                task,
                onPerform: (List<PlayerItem> selectedItems) => perform(
                  task.key,
                  selectedItems,
                )
                    .then(onTaskPerformed)
                    .catchError((e) => ErrorHandler.showError(context, e)),
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

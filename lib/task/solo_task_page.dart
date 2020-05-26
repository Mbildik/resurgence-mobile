import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/item/item.dart';
import 'package:resurgence/task/service.dart';
import 'package:resurgence/task/task.dart';
import 'package:resurgence/task/task_result.dart';
import 'package:resurgence/ui/button.dart';
import 'package:resurgence/ui/error_handler.dart';

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
      ),
      body: FutureBuilder<List<Task>>(
        future: futureTasks,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Column(
                  children: <Widget>[
                    Button(
                      child: Text(S.reload),
                      onPressed: () => this._refreshTasks(),
                    ),
                    Text(S.errorOccurred),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            primary: false,
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              var task = snapshot.data[index];
              return TaskWidget(
                task,
                onPerform: (List<PlayerItem> selectedItems) => perform(
                  task.key,
                  selectedItems,
                ).then(onTaskPerformed).catchError(
                    (e) => ErrorHandler.showError<TaskResult>(context, e)),
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

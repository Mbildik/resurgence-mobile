import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/task/service.dart';
import 'package:resurgence/task/task.dart';
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

  Future<TaskResult> perform(String task) =>
      context.read<TaskService>().perform(task);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task'),
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
                child: Text(S.errorOccurred),
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
                onPerform: () => perform(task.key)
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

//    showDialog(
//      context: context,
//      builder: (context) {
//        return AlertDialog(
//          title: result.succeed
//              ? Text(
//                  'Succeed',
//                  style: TextStyle(color: Colors.green),
//                )
//              : Text(
//                  'Failed',
//                  style: TextStyle(color: Colors.red),
//                ),
//          content: Text(result.moneyGain.toString()),
//        );
//      },
//    ).then((value) {
    setState(() {
      futureTasks = this.fetchAllTasks();
    });
//    });
    return result;
  }
}

import 'package:flutter/material.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/multiplayer-task/page.dart';
import 'package:resurgence/task/solo_task_page.dart';
import 'package:resurgence/ui/shared.dart';

class TaskTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(S.tasks),
          actions: [
            Tooltip(
              message: S.help,
              child: IconButton(
                icon: Icon(Icons.info),
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
          bottom: TabBar(
            tabs: [
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 4.0),
                    Text(S.soloTask),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people),
                    SizedBox(width: 4.0),
                    Text(S.multiplayerTasks),
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SoloTaskPage(),
            MultiplayerTaskPage(),
          ],
        ),
      ),
    );
  }
}

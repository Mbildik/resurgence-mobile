import 'package:flutter/material.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/multiplayer-task/page.dart';
import 'package:resurgence/task/solo_task_page.dart';
import 'package:resurgence/ui/shared.dart';

class TaskTab extends StatefulWidget {
  @override
  _TaskTabState createState() => _TaskTabState();
}

class _TaskTabState extends State<TaskTab> with SingleTickerProviderStateMixin {
  TabController _tabController;
  int _index;

  @override
  void initState() {
    super.initState();
    this._tabController = TabController(vsync: this, length: 2);
    this._index = this._tabController.index;

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;

      setState(() => this._index = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.tasks),
        actions: [
          if (this._index == 0)
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
            ),
          if (this._index == 1)
            Tooltip(
              message: S.help,
              child: IconButton(
                icon: Icon(Icons.info),
                onPressed: () {
                  showHelpDialog(
                    context: context,
                    title: S.multiplayerTasks,
                    content: S.multiplayerTaskHelp,
                  );
                },
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
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
        controller: _tabController,
        children: [
          SoloTaskPage(),
          MultiplayerTaskPage(),
        ],
      ),
    );
  }
}

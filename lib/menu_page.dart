import 'package:flutter/material.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/profile/profile_page.dart';
import 'package:resurgence/task/solo_task_page.dart';
import 'package:resurgence/ui/button.dart';
//import 'package:provider/provider.dart';

typedef WidgetBuilder = Widget Function(BuildContext context);

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: W.defaultAppBar,
      body: GridView.count(
        primary: false,
        padding: EdgeInsets.all(16),
        childAspectRatio: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        crossAxisCount: 2,
        shrinkWrap: true,
        children: <Widget>[
          profileButton(),
        ],
      ),
    );
  }

  Widget profileButton() {
    return Button(
      child: Text(S.profile),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ProfilePage();
          },
        ),
      ),
    );
  }

  Widget drawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          drawerHeader(S.applicationTitle),
          drawerItem(context, S.profile, (context) => ProfilePage()),
          drawerItem(context, S.task, (context) => Text('Task')),
        ],
      ),
    );
  }

  Widget drawerHeader(String header) {
    return DrawerHeader(
      child: Text(header),
      decoration: BoxDecoration(
        color: Colors.blue,
      ),
    );
  }

  Widget drawerItem(BuildContext context, String title, WidgetBuilder builder) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: builder),
        );
      },
    );
  }
}

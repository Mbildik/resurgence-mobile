import 'package:flutter/material.dart';
import 'package:resurgence/bank/bank.dart';
import 'package:resurgence/chat/chat.dart';
import 'package:resurgence/chat/mail.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/profile/profile_page.dart';
import 'package:resurgence/real-estate/read_estate.dart';
import 'package:resurgence/task/solo_task_page.dart';

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
        padding: EdgeInsets.all(8.0),
        childAspectRatio: 4.0,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        crossAxisCount: 2,
        shrinkWrap: true,
        children: <Widget>[
          _MenuItem(
            text: S.profile,
            icon: Icons.account_box,
            onPressed: () => push(context, widget: ProfilePage()),
          ),
          _MenuItem(
            text: S.tasks,
            icon: Icons.format_list_numbered,
            onPressed: () => push(context, widget: SoloTaskPage()),
          ),
          _MenuItem(
            text: S.bank,
            icon: Icons.account_balance,
            onPressed: () => push(context, route: BankPageRoute()),
          ),
          _MenuItem(
            text: S.mail,
            icon: Icons.mail,
            onPressed: () => push(context, route: MailPageRoute()),
          ),
          _MenuItem(
            text: S.realEstate,
            icon: Icons.work,
            onPressed: () => push(context, route: RealEstatePageRoute()),
          ),
          _MenuItem(
            text: S.chat,
            icon: Icons.people,
            onPressed: () => push(context, route: ChatRoute()),
          ),
        ],
      ),
    );
  }

  Future<T> push<T extends Object>(
    BuildContext context, {
    Route route,
    Widget widget,
  }) {
    return Navigator.push<T>(
      context,
      route ?? MaterialPageRoute(builder: (context) => widget),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    Key key,
    this.text,
    this.icon,
    this.onPressed,
  }) : super(key: key);

  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlineButton(
      onPressed: onPressed,
      child: Row(
        children: [
          Expanded(flex: 1, child: Icon(icon)),
          Expanded(flex: 2, child: Text(text)),
        ],
      ),
    );
  }
}

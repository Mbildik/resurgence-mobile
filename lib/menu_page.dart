import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/authentication/service.dart';
import 'package:resurgence/authentication/state.dart';
import 'package:resurgence/bank/bank.dart';
import 'package:resurgence/chat/chat.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/item/npc_counter_ui.dart';
import 'package:resurgence/multiplayer-task/page.dart';
import 'package:resurgence/notification/notification_message_ui.dart';
import 'package:resurgence/player/player.dart';
import 'package:resurgence/profile/profile_page.dart';
import 'package:resurgence/task/solo_task_page.dart';
import 'package:resurgence/ui/shared.dart';

class MenuPage extends StatefulWidget {
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Consumer<PlayerState>(
                      builder: (context, value, child) {
                        if (value.player == null)
                          return CircularProgressIndicator();
                        return ProfilePage(player: value.player);
                      },
                    ),
                    GridView.count(
                      primary: false,
                      padding: EdgeInsets.all(8.0),
                      childAspectRatio: 4.0,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      children: [
                        _MenuItem(
                          text: S.tasks,
                          icon: Icons.format_list_numbered,
                          onPressed: () => push(context, widget: SoloTaskPage()),
                        ),
                        _MenuItem(
                          text: S.multiplayerTasks,
                          icon: Icons.extension,
                          onPressed: () =>
                              push(context, route: MultiplayerTaskPageRoute()),
                        ),
                        _MenuItem(
                          text: S.bank,
                          icon: Icons.account_balance,
                          onPressed: () => push(context, route: BankPageRoute()),
                        ),
                        _MenuItem(
                          text: S.chat,
                          icon: Icons.people,
                          onPressed: () => push(context, route: ChatRoute()),
                        ),
                        _MenuItem(
                          text: S.messages,
                          icon: Icons.message,
                          onPressed: () =>
                              push(context, route: NotificationMessageRoute()),
                        ),
                        _MenuItem(
                          text: S.npc,
                          icon: Icons.category,
                          onPressed: () =>
                              push(context, route: NPCCounterRoute()),
                        ),
                        RaisedButton(
                          child: Text(S.logout),
                          color: Colors.red[700],
                          onPressed: () {
                            showConfirmationDialog(
                              context,
                              S.logoutConfirmationTitle,
                              S.logoutConfirmationContent,
                              S.logout,
                              S.cancel,
                              () {
                                context.read<AuthenticationState>().logout();
                                context.read<AuthenticationService>().logout();
                                return Future.value();
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    Container(
                      child: _OnlinePlayerInfo(),
                      margin: const EdgeInsets.only(bottom: 8.0),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
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

class _OnlinePlayerInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ChatState>(
      builder: (context, value, child) {
        if (value.onlineUsers == null) return Container();
        return RichText(
          text: TextSpan(
            text: S.onlineUserCount,
            style: Theme.of(context).textTheme.bodyText1.copyWith(),
            children: [
              TextSpan(text: ': '),
              TextSpan(
                text: value.onlineUsers.length.toString(),
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.green[700]),
              )
            ],
          ),
        );
      },
    );
  }
}

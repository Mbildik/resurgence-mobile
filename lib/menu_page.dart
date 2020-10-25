import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/bank/bank.dart';
import 'package:resurgence/chat/chat.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/item/npc_counter_ui.dart';
import 'package:resurgence/multiplayer-task/page.dart';
import 'package:resurgence/notification/notification_message_ui.dart';
import 'package:resurgence/player/player.dart';
import 'package:resurgence/player/service.dart';
import 'package:resurgence/profile/profile_page.dart';
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
            onPressed: () {
              context.read<PlayerService>().info().then((player) {
                context.read<PlayerState>().updatePlayer(player);
                push(context, widget: ProfilePage(player: player));
              });
            },
          ),
          _MenuItem(
            text: S.tasks,
            icon: Icons.format_list_numbered,
            onPressed: () => push(context, widget: SoloTaskPage()),
          ),
          _MenuItem(
            text: S.multiplayerTasks,
            icon: Icons.extension,
            onPressed: () => push(context, route: MultiplayerTaskPageRoute()),
          ),
          _MenuItem(
            text: S.bank,
            icon: Icons.account_balance,
            onPressed: () => push(context, route: BankPageRoute()),
          ),
          /*_MenuItem(
            text: S.realEstate,
            icon: Icons.work,
            onPressed: () => push(context, route: RealEstatePageRoute()),
          ),
          _MenuItem(
            text: S.families,
            icon: Icons.people,
            onPressed: () => push(context, route: FamiliesPageRoute()),
          ),
          Consumer<FamilyState>(
            builder: (context, state, child) {
              if (state.haveFamily) {
                return _MenuItem(
                  text: S.myFamily,
                  icon: Icons.my_location,
                  onPressed: () {
                    context.read<FamilyService>().info().then((value) {
                      state.family = value;
                      if (value != null) {
                        push(context, route: FamilyDetailRoute(state.family));
                      } else {
                        showInformationDialog(context, S.noFamilyAnymore)
                            .then((_) {
                          push(context, route: PlayerInvitationRoute());
                        });
                      }
                    });
                  },
                );
              }
              return child;
            },
            child: _MenuItem(
              text: S.applicationsInvitations,
              icon: Icons.merge_type,
              onPressed: () => push(context, route: PlayerInvitationRoute()),
            ),
          ),*/
          _MenuItem(
            text: S.chat,
            icon: Icons.people,
            onPressed: () => push(context, route: ChatRoute()),
          ),
          _MenuItem(
            text: S.messages,
            icon: Icons.message,
            onPressed: () => push(context, route: NotificationMessageRoute()),
          ),
          _MenuItem(
            text: S.npc,
            icon: Icons.category,
            onPressed: () => push(context, route: NPCCounterRoute()),
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

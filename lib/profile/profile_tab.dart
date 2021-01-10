import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/authentication/state.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/notification/notification_message_ui.dart';
import 'package:resurgence/player/player.dart';
import 'package:resurgence/player/skills.dart';
import 'package:resurgence/profile/profile_page.dart';

class ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final playerState = context.watch<PlayerState>();

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(playerState.player.nickname),
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.0),
                      topRight: Radius.circular(16.0),
                    ),
                  ),
                  builder: (context) {
                    return Container(
                      padding: EdgeInsets.only(top: 16.0),
                      height: MediaQuery.of(context).size.height * 0.1,
                      child: Column(
                        children: [
                          ListTile(
                            leading: Icon(Icons.logout),
                            title: Text(S.logout),
                            onTap: () =>
                                context.read<AuthenticationState>().logout(),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: DefaultTabController(
          length: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfilePage(player: playerState.player),
              SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  playerState.player.race.value,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: Colors.grey),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  playerState.player.title.value,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText1
                      .copyWith(color: Colors.grey),
                ),
              ),
              SizedBox(height: 16.0),
              TabBar(
                tabs: [
                  _ProfileTabBar(
                    icon: Icon(Icons.account_tree_outlined),
                    text: Text(S.skills),
                  ),
                  _ProfileTabBar(
                    icon: Icon(Icons.new_releases_outlined),
                    text: Text(S.news),
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Skills(),
                    NotificationMessagePage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileTabBar extends StatelessWidget {
  const _ProfileTabBar({Key key, this.icon, this.text}) : super(key: key);

  final Icon icon;
  final Widget text;

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          SizedBox(width: 4.0),
          text,
        ],
      ),
    );
  }
}

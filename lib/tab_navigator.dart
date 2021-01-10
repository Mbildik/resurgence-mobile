import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/multiplayer-task/page.dart';
import 'package:resurgence/navigation.dart';
import 'package:resurgence/player/online_players.dart';
import 'package:resurgence/player/profile.dart';
import 'package:resurgence/player/skills.dart';

class TabNavigatorRoutes {
  static const String root = '/';
  static const String detail = '/detail';
}

class TabNavigator extends StatelessWidget {
  TabNavigator(this.tabItem);

  final NavigationItem tabItem;

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    return {
      TabNavigatorRoutes.root: (context) => tabItem.screen,
      Routes.ONLINE_USERS: (context) => OnlinePlayers(),
      Routes.MULTIPLAYER_TASKS: (context) => MultiplayerTaskPage(),
      Routes.SKILLS: (context) => Skills(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final routes = _routeBuilders(context);
    return Navigator(
      key: tabItem.key,
      initialRoute: TabNavigatorRoutes.root,
      onGenerateRoute: (settings) {
        log('Route generated $settings');

        if (settings.name == Routes.USER_PROFILE) {
          final PlayerProfileRouteArguments args = settings.arguments;
          return MaterialPageRoute(
            builder: (context) => PlayerProfile(args?.player),
          );
        }
        final route = routes[settings.name];

        if (route != null) {
          return MaterialPageRoute(builder: (context) => route(context));
        }

        assert(false, 'Need to implement ${settings.name}');
        return null;
      },
    );
  }
}

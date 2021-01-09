import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/authentication/authentication_page.dart';
import 'package:resurgence/authentication/state.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/multiplayer-task/page.dart';
import 'package:resurgence/notification_handler.dart';
import 'package:resurgence/player/online_players.dart';
import 'package:resurgence/player/player_control_page.dart';
import 'package:resurgence/player/profile.dart';
import 'package:resurgence/player/skills.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class Application extends StatelessWidget {
  final FirebaseAnalytics analytics;

  const Application({Key key, this.analytics}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var darkTheme = ThemeData.dark();
    var theme = darkTheme.copyWith(
      textTheme: darkTheme.textTheme.copyWith(
        headline4: darkTheme.textTheme.headline4.copyWith(
          color: Colors.white,
        ),
        subtitle2: darkTheme.textTheme.subtitle2.copyWith(
          color: Colors.grey,
        ),
        button: darkTheme.textTheme.button.copyWith(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return OverlaySupport(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: S.applicationTitle,
        theme: theme,
        navigatorObservers: analytics != null
            ? [
                FirebaseAnalyticsObserver(analytics: analytics),
                SentryNavigatorObserver(),
              ]
            : const <NavigatorObserver>[],
        home: NotificationHandler(
          child: Consumer<AuthenticationState>(
            builder: (context, state, child) {
              if (state.isLoggedIn) {
                return PlayerControlPage();
              }
              return AuthenticationPage();
            },
          ),
        ),
        routes: {
          Routes.ONLINE_USERS: (context) => OnlinePlayers(),
          Routes.MULTIPLAYER_TASKS: (context) => MultiplayerTaskPage(),
          Routes.SKILLS: (context) => Skills(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == Routes.USER_PROFILE) {
            final PlayerProfileRouteArguments args = settings.arguments;
            return MaterialPageRoute(
              builder: (context) => PlayerProfile(args?.player),
            );
          }

          // we can implement more here

          assert(false, 'Need to implement ${settings.name}');
          return null;
        },
      ),
    );
  }
}

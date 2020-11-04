import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/authentication/authentication_page.dart';
import 'package:resurgence/authentication/state.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/notification_handler.dart';
import 'package:resurgence/player/player_control_page.dart';

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
            ? [FirebaseAnalyticsObserver(analytics: analytics)]
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
      ),
    );
  }
}

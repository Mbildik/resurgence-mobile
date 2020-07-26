import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/authentication/authentication_page.dart';
import 'package:resurgence/authentication/state.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/player/player_control_page.dart';

class Application extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var authenticationState = context.watch<AuthenticationState>();

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

    return MaterialApp(
      title: S.applicationTitle,
      theme: theme,
      home: buildBody(context, authenticationState),
    );
  }

  Widget buildBody(BuildContext context, AuthenticationState state) {
    if (state.isLoggedIn) {
      return PlayerControlPage();
    }
    return AuthenticationPage();
  }
}

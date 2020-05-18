import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/authentication/login_page.dart';
import 'package:resurgence/authentication/state.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/player/player_control_page.dart';

class Application extends StatelessWidget {
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    var authenticationState = context.watch<AuthenticationState>();
    return MaterialApp(
      title: S.applicationTitle,
      theme: ThemeData.dark(),
      home: buildBody(context, authenticationState),
    );
  }

  Widget buildBody(BuildContext context, AuthenticationState state) {
    if (state.isLoggedIn) {
      return PlayerControlPage();
    }
    return LoginPage();
  }
}

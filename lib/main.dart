import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/authentication/service.dart';
import 'package:resurgence/authentication/state.dart';
import 'package:resurgence/network/client.dart';
import 'package:resurgence/player/player.dart';
import 'package:resurgence/player/service.dart';

import 'application.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final authenticationState = AuthenticationState();
  final client = Client(authenticationState);

  // Authentication
  var authenticationStateProvider = ChangeNotifierProvider(
    create: (BuildContext context) => authenticationState,
  );
  var authenticationServiceProvider = Provider(
    create: (_) => AuthenticationService(client),
  );

  // Player
  var playerStateProvider = ChangeNotifierProvider(
    create: (BuildContext context) => PlayerState(),
  );
  var playerServiceProvider = Provider(
    create: (_) => PlayerService(client),
  );

  runApp(
    MultiProvider(
      providers: [
        // Authentication
        authenticationStateProvider,
        authenticationServiceProvider,

        // Player
        playerServiceProvider,
        playerStateProvider
      ],
      child: Application(),
    ),
  );
}

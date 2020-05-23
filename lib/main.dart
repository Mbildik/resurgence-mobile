import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/authentication/service.dart';
import 'package:resurgence/authentication/state.dart';
import 'package:resurgence/network/client.dart';
import 'package:resurgence/player/player.dart';
import 'package:resurgence/player/service.dart';
import 'package:resurgence/task/service.dart';

import 'application.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final authenticationState = AuthenticationState();
  final client = Client(authenticationState);

  // Authentication
  final authenticationStateProvider = ChangeNotifierProvider(
    create: (BuildContext context) => authenticationState,
  );
  final authenticationServiceProvider = Provider(
    create: (_) => AuthenticationService(client),
  );

  // Player
  final playerStateProvider = ChangeNotifierProvider(
    create: (BuildContext context) => PlayerState(),
  );
  final playerServiceProvider = Provider(
    create: (_) => PlayerService(client),
  );

  // Task
  final taskServiceProvider = Provider(
    create: (_) => TaskService(client),
  );

  runApp(
    MultiProvider(
      providers: [
        // Authentication
        authenticationStateProvider,
        authenticationServiceProvider,

        // Player
        playerServiceProvider,
        playerStateProvider,

        // Task
        taskServiceProvider,

      ],
      child: Application(),
    ),
  );
}

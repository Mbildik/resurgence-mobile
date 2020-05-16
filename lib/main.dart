import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/authentication/service.dart';
import 'package:resurgence/authentication/state.dart';
import 'package:resurgence/network/client.dart';

import 'application.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final authenticationState = AuthenticationState();
  final client = Client(authenticationState);

  var authenticationStateProvider = ChangeNotifierProvider(
    create: (BuildContext context) {
      return authenticationState;
    },
  );
  var authenticationServiceProvider = Provider(
    create: (_) => AuthenticationService(client),
  );

  runApp(
    MultiProvider(
      providers: [
        authenticationStateProvider,
        authenticationServiceProvider,
      ],
      child: Application(),
    ),
  );
}

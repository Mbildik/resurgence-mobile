import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/authentication/service.dart';
import 'package:resurgence/authentication/state.dart';
import 'package:resurgence/bank/service.dart';
import 'package:resurgence/chat/service.dart';
import 'package:resurgence/family/service.dart';
import 'package:resurgence/item/service.dart';
import 'package:resurgence/network/client.dart';
import 'package:resurgence/player/player.dart';
import 'package:resurgence/player/service.dart';
import 'package:resurgence/real-estate/service.dart';
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

  final itemServiceProvider = Provider(
    create: (_) => ItemService(client),
  );

  final bankServiceProvider = Provider(
    create: (_) => BankService(client),
  );

  // Mail
  final mailServiceProvider = Provider(
    create: (_) => MailService(client),
  );

  // Real Estate
  final realEstateServiceProvider = Provider(
    create: (_) => RealEstateService(client),
  );

  // Family Estate
  final familyServiceProvider = Provider(
    create: (_) => FamilyService(client),
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

        // Item
        itemServiceProvider,

        // Bank
        bankServiceProvider,

        // Mail
        mailServiceProvider,

        // Real Estate
        realEstateServiceProvider,

        // Family
        familyServiceProvider,
      ],
      child: Application(),
    ),
  );
}

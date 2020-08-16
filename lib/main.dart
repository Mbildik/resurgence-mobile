import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/authentication/service.dart';
import 'package:resurgence/authentication/state.dart';
import 'package:resurgence/bank/service.dart';
import 'package:resurgence/chat/client.dart';
import 'package:resurgence/chat/state.dart';
import 'package:resurgence/constants.dart';
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
  final authenticationStateProvider = ChangeNotifierProvider.value(
    value: authenticationState,
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

  // Real Estate
  final realEstateServiceProvider = Provider(
    create: (_) => RealEstateService(client),
  );

  // Family Estate
  final familyServiceProvider = Provider(
    create: (_) => FamilyService(client),
  );

  // Chat
  final ChatState chatState = ChatState();
  final chatStateProvider = ChangeNotifierProvider.value(
    value: chatState,
  );
  final chatClientProvider = Provider(
    create: (_) {
      var chatClient = ChatClient(S.wsUrl, chatState);
      authenticationState.addListener(() {
        if (!authenticationState.isLoggedIn) {
          chatClient.logout();
        }
      });
      return chatClient;
    },
    lazy: false,
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

        // Real Estate
        realEstateServiceProvider,

        // Family
        familyServiceProvider,

        // Chat
        chatClientProvider,
        chatStateProvider,
      ],
      child: Application(),
    ),
  );
}

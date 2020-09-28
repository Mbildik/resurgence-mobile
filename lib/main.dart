import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/authentication/service.dart';
import 'package:resurgence/authentication/state.dart';
import 'package:resurgence/bank/service.dart';
import 'package:resurgence/chat/client.dart';
import 'package:resurgence/chat/state.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/family/service.dart';
import 'package:resurgence/family/state.dart';
import 'package:resurgence/item/service.dart';
import 'package:resurgence/multiplayer-task/service.dart';
import 'package:resurgence/network/client.dart';
import 'package:resurgence/player/player.dart';
import 'package:resurgence/player/service.dart';
import 'package:resurgence/real-estate/service.dart';
import 'package:resurgence/task/service.dart';
import 'package:sentry/sentry.dart';

import 'application.dart';

bool get isInDebugMode {
  bool inDebugMode = false;
  assert(inDebugMode = true);
  return inDebugMode;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Monitoring
  final analytics = FirebaseAnalytics();
  final sentry = SentryClient(dsn: S.DSN);

  final authenticationState = AuthenticationState(sentryClient: sentry);
  final client = Client(authenticationState, sentryClient: sentry);

  // Authentication
  final authenticationStateProvider = ChangeNotifierProvider.value(
    value: authenticationState,
  );
  final authenticationServiceProvider = Provider(
    create: (_) => AuthenticationService(client, analytics: analytics),
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
  final familyStateProvider = ChangeNotifierProvider(
    create: (context) => FamilyState(),
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

  // Multiplayer Task
  final multiplayerServiceProvider = Provider(
    create: (_) => MultiplayerService(client),
  );

  FlutterError.onError = (details, {bool forceReport = false}) {
    if (isInDebugMode) {
      // In development mode, simply print to console.
      FlutterError.dumpErrorToConsole(details, forceReport: forceReport);
    } else {
      // In production mode, report to the application zone to report to
      // Sentry.
      sentry.captureException(
        exception: details.exception,
        stackTrace: details.stack,
      );
    }
  };

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
        familyStateProvider,

        // Chat
        chatClientProvider,
        chatStateProvider,

        // Multiplayer Task
        multiplayerServiceProvider,
      ],
      child: Application(analytics: analytics),
    ),
  );
}

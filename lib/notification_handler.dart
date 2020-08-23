import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/authentication/state.dart';

import 'authentication/service.dart';

class NotificationHandler extends StatefulWidget {
  const NotificationHandler({Key key, this.child})
      : assert(child != null),
        super(key: key);

  final Widget child;

  @override
  _NotificationHandlerState createState() => _NotificationHandlerState();
}

class _NotificationHandlerState extends State<NotificationHandler> {
  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription iosSubscription;

  VoidCallback tokenListener;

  @override
  void initState() {
    super.initState();
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        // save the token  OR subscribe to a topic here
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showOverlayNotification((context) {
          return GestureDetector(
            onVerticalDragUpdate: (details) {
              if (details.delta.dy > -1.4) return;
              // on swipe up
              OverlaySupportEntry.of(context).dismiss();
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: SafeArea(
                child: ListTile(
                  title: Text(message['notification']['title']),
                  subtitle: Text(message['notification']['body']),
                ),
              ),
            ),
          );
        }, duration: Duration(seconds: 4));
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );

    var authenticationState = context.read<AuthenticationState>();
    tokenListener = () {
      if (authenticationState.isLoggedIn) {
        this._fcm.getToken().then((token) {
          if (token == null || token.isEmpty) return;
          context
              .read<AuthenticationService>()
              .pushToken(token)
              .then((_) => authenticationState.removeListener(tokenListener));
        });
      }
    };
    authenticationState.addListener(tokenListener);
  }

  @override
  void dispose() {
    super.dispose();
    iosSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthenticationState>(
      builder: (context, state, child) => child,
      child: widget.child,
    );
  }
}

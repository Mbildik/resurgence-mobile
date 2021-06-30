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
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  StreamSubscription iosSubscription;

  VoidCallback tokenListener;

  @override
  void initState() {
    super.initState();

    if (Platform.isIOS) {
      // todo we need a permission after that listen.
      _fcm.requestPermission();
    }

    FirebaseMessaging.onMessage.listen((event) {
      print("Firebase Messaging onMessage: $event");
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
                title: Text(event.data['notification']['title']),
                subtitle: Text(event.data['notification']['body']),
              ),
            ),
          ),
        );
      }, duration: Duration(seconds: 10));
    });

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
    iosSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

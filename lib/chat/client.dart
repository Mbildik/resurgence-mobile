import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:resurgence/authentication/state.dart';
import 'package:resurgence/chat/model.dart';
import 'package:resurgence/constants.dart';
import 'package:stomp_dart_client/sock_js/sock_js_utils.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';

import 'state.dart';

class Client {
  String _token;
  String _playerName;
  StompClient _client;
  final Map<Subscription, Function({Map<String, String> unsubscribeHeaders})>
      callbacks = HashMap();

  final ChatState _state;

  Client(this._state, AuthenticationState state) {
    state.addListener(() {
      if (state.isLoggedIn) {
        var playerName = state.playerName();
        if (playerName == null) return;
        this._token = state.token.accessToken;
        this._playerName = playerName;
        var client = _init();
        client.activate();
      } else {
        if (_client != null) _client.deactivate();
        // dispose();
      }
    });
  }

  void subscribe(Subscription subscription) {
    _client.send(destination: '/p2p/${subscription.name}');
  }

  void searchUser(String player) {
    _client.send(destination: '/players/$player');
  }

  void clearSearchUserFilter() => _state.filteredUsers = Set();

  void sendText(Subscription subscription, String text) {
    _client.send(destination: '/send/${subscription.topic}', body: text);
  }

  StompClient _init() {
    var url = SockJsUtils()
        .generateTransportUrl('${S.baseUrl}ws')
        .replaceAll('#', ''); // todo refactor
    return StompClient(
      config: StompConfig(
        url: url,
        stompConnectHeaders: {
          HttpHeaders.authorizationHeader: 'Bearer $_token'
        },
        webSocketConnectHeaders: {
          HttpHeaders.authorizationHeader: 'Bearer $_token'
        },
        onConnect: (client, frame) {
          this._client = client;
          _initSubscriptions();
          _initOnlineUsers();
          _initPlayerFilterSubscription();
        },
        onStompError: (frame) => log('error ${frame.body}'),
        onDisconnect: (frame) => log('disconnected $frame'),
        useSockJS: true,
      ),
    );
  }

  void _initSubscriptions() {
    _client.subscribe(
      destination: '/user/$_playerName/subscriptions',
      callback: (frame) {
        var topics = Set<Subscription>.from((jsonDecode(frame.body) as List)
            .map((e) => Subscription.fromJson(e)));
        log('Current subscriptions ${frame.body}');
        var oldSubs = Set.of(_state.subscriptions);
        _state.subscribe(topics);
        oldSubs.removeAll(_state.subscriptions);
        _subscribe(oldSubs);
      },
    );
    this._client.send(destination: '/subscriptions');
  }

  void _subscribe(Set<Subscription> old) {
    callbacks.keys.where((e) => old.contains(e)).forEach((e) {
      try {
        // unsubscribe all old subs.
        log('Unsubscribing topic ${e.topic}');
        callbacks[e](unsubscribeHeaders: {});
        _state.clear(e);
      } catch (e) {
        log('An error occurred while unsubscribing', error: e);
      }
    });

    // clear callbacks
    callbacks.removeWhere((key, value) => old.contains(key));

    _state.subscriptions.forEach((sub) {
      if (callbacks.containsKey(sub)) return;

      log('Subscribing topic ${sub.topic}.');
      // todo callback fonksiyonu çalışması için saçma bir çözüm
      //  Future içine alarak sorundan kurtuluyoruz.
      //  aynı thread de olunca ya callback ataması yaparken sorun oluyor
      //  yada başka bir şey var anlamadım.
      Future.delayed(Duration.zero).then((_) {
        callbacks[sub] = _client.subscribe(
          destination: '/user/$_playerName/${sub.topic}',
          callback: (frame) {
            log('Message ${frame.body}');
            _state.onMessage(sub, Message.fromJson(jsonDecode(frame.body)));
          },
        );
      });
    });
  }

  void _initOnlineUsers() {
    Future.delayed(Duration.zero).then((_) {
      _client.subscribe(
        destination: '/user/$_playerName/online-players',
        callback: (frame) {
          _state.onlineUsers = Set<String>.from(jsonDecode(frame.body));
          log('online players ${_state.onlineUsers}');
        },
      );
    });
  }

  void _initPlayerFilterSubscription() {
    _client.subscribe(
      destination: '/user/$_playerName/players',
      callback: (frame) {
        _state.filteredUsers = Set<Subscription>.from(
            (jsonDecode(frame.body) as List)
                .map((e) => Subscription.fromJson(e)));
        log('filtered players ${frame.body}');
      },
    );
  }

// dispose() => _state.clear();
}

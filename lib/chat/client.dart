import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:resurgence/authentication/state.dart';
import 'package:resurgence/chat/model.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/player/player.dart';
import 'package:stomp_dart_client/sock_js/sock_js_utils.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';

import 'state.dart';

const String _LOG_TAG = 'CHAT_CLIENT: ';

class Client {
  String _token;
  String _playerName;
  StompClient _client;
  bool _isOpen = false;
  final Map<Subscription, Function({Map<String, String> unsubscribeHeaders})>
      callbacks = HashMap();
  final ChatState _state;

  Client(this._state, AuthenticationState state) {
    log('$_LOG_TAG constructor called');
    if (state.isLoggedIn) this._initialize(state);

    state.addListener(() {
      if (state.isLoggedIn)
        this._initialize(state);
      else
        this._destroy();
    });
  }

  void _initialize(AuthenticationState state) {
    if (this._isOpen) {
      this._destroy();
    }
    this._isOpen = true;
    log('$_LOG_TAG User has logged in');
    var playerName = state.playerName();
    log('$_LOG_TAG Player name is $playerName');
    if (playerName == null) return;
    this._token = state.token.accessToken;
    this._playerName = playerName;
    var client = _init();
    client.activate();
    log('$_LOG_TAG client activated');
  }

  void _destroy() {
    this._isOpen = false;
    log('$_LOG_TAG User has logged out, client deactivated');
    _client?.deactivate();
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
          log('on connect');
          _state.connectionState = ChatConnectionState.connected;
          _initSubscriptions();
          _initOnlineUsers();
          _initPlayerFilterSubscription();
          _subscribeUnread();
        },
        onStompError: (frame) {
          log('error ${frame.body}');
          _client.deactivate();
          this._init();
        },
        onDisconnect: (frame) {
          log('$_LOG_TAG disconnected $frame');
        },
        onWebSocketDone: () =>
            _state.connectionState = ChatConnectionState.disconnected,
        onWebSocketError: (e) {
          log('$_LOG_TAG onWebSocketError $e');
        },
        useSockJS: true,
      ),
    );
  }

  void _initSubscriptions() {
    _state.clearSubscriptions();
    _client.subscribe(
      destination: '/user/$_playerName/subscriptions',
      callback: (frame) {
        var topics = Set<Subscription>.from((jsonDecode(frame.body) as List)
            .map((e) => Subscription.fromJson(e)));
        log('Current subscriptions ${frame.body}');
        _state.subscribe(topics);
        _subscribe(_state.subscriptions);
      },
    );
    this._client.send(destination: '/subscriptions');
  }

  void _subscribe(Set<Subscription> subscriptions) {
    callbacks.clear();
    var firstReceiveTime; // todo improve this ugly code

    subscriptions.forEach((sub) {
      log('Subscribing topic ${sub.topic}.');
      callbacks[sub] = _client.subscribe(
        destination: '/user/$_playerName/${sub.topic}',
        callback: (frame) {
          if (firstReceiveTime == null) {
            firstReceiveTime = DateTime.now().millisecondsSinceEpoch;
          }
          log('Message ${frame.body}');
          var message = Message.fromJson(jsonDecode(frame.body));
          _state.onMessage(
            sub,
            message,
            notify: message.from != PlayerState.playerName &&
                firstReceiveTime != null &&
                DateTime.now().millisecondsSinceEpoch - firstReceiveTime > 5000,
          );
        },
      );
    });
  }

  void _initOnlineUsers() {
    _client.subscribe(
      destination: '/user/$_playerName/online-players',
      callback: (frame) =>
          _state.onlineUsers = Set<String>.from(jsonDecode(frame.body)),
    );
    _client.subscribe(
      destination: '/user/$_playerName/user-presence',
      callback: (frame) => _state.presences = (jsonDecode(frame.body) as List)
          .map((e) => Presence.fromJson(e))
          .toList(growable: false),
    );
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

  void _subscribeUnread() {
    _client.subscribe(
      destination: '/user/$_playerName/unread',
      callback: (frame) {
        var body = jsonDecode(frame.body);
        return _state.updateUnread(body['topic'], body['unread']);
      },
    );
  }

  void read(String topic) => _client.send(destination: '/read/$topic');
}

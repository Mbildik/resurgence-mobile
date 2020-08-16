import 'dart:async';
import 'dart:developer';

import 'package:resurgence/chat/client_messages.dart' as client;
import 'package:resurgence/chat/server_messages.dart' as server;
import 'package:resurgence/chat/shared_messages.dart' as shared;
import 'package:resurgence/chat/state.dart';
import 'package:web_socket_channel/io.dart';

typedef ServerMessageCallback = void Function(server.ServerMessage message);
typedef SendMessage = void Function(
  client.ClientMessage message, {
  ServerMessageCallback callback,
  bool removeOnEvent,
});

class ChatClient {
  final String url;
  final ChatState chatState;

  IOWebSocketChannel _channel;
  StreamSubscription _streamSubscription;
  Map<String, OnServerMessage> _onResponses = {};

  ChatClient(this.url, this.chatState) {
    chatState.sendMessage = this.sendMessage;
    _connect();
  }

  void createAccount(String username, String password) =>
      sendMessage(client.Acc.basic(username, password));

  void login(String username, String password) =>
      sendMessage(client.Login.basic(username, password));

  void addNickname(String nickname) {
    sendMessage(
      client.Set(
        topic: "me",
        desc: client.SetDesc(public: shared.Public(fn: nickname)),
        tags: List.from(chatState.tags)..add('nick:$nickname'),
      ),
    );
  }

  void fetchMessages(
    String topic, {
    int limit = 24,
  }) {
    sendMessage(
      client.Sub(
        topic: topic,
        subGet: client.Get(
          data: client.Data(limit: limit),
          what: 'data sub desc',
        ),
      ),
    );
  }

  void sendReadNote(String topic) {
    var currentData = chatState.currentData;
    if (currentData.isEmpty) return;

    var seq = currentData.first.seq;
    sendMessage(client.Note(
      topic: topic,
      what: 'read',
      seq: seq,
    ));
    chatState.updateSequence(topic, seq);
  }

  void leave(String topic) {
    sendMessage(client.Leave(topic: topic));
  }

  void sendTextMessage(String topic, String content) {
    sendMessage(client.Pub(topic: topic, noecho: false, content: content));
  }

  void searchUser(String nickname) {
    sendMessage(client.Set(
      topic: 'fnd',
      desc: client.SetDesc(publicString: 'nick:$nickname'),
    ));
    sendMessage(client.Get(topic: 'fnd', what: 'sub'));
  }

  void subscribeUser(String username) {
    sendMessage(
      client.Sub(
        topic: username,
        subSet: client.Set(
          sub: client.SetSub(mode: 'JRWPS'),
          desc: client.SetDesc(
            defacs: shared.Defacs(auth: 'JRWPS'),
          ),
        ),
        subGet: client.Get(
          data: client.Data(limit: 24),
          what: 'data sub desc',
        ),
      ),
    );
  }

  Future logout() async {
    await chatState.logout();
    reconnect();
  }

  Future reconnect() async {
    await _close();
    _connect();
  }

  void sendMessage(
    client.ClientMessage message, {
    ServerMessageCallback callback,
    bool removeOnEvent: true,
  }) {
    var json = message.json();
    log('Sent message: $json');
    _channel.sink.add(json);
    if (callback != null) {
      _onResponses[message.id] = OnServerMessage(removeOnEvent, callback);
    }
  }

  void _connect() {
    _channel = IOWebSocketChannel.connect(url);
    sendMessage(client.Hi());
    _streamSubscription = _channel.stream.map((event) {
      log('raw websocket message: $event');
      return server.ServerMessage.parse(event);
    }).listen((message) {
      final String messageId = message.id;

      if (messageId != null && _onResponses.containsKey(messageId)) {
        var onResponse = _onResponses[messageId];
        onResponse.callback(message);
        if (onResponse.remove) _onResponses.remove(messageId);
      }

      chatState.on(message);
    }, onError: (error) {
      log('websocket error', error: error);
    }, onDone: () {
      log('websocket connection closed!');
    });

    if (!chatState.isLogin()) {
      chatState
          .getToken()
          .then((token) => this.sendMessage(client.Login.token(token)))
          .catchError((e) => log('Websocket token not found. do nothing!'));
    }
  }

  Future _close() async {
    await _streamSubscription?.cancel();
    await _channel?.sink?.close(1000, 'Normal closure');
    chatState.cleanToken();
    _onResponses = {};
  }
}

class OnServerMessage {
  final bool remove;
  final ServerMessageCallback callback;

  OnServerMessage(this.remove, this.callback);
}

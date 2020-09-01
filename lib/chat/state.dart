import 'dart:collection';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:resurgence/chat/client.dart';
import 'package:resurgence/chat/client_messages.dart' as client;
import 'package:resurgence/chat/server_messages.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatState extends ChangeNotifier {
  static const _WEBSOCKET_TOKEN_KEY = 'websocket_token';

  SendMessage _sendMessage;
  String _token;

  String username;
  Set<String> tags = HashSet();
  Set<Sub> subs = HashSet();
  Set<String> onlineUsers = HashSet();
  SplayTreeSet<Data> currentData = SplayTreeSet(
    (data1, data2) => data2.seq.compareTo(data1.seq),
  );
  Map<String, String> usernameNickMap = HashMap();

  Set<Sub> fndSub = HashSet();

//  Desc desc;

  ChatState() {
    getToken().then((value) => _token = value).catchError((e) {
      log('Token not found initializing chat state.', error: e);
    });
  }

  void on(ServerMessage message) {
//    log('On server message. $message');

    switch (message.runtimeType) {
      case Data:
        return _onData(message);
      case Ctrl:
        return _onCtrl(message);
      case Meta:
        return _onMeta(message);
      case Pres:
        return _onPres(message);
      default:
        log('Missing message handler for ${message.runtimeType} $message');
    }
  }

  Future<String> getToken() {
    if (_token != null) return Future.value(_token);
    return _getToken();
  }

  bool isLogin() {
    return _token != null;
  }

  // reset all values
  Future<void> logout() async {
    await _removeToken();
    _token = null;
    username = null;
    tags.clear();
    subs.clear();
    onlineUsers.clear();
    currentData.clear();
    fndSub.clear();
    usernameNickMap.clear();
  }

  void cleanToken() {
    _token = null;
    username = null;
  }

  void updateSequence(String topic, int read) {
    subs.where((s) => s.topic == topic).forEach((s) => s.read = read);
    notifyListeners();
  }

  set sendMessage(SendMessage value) {
    _sendMessage = value;
  }

  void _onCtrl(Ctrl message) {
    String messageId = message.id;
    String clientMessageType =
        messageId.contains('__') ? messageId.split('__').first : null;

    if (clientMessageType == null) {
      return _handleUnknownMessage(message);
    }

    switch (clientMessageType) {
      case 'Login':
        return _onLogin(message);
      case 'Leave':
        return _onLeave(message);
      case 'Get':
        return _onGet(message);
    }
  }

  void _onLogin(Ctrl message) {
    if (message.code != 200)
      throw Exception('Websocket login failed. $message');

    _token = message.params['token'];
    username = message.params['user'];
    log('login succeed. Token: $_token');
    _sendMessage(client.Sub(
      topic: 'me',
      subGet: client.Get(what: 'sub desc tags'),
    ));
    _sendMessage(client.Sub(topic: 'fnd'));
    _saveToken(_token);
  }

  void _onGet(Ctrl message) {
    if (message.topic == 'fnd' && message.code == 204) {
      fndSub.clear();
    }
  }

  void _onMeta(Meta message) {
    bool notify = false;

    if (message.topic == 'me') {
      if (message.tags != null) {
        tags.addAll(message.tags);
        notify = true;
      }
      if (message.sub != null) {
        subs.addAll(message.sub);
        subs.where((s) => s.online).forEach((s) => onlineUsers.add(s.topic));
        notify = true;
      }
      // if (message.desc != null) {
      //   desc = message.desc;
      //   notify = true;
      // }
    } else if (message.topic == 'fnd') {
      if (message.sub != null) {
        message.sub.forEach((s) => s.topic = s.user);
        fndSub.addAll(message.sub);
        notify = true;
      }
    } else if (message.topic.startsWith('grp')) {
      if (message.sub != null) {
        usernameNickMap.addAll(Map.fromEntries(
            message.sub.map((e) => MapEntry(e.user, e.public.fn))));
        notify = true;
      }
    }
    if (notify) notifyListeners();
  }

  void _onPres(Pres message) {
    bool notify = false;
    if (message.topic == 'me') {
      if (message.what == 'on') {
        onlineUsers.add(message.src);
        notify = true;
      } else if (message.what == 'off') {
        onlineUsers.remove(message.src);
        notify = true;
      } else if (message.what == 'msg') {
        subs
            .where((s) => s.topic == message.src)
            .forEach((s) => s.seq = message.seq);
        notify = true;
      } else if (message.what == 'acs') {
        _sendMessage(
          client.Get(
            topic: 'me',
            what: 'sub',
            sub: client.GetSub(topic: message.src),
          ),
        );
      }
    }
    if (notify) notifyListeners();
  }

  void _onData(Data message) {
    currentData.add(message);
    notifyListeners();
  }

  void _onLeave(Ctrl message) {
    currentData.clear();
  }

  void _handleUnknownMessage(Ctrl message) {
    log('Handling unknown message $message');
  }

  Future<String> _getToken() {
    return SharedPreferences.getInstance().then((sp) {
      var token = sp.getString(_WEBSOCKET_TOKEN_KEY);
      if (token == null)
        throw Exception('Websocket token not found in SharedPreferences');
      return token;
    });
  }

  Future<void> _saveToken(String token) => SharedPreferences.getInstance()
      .then((sp) => sp.setString(_WEBSOCKET_TOKEN_KEY, token));

  Future<void> _removeToken() => SharedPreferences.getInstance()
      .then((sp) => sp.remove(_WEBSOCKET_TOKEN_KEY));
}

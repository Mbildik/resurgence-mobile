import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:resurgence/constants.dart';

import 'model.dart';

enum ChatConnectionState { connected, connecting, disconnected }

class ChatState extends ChangeNotifier {
  Set<Subscription> _subscriptions = Set();
  Set<String> _onlineUsers = Set();
  Set<Subscription> _filteredUsers = Set();
  Map<Subscription, SplayTreeSet<Message>> _subsMessages = HashMap();
  ChatConnectionState _connectionState = ChatConnectionState.disconnected;
  bool chatPageOpen = false;
  List<Presence> _presences = List();

  void subscribe(Set<Subscription> subscriptions) {
    var oldSubs = Set<Subscription>.from(_subscriptions);
    _subscriptions = subscriptions;
    _subscriptions.forEach((s) {
      s.lastMessage = oldSubs
          .firstWhere(
            (os) => os == s,
            orElse: () => null,
          )
          ?.lastMessage;
    });
    notifyListeners();
  }

  void onMessage(
    Subscription subscription,
    Message message, {
    bool notify = false,
  }) {
    if (!_subsMessages.containsKey(subscription)) {
      _subsMessages[subscription] = SplayTreeSet(
        (data1, data2) => data2.sequence.compareTo(data1.sequence),
      );
    }
    _subsMessages[subscription].add(message);
    _subscriptions
        .firstWhere((e) => e == subscription, orElse: () => null)
        ?.lastMessage = _subsMessages[subscription].first;

    notifyListeners();

    if (notify && !chatPageOpen) {
      showOverlayNotification((context) {
        String title =
            subscription.isGroup() ? subscription.name : message.from;
        String sender = message.from;

        Widget subtitle;
        if (subscription.isGroup()) {
          subtitle = RichText(
            text: TextSpan(
              text: sender,
              style: Theme.of(context).textTheme.bodyText1,
              children: [
                TextSpan(text: ': '),
                TextSpan(
                  text: message.content,
                  style: Theme.of(context).textTheme.bodyText2,
                ),
              ],
            ),
          );
        } else {
          subtitle = Text(message.content);
        }

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
                leading: _getImage(subscription),
                title: Text(title),
                subtitle: subtitle,
              ),
            ),
          ),
        );
      }, duration: Duration(seconds: 1));
    }
  }

  set onlineUsers(Set<String> value) {
    _onlineUsers = value;
    notifyListeners();
  }

  void clearSubscriptions() {
    _subscriptions.clear();
    _subsMessages.clear();
    notifyListeners();
  }

  Set<Subscription> get filteredUsers => _filteredUsers;

  set filteredUsers(Set<Subscription> value) {
    _filteredUsers = value;
    notifyListeners();
  }

  Set<Message> messages(Subscription subscription) =>
      _subsMessages[subscription] ?? Set();

  Set<Subscription> get subscriptions => _subscriptions;

  Set<String> get onlineUsers => _onlineUsers;

  void updateUnread(String topic, bool unread) {
    var subs = _subscriptions.firstWhere(
      (e) => e.topic == topic,
      orElse: () => null,
    );
    if (subs == null) return;
    if (subs.unread == unread) return;

    subs.unread = unread;
    notifyListeners();
  }

  ChatConnectionState get connectionState => _connectionState;

  set connectionState(ChatConnectionState value) {
    if (value == _connectionState) return;
    _connectionState = value;
    notifyListeners();
  }

  int unreadMessageCount() {
    var fold = _subscriptions.fold(0, (v, e) {
      return e.unread ? ++v : v;
    });
    return fold;
  }

  List<Presence> get presences {
    _presences.sort((x, y) {
      var online = (x.online == y.online) ? 0 : (x.online ? -1 : 1);
      return online == 0 ? x.duration.compareTo(y.duration) : online;
    });
    return _presences;
  }

  set presences(List<Presence> value) {
    _presences = value;
    notifyListeners();
  }
}

Image _getImage(Subscription sub) {
  var url = S.baseUrl + 'player/image/${sub.name}';
  if (sub.isGroup()) {
    url = S.baseUrl + 'static/chat/${sub.topic}.png';
  }
  return Image.network(url, height: 48.0, width: 48.0);
}

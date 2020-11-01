import 'dart:collection';

import 'package:flutter/foundation.dart';

import 'model.dart';

class ChatState extends ChangeNotifier {
  Set<Subscription> _subscriptions = Set();
  Set<String> _onlineUsers = Set();
  Set<Subscription> _filteredUsers = Set();
  Map<Subscription, SplayTreeSet<Message>> _subsMessages = HashMap();

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

  void onMessage(Subscription subscription, Message message) {
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
}

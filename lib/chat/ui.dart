import 'dart:collection';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/chat/chat.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/player/player.dart';

Image getImage(Subscription sub) {
  if (sub.isGroup()) {
    return Image.network(S.baseUrl + 'static/chat/${sub.topic}.png');
  }
  return Image.network(S.baseUrl + 'player/image/${sub.name}');
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _filterController = new TextEditingController();

  String filter = '';
  Client _client;
  ChatState _chatState;

  @override
  void initState() {
    super.initState();
    _chatState = context.read<ChatState>();
    _chatState.chatPageOpen = true;
    _client = context.read<Client>();
    _filterController.addListener(() {
      var value = _filterController.text.trim();
      if (filter == value) return; // same filter. do not search.
      if (value.isNotEmpty) {
        // search only user enter some text.
        _client.searchUser(value);
      } else {
        _client.clearSearchUserFilter();
      }
      setState(() => filter = value);
    });
  }

  @override
  void dispose() {
    _chatState?.chatPageOpen = false;
    _filterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.chat),
      ),
      body: Column(
        children: [
          TextField(
            controller: _filterController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(16.0),
              hintText: S.search,
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon:
                    filter.isNotEmpty ? Icon(Icons.clear) : Icon(Icons.search),
                onPressed: () {
                  if (filter.isNotEmpty) _filterController.clear();
                },
              ),
            ),
          ),
          Container(height: 1, color: Theme.of(context).colorScheme.background),
          Expanded(
            child: Consumer<ChatState>(
              builder: (context, state, child) {
                if (state.connectionState != ChatConnectionState.connected) {
                  return Center(child: CircularProgressIndicator());
                }

                Set<Subscription> subscriptions = orderSubs(state);

                var fndSubscriptions = state.filteredUsers;
                subscriptions.addAll(fndSubscriptions);

                return ListView.builder(
                  primary: false,
                  itemCount: subscriptions.length,
                  itemBuilder: (context, index) {
                    var currentSub = subscriptions.elementAt(index);
                    var subName = currentSub.name;
                    if (filter.isNotEmpty &&
                        !subName.toLowerCase().contains(filter.toLowerCase())) {
                      return Container();
                    }

                    var online = state.onlineUsers.contains(subName);
                    var read = !currentSub.unread;
                    var image = getImage(currentSub);

                    return _ChatListItem(
                      image: image,
                      title: subName,
                      content: currentSub.lastMessage?.content ?? '',
                      read: read,
                      online: online,
                      showOnline: !currentSub.isGroup(),
                      onClick: () {
                        if (fndSubscriptions.contains(currentSub) &&
                            !state.subscriptions.contains(currentSub)) {
                          _client.subscribe(currentSub);
                        }
                        return Navigator.push(
                          context,
                          _MessageRoute(currentSub),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Set<Subscription> orderSubs(ChatState state) {
    if (filter.isNotEmpty) {
      return HashSet<Subscription>.from(
        state.subscriptions,
      );
    } else {
      return SplayTreeSet(
        (data1, data2) {
          if (data1.lastMessage == null || data2.lastMessage == null) {
            return 0;
          }
          return data2.lastMessage.time.compareTo(data1.lastMessage.time);
        },
      )..addAll(state.subscriptions);
    }
  }
}

class _ChatDetail extends StatelessWidget {
  const _ChatDetail({Key key, this.sub}) : super(key: key);

  final Subscription sub;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: ListTile(
            leading: Image(image: getImage(sub).image, width: 48),
            title: Text(sub.name),
            subtitle: sub.isGroup()
                ? Container()
                : Consumer<ChatState>(
                    builder: (context, state, child) =>
                        state.onlineUsers.contains(sub.name)
                            ? child
                            : Text(S.offline),
                    child: Text(S.online),
                  ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Consumer<ChatState>(
                builder: (context, state, child) {
                  var messages = state.messages(sub);

                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.only(top: 8.0),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages.elementAt(index);

                      return _MessageBubble(
                        screenWidth: screenWidth,
                        owner: message.from == PlayerState.playerName,
                        text: message.content,
                        sender: sub.isGroup() ? message.from : null,
                        time: message.time,
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              height: 1,
              color: Theme.of(context).colorScheme.background,
            ),
            _MessageInput(sub),
          ],
        ),
      ),
      onWillPop: () async {
        try {
          context.read<Client>().read(sub.topic);
        } catch (e) {}
        return true;
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  _MessageBubble({
    @required this.screenWidth,
    @required this.text,
    @required this.owner,
    this.sender,
    this.time,
  });

  final double screenWidth;
  final String text;
  final bool owner;
  final String sender;
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    final margin = EdgeInsets.only(
      bottom: 8.0,
      right: owner ? 8.0 : 0.0,
      left: owner ? 0.0 : 8.0,
    );
    final color = owner ? Colors.blue[700] : Colors.white24;
    final alignment = owner ? WrapAlignment.end : WrapAlignment.start;

    return Wrap(
      alignment: alignment,
      children: [
        Card(
          margin: margin,
          color: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(8.0),
              topRight: Radius.circular(8.0),
              topLeft: owner ? Radius.circular(8.0) : Radius.circular(0),
              bottomRight: owner ? Radius.circular(0) : Radius.circular(8.0),
            ),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: messageBody(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget messageBody(BuildContext context) {
    if (owner || sender == null) {
      return MessageContentWidget(text: text, time: time);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sender,
          textScaleFactor: 1.1,
          style: Theme.of(context)
              .textTheme
              .bodyText1
              .copyWith(color: Colors.amber),
        ),
        MessageContentWidget(text: text, time: time),
      ],
    );
  }
}

class MessageContentWidget extends StatelessWidget {
  const MessageContentWidget({
    Key key,
    @required this.text,
    @required this.time,
  }) : super(key: key);

  final String text;
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 32.0),
          child: SelectableText(
            text,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ),
        const SizedBox(height: 1.0),
        Text(
          DateFormat('HH:mm').format(time.toLocal()),
          style: Theme.of(context)
              .textTheme
              .subtitle2
              .copyWith(fontSize: 12.0, color: Colors.white54),
        ),
      ],
    );
  }
}

class _MessageInput extends StatefulWidget {
  const _MessageInput(this.sub, {Key key}) : super(key: key);

  final Subscription sub;

  @override
  __MessageInputState createState() => __MessageInputState();
}

class __MessageInputState extends State<_MessageInput> {
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextField(
        controller: textController,
        minLines: 1,
        maxLines: 3,
        keyboardType: TextInputType.multiline,
        onSubmitted: (_) => send(),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(16.0),
          hintText: S.typeSomething,
          border: InputBorder.none,
          suffixIcon: Consumer<ChatState>(
            builder: (context, value, child) {
              if (value.connectionState != ChatConnectionState.connected) {
                return Padding(
                  padding: EdgeInsets.all(4.0),
                  child: CircularProgressIndicator(),
                );
              }

              return child;
            },
            child: IconButton(
              icon: Icon(Icons.send),
              onPressed: send,
            ),
          ),
        ),
      ),
    );
  }

  void send() {
    var text = textController.text.trim();
    if (text.isNotEmpty) {
      var client = context.read<Client>();
      client.sendText(widget.sub, text);
    }
    textController.text = '';
  }
}

class _ChatListItem extends StatelessWidget {
  const _ChatListItem({
    Key key,
    this.image,
    this.title,
    this.content,
    this.read = false,
    this.online = false,
    this.onClick,
    this.showOnline = true,
  }) : super(key: key);

  final Image image;
  final String title;
  final String content;
  final bool read;
  final bool online;
  final bool showOnline;
  final Function onClick;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Image(image: image.image, width: 48),
          showOnline
              ? Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: online ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                )
              : Container(height: 0, width: 0)
        ],
      ),
      title: Text(title),
      subtitle: Text(
        content,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: notificationWidget(),
      onTap: onClick,
    );
  }

  Widget notificationWidget() {
    if (read) return null;

    return Icon(Icons.markunread);
  }
}

class ChatRoute<T> extends MaterialPageRoute<T> {
  ChatRoute() : super(builder: (BuildContext context) => ChatPage());
}

class _MessageRoute<T> extends MaterialPageRoute<T> {
  final Subscription sub;

  _MessageRoute(this.sub)
      : super(builder: (BuildContext context) => _ChatDetail(sub: sub));
}

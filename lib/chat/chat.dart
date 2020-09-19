import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/chat/client.dart';
import 'package:resurgence/chat/server_messages.dart';
import 'package:resurgence/chat/state.dart';
import 'package:resurgence/constants.dart';

Image getImage(Sub sub) {
  var photo = sub.public.photo;
  Image image;
  if (photo != null) {
    var bytes = base64Decode(photo.data);
    image = Image.memory(bytes);
  } else {
    image = Image.network('https://picsum.photos/56');
  }
  return image;
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController filterController = new TextEditingController();
  String filter = '';

  @override
  void initState() {
    super.initState();
    var chatClient = context.read<ChatClient>();
    filterController.addListener(() {
      var value = filterController.text.trim();
      if (value.isNotEmpty) {
        chatClient.searchUser(filter);
      }
      setState(() => filter = value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.messages),
      ),
      body: Column(
        children: [
          TextField(
            controller: filterController,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(16.0),
              hintText: S.search,
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon:
                    filter.isNotEmpty ? Icon(Icons.clear) : Icon(Icons.search),
                onPressed: () {
                  if (filter.isNotEmpty) filterController.clear();
                },
              ),
            ),
          ),
          Container(height: 1, color: Theme.of(context).colorScheme.background),
          Expanded(
            child: Consumer<ChatState>(
              builder: (context, state, child) {
                var subscriptions = SplayTreeSet<Sub>.from(
                  state.subs,
                  (sub1, sub2) => sub2.updated.compareTo(sub1.updated),
                );
                var fndSubscriptions = state.fndSub;
                subscriptions.addAll(state.fndSub);

                return ListView.builder(
                  primary: false,
                  itemCount: subscriptions.length,
                  itemBuilder: (context, index) {
                    var currentSub = subscriptions.elementAt(index);
                    var sender = currentSub.public.fn;

                    if (!sender.toLowerCase().contains(filter.toLowerCase())) {
                      return Container();
                    }

                    var online = state.onlineUsers.contains(currentSub.topic);
                    var read = currentSub.seq - currentSub.read <= 0;
                    var image = getImage(currentSub);
                    var lastUpdate = currentSub.updated;

                    return _ChatListItem(
                      image: image,
                      title: sender,
                      content: DateFormat(S.dateFormat).format(
                        lastUpdate.toLocal(),
                      ),
                      read: read,
                      online: online,
                      onClick: () {
                        var chatClient = context.read<ChatClient>();
                        if (fndSubscriptions.contains(currentSub) &&
                            !subscriptions.contains(currentSub)) {
                          chatClient.subscribeUser(currentSub.user);
                        }
                        chatClient.fetchMessages(currentSub.topic);
                        return Navigator.push(
                            context, _MessageRoute(currentSub));
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
}

class _ChatDetail extends StatelessWidget {
  const _ChatDetail({Key key, this.sub}) : super(key: key);

  final Sub sub;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: ListTile(
            leading: CircleAvatar(
              backgroundImage: getImage(sub).image,
            ),
            title: Text(sub.public.fn),
            subtitle: Consumer<ChatState>(
              builder: (context, state, child) =>
                  state.onlineUsers.contains(sub.topic)
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
                  var messages = state.currentData;

                  return ListView.builder(
                    reverse: true,
                    padding: EdgeInsets.only(top: 8.0),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      var message = messages.elementAt(index);

                      return _MessageBubble(
                        screenWidth: screenWidth,
                        owner: message.from == state.username,
                        text: message.content,
                        sender: sub.topic.startsWith('grp')
                            ? state.usernameNickMap[message.from]
                            : null,
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
            _MessageInput(sub.topic),
          ],
        ),
      ),
      onWillPop: () async {
        var client = context.read<ChatClient>();
        client.sendReadNote(sub.topic);
        client.leave(sub.topic);
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
  });

  final double screenWidth;
  final String text;
  final bool owner;
  final String sender;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          owner ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin:
              owner ? EdgeInsets.only(right: 8.0) : EdgeInsets.only(left: 8.0),
          constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: owner ? Radius.circular(0) : Radius.circular(8.0),
                topLeft: owner ? Radius.circular(8.0) : Radius.circular(0),
                topRight: Radius.circular(8.0),
              ),
            ),
            color: owner ? Colors.blue : Colors.white24,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: messageBody(context),
            ),
          ),
        ),
        SizedBox(height: 8.0),
      ],
    );
  }

  Widget messageBody(BuildContext context) {
    if (owner || sender == null) return SelectableText(text);

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
        SelectableText(text),
      ],
    );
  }
}

class _MessageInput extends StatefulWidget {
  const _MessageInput(this.topic, {Key key}) : super(key: key);

  final String topic;

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
          suffixIcon: IconButton(
            icon: Icon(Icons.send),
            onPressed: send,
          ),
        ),
      ),
    );
  }

  void send() {
    var text = textController.text.trim();
    if (text.isNotEmpty) {
      var client = context.read<ChatClient>();
      client.sendTextMessage(widget.topic, text);
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
  }) : super(key: key);

  final Image image;
  final String title;
  final String content;
  final bool read;
  final bool online;
  final Function onClick;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        alignment: Alignment.bottomRight,
        children: [
          CircleAvatar(backgroundImage: image.image),
          Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(
              color: online ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          )
        ],
      ),
      title: Text(title),
      subtitle: Text(content),
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
  final Sub sub;

  _MessageRoute(this.sub)
      : super(builder: (BuildContext context) => _ChatDetail(sub: sub));
}

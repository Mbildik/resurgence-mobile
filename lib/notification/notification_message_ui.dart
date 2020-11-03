import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/notification/model.dart';
import 'package:resurgence/notification/service.dart';
import 'package:resurgence/ui/error_handler.dart';
import 'package:resurgence/ui/shared.dart';

class NotificationMessagePage extends StatefulWidget {
  @override
  _NotificationMessagePageState createState() =>
      _NotificationMessagePageState();
}

class _NotificationMessagePageState extends State<NotificationMessagePage> {
  Future<List<Message>> _messagesFuture;
  MessageService _service;

  @override
  void initState() {
    super.initState();
    _service = context.read<MessageService>();
    _messagesFuture = _service.messages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.messages),
      ),
      body: LoadingFutureBuilder<List<Message>>(
        future: _messagesFuture,
        onError: _onError,
        builder: (context, snapshot) {
          var messages = List.of(snapshot.data);

          return RefreshIndicator(
            onRefresh: () {
              var future = _service.messages();
              setState(() {
                _messagesFuture = future;
              });
              return future;
            },
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                var message = messages[index];

                return Dismissible(
                  key: ValueKey(message.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 8.0),
                    child: Text(S.delete),
                    color: Colors.red,
                  ),
                  onDismissed: (direction) {
                    _service
                        .delete(message.id)
                        .catchError((e) => ErrorHandler.showError(context, e));
                  },
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(message.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(message.content),
                            SizedBox(height: 16.0),
                            Text(
                              DateFormat(S.dateFormat).format(
                                message.time.toLocal(),
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                      Divider(height: 0),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  _onError() => this._refresh();

  _refresh() => setState(() {
        _messagesFuture = _service.messages();
      });
}

class NotificationMessageRoute<T> extends MaterialPageRoute<T> {
  NotificationMessageRoute()
      : super(builder: (BuildContext context) => NotificationMessagePage());
}

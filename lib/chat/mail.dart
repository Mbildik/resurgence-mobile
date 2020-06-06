import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/chat/service.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/ui/button.dart';
import 'package:resurgence/ui/error_handler.dart';

const String REPLY_SEPARATOR = "\n___\n";
const String FROM_SEPARATOR = "\n~~~\n";

class Mail {
  int id;
  String from;
  String to;
  String content;
  DateTime time;
  bool read;

  Mail({this.id, this.from, this.to, this.content, this.time, this.read});

  Mail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    from = json['from'];
    to = json['to'];
    content = json['content'];
    time = DateTime.parse(json['time']).toLocal();
    read = json['read'];
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Mail && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum _Menu { send, incoming, outgoing }

class MailPage extends StatefulWidget {
  @override
  _MailPageState createState() => _MailPageState();
}

class _MailPageState extends State<MailPage> {
  _Menu menu = _Menu.incoming;
  Future<List<Mail>> incomingMailFuture;
  Future<List<Mail>> outgoingMailFuture;

  @override
  void initState() {
    super.initState();
    var mailService = context.read<MailService>();
    if (menu == _Menu.incoming) incomingMailFuture = mailService.incoming();
    if (menu == _Menu.outgoing) outgoingMailFuture = mailService.outgoing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.mail),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (int selected) {
          setState(() => menu = _Menu.values[selected]);
          _refresh();
        },
        currentIndex: menu.index,
        items: [
          BottomNavigationBarItem(
            title: Text(S.send),
            icon: Icon(Icons.send),
          ),
          BottomNavigationBarItem(
            title: Text(S.received),
            icon: Icon(Icons.call_received),
          ),
          BottomNavigationBarItem(
            title: Text(S.sent),
            icon: Icon(Icons.call_made),
          ),
        ],
      ),
      body: _pageBody(),
    );
  }

  Widget _pageBody() {
    switch (menu) {
      case _Menu.send:
        return sendMailWidget();
      case _Menu.incoming:
        return incomingMailWidget();
      case _Menu.outgoing:
        return outgoingMailWidget();
      default:
        return incomingMailWidget();
    }
  }

  Widget sendMailWidget() {
    return SendMailWidget();
  }

  Widget incomingMailWidget() {
    return baseMailWidget(incomingMailFuture, false);
  }

  Widget outgoingMailWidget() {
    return baseMailWidget(outgoingMailFuture, true);
  }

  Widget baseMailWidget(Future<List<Mail>> future, bool readonly) {
    return FutureBuilder<List<Mail>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingWidget();
        } else if (snapshot.hasError) {
          return _errorWidget();
        }

        return MailListView(
          snapshot.data,
          sent: readonly,
        );
      },
    );
  }

  void _refresh() {
    var mailService = context.read<MailService>();
    if (menu == _Menu.incoming) {
      setState(() {
        incomingMailFuture = mailService.incoming();
      });
    } else if (menu == _Menu.outgoing) {
      setState(() {
        outgoingMailFuture = mailService.outgoing();
      });
    }
  }

  Widget _loadingWidget() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _errorWidget() {
    return Center(
      child: Column(
        children: <Widget>[
          Button(
            child: Text(S.reload),
            onPressed: () => _refresh(),
          ),
          Text(S.errorOccurred),
        ],
      ),
    );
  }
}

class SendMailWidget extends StatefulWidget {
  const SendMailWidget({
    Key key,
    this.reply,
    this.mail,
  }) : super(key: key);

  final String reply;
  final Mail mail;

  @override
  _SendMailWidgetState createState() => _SendMailWidgetState();
}

class _SendMailWidgetState extends State<SendMailWidget> {
  final _formKey = GlobalKey<FormState>();
  final mailToController = TextEditingController();
  final mailContentController = TextEditingController();

  bool loading = false;
  bool isReply = false;

  @override
  void initState() {
    super.initState();
    var reply = widget.reply;
    if (reply != null && reply.isNotEmpty) {
      mailToController.text = reply;
      isReply = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            _toTextFormField(context),
            _contentTextFormField(context),
            SizedBox(height: 8.0),
            _submitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _submitButton(BuildContext context) {
    if (loading) return CircularProgressIndicator();

    return Button(
      child: Text(S.send),
      onPressed: () {
        if (!_formKey.currentState.validate()) return;

        FocusScope.of(context).unfocus();
        setState(() => loading = true);

        String content = mailContentController.text;
        if (isReply) {
          content += REPLY_SEPARATOR +
              widget.mail.from +
              FROM_SEPARATOR +
              widget.mail.content;
        }
        context
            .read<MailService>()
            .send(mailToController.text, content)
            .then((_) {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  content: Text(S.sentSuccessfully),
                  duration: Duration(seconds: 1),
                ),
              );
            })
            .catchError((e) => ErrorHandler.showError<Null>(context, e))
            .whenComplete(() {
              setState(() => loading = false);
              mailToController.text = '';
              mailContentController.text = '';
            });
      },
    );
  }

  Widget _contentTextFormField(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(labelText: S.mail),
      minLines: 1,
      maxLines: 5,
      controller: mailContentController,
      onFieldSubmitted: (value) => FocusScope.of(context).unfocus(),
      validator: (value) {
        if (value.isEmpty) return S.validationRequired;
        return null;
      },
    );
  }

  Widget _toTextFormField(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(labelText: S.to),
      enabled: !isReply,
      textInputAction: TextInputAction.next,
      controller: mailToController,
      onFieldSubmitted: (value) => FocusScope.of(context).nextFocus(),
      validator: (value) {
        if (value.isEmpty) return S.validationRequired;
        return null;
      },
    );
  }
}

class MailListView extends StatefulWidget {
  const MailListView(
    this.mails, {
    Key key,
    this.sent = false,
  }) : super(key: key);

  final List<Mail> mails;
  final bool sent;

  @override
  _MailListViewState createState() => _MailListViewState();
}

class _MailListViewState extends State<MailListView> {
  List<Mail> mails;
  Set<int> readMails;

  @override
  void initState() {
    super.initState();
    mails = List<Mail>.from(widget.mails);
    readMails = widget.mails.where((e) => e.read).map((e) => e.id).toSet();
  }

  @override
  Widget build(BuildContext context) {
    if (mails == null || mails.isEmpty) {
      return Center(
        child: Text(S.noMail),
      );
    }

    return ListView.builder(
      primary: false,
      itemCount: mails.length,
      itemBuilder: (context, index) {
        var mail = mails[index];
        return Dismissible(
          key: Key('${mail.id}'),
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 8.0),
            child: Text(S.delete),
            color: Colors.red,
          ),
          onDismissed: (direction) {
            context.read<MailService>().delete(mail.id).then((_) {
              mails.remove(mail);
              setState(() {});
            }).catchError((e) => ErrorHandler.showError<Null>(context, e));
          },
          direction: DismissDirection.endToStart,
          child: ListTile(
            leading: Image.asset('assets/img/bank.png'),
            title: Text(widget.sent ? mail.to : mail.from),
            subtitle: Text(
              mail.content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: widget.sent || readMails.contains(mail.id)
                ? null
                : Icon(Icons.markunread),
            onTap: () {
              if (!widget.sent && !readMails.contains(mail.id)) {
                context.read<MailService>().read(mail.id).then((value) {
                  readMails.add(mail.id);
                  setState(() {});
                });
              }
              return Navigator.push(
                context,
                _MailDetailWidgetRoute(mail, widget.sent),
              );
            },
          ),
        );
      },
    );
  }
}

class MailDetailWidget extends StatelessWidget {
  final Mail mail;
  final bool sent;

  const MailDetailWidget(this.mail, this.sent, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mailContentList = mail.content
        .split(REPLY_SEPARATOR)
        .map((e) => _mailContentCard(e))
        .toList(growable: false);

    return Scaffold(
      appBar: AppBar(
        actions: sent
            ? null
            : [
                IconButton(
                  icon: Icon(Icons.report),
                  onPressed: () {
                    Widget cancelButton = FlatButton(
                      child: Text(S.cancel),
                      onPressed: () => Navigator.pop(context),
                    );
                    Widget continueButton = FlatButton(
                      child: Text(S.submit),
                      onPressed: () => context
                          .read<MailService>()
                          .report(mail.id)
                          .then((_) => Navigator.pop(context))
                          .catchError(
                              (e) => ErrorHandler.showError(context, e)),
                    );
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(S.reportMail),
                          content: Text(S.reportMailDetail),
                          actions: [
                            cancelButton,
                            continueButton,
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
        title: Text(sent ? mail.to : mail.from),
      ),
      body: SingleChildScrollView(
        primary: false,
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  DateFormat('y-MM-dd HH:mm:ss').format(mail.time),
                ),
              ),
            ),
            ...mailContentList,
            SendMailWidget(
              reply: sent ? mail.to : mail.from,
              mail: mail,
            ),
          ],
        ),
      ),
    );
  }

  Widget _mailContentCard(String content) {
    var split = content.split(FROM_SEPARATOR);
    String from;
    String message;

    if (split.length > 1) {
      from = split[0] + ': ';
      message = split[1];
    } else {
      message = split[0];
    }

    var text = new RichText(
      text: new TextSpan(
        children: <TextSpan>[
          new TextSpan(
            text: from,
            style: new TextStyle(fontWeight: FontWeight.bold),
          ),
          new TextSpan(text: message),
        ],
      ),
    );

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: text,
        ),
      ),
    );
  }
}

class MailPageRoute<T> extends MaterialPageRoute<T> {
  MailPageRoute() : super(builder: (BuildContext context) => new MailPage());
}

class _MailDetailWidgetRoute<T> extends MaterialPageRoute<T> {
  _MailDetailWidgetRoute(Mail mail, bool sent)
      : super(
            builder: (BuildContext context) =>
                new MailDetailWidget(mail, sent));
}

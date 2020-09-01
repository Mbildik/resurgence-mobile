import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/family/family.dart';
import 'package:resurgence/family/service.dart';
import 'package:resurgence/ui/error_handler.dart';
import 'package:resurgence/ui/shared.dart';

class _HumanResource extends StatefulWidget {
  const _HumanResource(
    this.family, {
    Key key,
  }) : super(key: key);

  final Family family;

  @override
  __HumanResourceState createState() => __HumanResourceState();
}

class __HumanResourceState extends State<_HumanResource> {
  @override
  Widget build(BuildContext context) {
    var members = widget.family.sortMembers();

    return Scaffold(
      appBar: W.defaultAppBar,
      body: ListView.separated(
        itemBuilder: (context, index) {
          var member = members[index];
          Widget trailing;
          Widget subtitle = RaisedButton(
            child: Text(S.fire),
            onPressed: () => onFire(context, member),
            color: Colors.red,
          );

          if (member == widget.family.boss) {
            trailing = Text(S.boss);
            subtitle = null;
          } else if (member == widget.family.consultant) {
            trailing = Text(S.consultant);
            subtitle = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RaisedButton(
                  child: Text(S.disqualify),
                  onPressed: () => onConsultantDisqualify(context, member),
                  color: Colors.amber,
                ),
                SizedBox(width: 8.0),
                subtitle
              ],
            );
          } else if (widget.family.chiefs.map((c) => c.name).contains(member)) {
            trailing = Text(S.chief);
            subtitle = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RaisedButton(
                  child: Text(S.disqualify),
                  onPressed: () => onChiefDisqualify(context, member),
                  color: Colors.amber,
                ),
                SizedBox(width: 8.0),
                subtitle
              ],
            );
          } else {
            subtitle = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RaisedButton(
                  child: Text(S.promoteToConsultant),
                  onPressed: () => onPromoteConsultant(context, member),
                  color: Colors.green,
                ),
                SizedBox(width: 8.0),
                RaisedButton(
                  child: Text(S.promoteToChief),
                  onPressed: () => onPromoteChief(context, member),
                  color: Colors.blue,
                ),
                SizedBox(width: 8.0),
                subtitle
              ],
            );
          }

          return ListTile(
            title: Text(member),
            subtitle: subtitle,
            trailing: trailing,
          );
        },
        separatorBuilder: (_, __) => const Divider(),
        itemCount: members.length,
      ),
    );
  }

  void onPromoteConsultant(BuildContext context, String member) {
    context.read<FamilyService>().makeConsultant(member).then((value) {
      widget.family.consultant = member;
      setState(() {}); // re-render
    }).catchError((e) => ErrorHandler.showError(context, e));
  }

  void onPromoteChief(BuildContext context, String member) {
    context.read<FamilyService>().makeChief(member).then((value) {
      widget.family.chiefs.add(Chief(name: member, members: []));
      setState(() {}); // re-render
    }).catchError((e) => ErrorHandler.showError(context, e));
  }

  void onFire(BuildContext context, String member) {
    showConfirmationDialog(
      context,
      S.memberDeleteTitle,
      S.memberDeleteContent,
      S.delete,
      S.cancel,
      () => context.read<FamilyService>().fire(member).then((value) {
        widget.family.members.remove(member);
        if (widget.family.consultant == member) {
          widget.family.consultant = null;
        } else if (widget.family.chiefs.map((c) => c.name).contains(member)) {
          widget.family.chiefs.removeWhere((c) => c.name == member);
        }
        setState(() {}); // re-render
      }).catchError((e) => ErrorHandler.showError(context, e)),
    );
  }

  void onConsultantDisqualify(BuildContext context, String member) {
    showConfirmationDialog(
      context,
      S.consultantDisqualifyTitle,
      S.consultantDisqualifyContent,
      S.disqualify,
      S.cancel,
      () => context.read<FamilyService>().fireConsultant().then((value) {
        widget.family.consultant = null;
        setState(() {}); // re-render
      }).catchError((e) => ErrorHandler.showError(context, e)),
    );
  }

  void onChiefDisqualify(BuildContext context, String member) {
    showConfirmationDialog(
      context,
      S.chiefDisqualifyTitle,
      S.chiefDisqualifyContent,
      S.disqualify,
      S.cancel,
      () => context.read<FamilyService>().fireChief(member).then((value) {
        widget.family.chiefs.removeWhere((c) => c.name == member);
        setState(() {}); // re-render
      }).catchError((e) => ErrorHandler.showError(context, e)),
    );
  }
}

class _Invitation extends StatefulWidget {
  const _Invitation(
    this.family, {
    Key key,
  }) : super(key: key);

  final Family family;

  @override
  __InvitationState createState() => __InvitationState();
}

class __InvitationState extends State<_Invitation> {
  Future<List<Invitation>> invitationsFuture;

  @override
  void initState() {
    super.initState();
    invitationsFuture = fetch();
  }

  Future<List<Invitation>> fetch() =>
      context.read<FamilyService>().invitations();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.applicationsInvitations),
      ),
      body: LoadingFutureBuilder<List<Invitation>>(
        future: invitationsFuture,
        onError: () => setState(() {
          invitationsFuture = fetch();
        }),
        builder: (context, snapshot) {
          var invitations = snapshot.data;

          return RefreshIndicator(
            onRefresh: () {
              var future = fetch();
              setState(() {
                invitationsFuture = future;
              });
              return future;
            },
            child: ListView.separated(
              itemBuilder: (context, index) {
                var invitation = invitations[index];

                return ListTile(
                  title: Text(invitation.player),
                  subtitle: Text(
                    DateFormat(S.dateFormat).format(invitation.time.toLocal()),
                  ),
                  trailing: _InvitationButton(
                    widget.family,
                    invitation,
                    onComplete: () => setState(() {
                      invitationsFuture = fetch();
                    }),
                  ),
                );
              },
              separatorBuilder: (_, __) => Divider(),
              itemCount: invitations.length,
            ),
          );
        },
      ),
    );
  }
}

class _InvitationButton extends StatelessWidget {
  const _InvitationButton(
    this.family,
    this.invitation, {
    Key key,
    this.onComplete,
  }) : super(key: key);

  final Family family;
  final Invitation invitation;
  final Function onComplete;

  @override
  Widget build(BuildContext context) {
    if (invitation.direction == Direction.family) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RaisedButton(
            child: Text(S.accept),
            color: Colors.green,
            onPressed: () {
              context
                  .read<FamilyService>()
                  .accept(invitation.id)
                  .then((_) {
                    family.members.add(invitation.player);
                  })
                  .then((_) => onComplete())
                  .catchError((e) => ErrorHandler.showError(context, e));
            },
          ),
          SizedBox(width: 4.0),
          RaisedButton(
            child: Text(S.revoke),
            color: Colors.red,
            onPressed: () {
              context
                  .read<FamilyService>()
                  .cancel(invitation.id)
                  .then((_) => onComplete())
                  .catchError((e) => ErrorHandler.showError(context, e));
            },
          ),
        ],
      );
    } else if (invitation.direction == Direction.player) {
      return RaisedButton(
        child: Text(S.revoke),
        onPressed: () {
          context
              .read<FamilyService>()
              .cancel(invitation.id)
              .then((_) => onComplete())
              .catchError((e) => ErrorHandler.showError(context, e));
        },
      );
    }
    return Container();
  }
}

class _ChiefManagement extends StatefulWidget {
  const _ChiefManagement(
    this.family, {
    Key key,
  }) : super(key: key);

  final Family family;

  @override
  __ChiefManagementState createState() => __ChiefManagementState();
}

class __ChiefManagementState extends State<_ChiefManagement> {
  @override
  Widget build(BuildContext context) {
    var family = widget.family;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: S.assign),
              Tab(text: S.discharge),
            ],
          ),
          title: Text(S.family),
        ),
        body: TabBarView(
          children: [
            _AssignToChiefWidget(family),
            _DischargeFromChiefWidget(family),
          ],
        ),
      ),
    );
  }
}

class _AssignToChiefWidget extends StatefulWidget {
  const _AssignToChiefWidget(
    this.family, {
    Key key,
  }) : super(key: key);

  final Family family;

  @override
  __AssignToChiefWidgetState createState() => __AssignToChiefWidgetState();
}

class __AssignToChiefWidgetState extends State<_AssignToChiefWidget> {
  @override
  Widget build(BuildContext context) {
    var family = widget.family;
    var members = family.sortMembers();

    members.removeWhere((m) => m == family.boss);
    members.removeWhere((m) => m == family.consultant);
    members.removeWhere((m) => family.chiefs.map((c) => c.name).contains(m));
    members
        .removeWhere((m) => family.chiefs.expand((c) => c.members).contains(m));

    if (members.isEmpty) {
      return EmptyDataWidget.noData();
    }

    return ListView.builder(
      itemBuilder: (context, index) {
        var member = members[index];
        return ListTile(
          title: Text(member),
          trailing: RaisedButton(
            child: Text(S.assign),
            onPressed: () {
              SimpleDialog dialog = SimpleDialog(
                title: Text(S.assignChiefDialogTitle),
                children: family.chiefs
                    .map((c) => c.name)
                    .map((chief) => SimpleDialogOption(
                          child: Text(chief),
                          onPressed: () {
                            var service = context.read<FamilyService>();
                            service.assign(chief, member).then((_) {
                              family.chiefs
                                  .firstWhere((c) => c.name == chief)
                                  .members
                                  .add(member);
                              setState(() {});
                              Navigator.pop(context);
                            }).catchError(
                                (e) => ErrorHandler.showError(context, e));
                          },
                        ))
                    .toList(growable: false),
              );

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return dialog;
                },
              );
            },
          ),
        );
      },
      itemCount: members.length,
    );
  }
}

class _DischargeFromChiefWidget extends StatefulWidget {
  const _DischargeFromChiefWidget(
    this.family, {
    Key key,
  }) : super(key: key);

  final Family family;

  @override
  __DischargeFromChiefWidgetState createState() =>
      __DischargeFromChiefWidgetState();
}

class __DischargeFromChiefWidgetState extends State<_DischargeFromChiefWidget> {
  @override
  Widget build(BuildContext context) {
    var family = widget.family;
    var members = family.chiefs.expand((e) => e.members).toList();

    if (members.isEmpty) {
      return EmptyDataWidget.noData();
    }

    return ListView.builder(
      itemBuilder: (context, index) {
        var member = members[index];
        var chief =
            family.chiefs.firstWhere((c) => c.members.contains(member)).name;
        return ListTile(
          title: Text(member),
          subtitle: Text(chief),
          trailing: RaisedButton(
            child: Text(S.discharge),
            color: Colors.red,
            onPressed: () {
              showConfirmationDialog(
                context,
                S.memberDischargeConfirmationTitle,
                S.memberDischargeConfirmationContent(member, chief),
                S.accept,
                S.cancel,
                () {
                  var service = context.read<FamilyService>();
                  return service.discharge(chief, member).then((_) {
                    family.chiefs
                        .firstWhere((c) => c.name == chief)
                        .members
                        .remove(member);
                    setState(() {});
                    Navigator.pop(context, true);
                  }).catchError((e) => ErrorHandler.showError(context, e));
                },
              );
            },
          ),
        );
      },
      itemCount: members.length,
    );
  }
}

class _AnnouncementManagement extends StatefulWidget {
  @override
  __AnnouncementManagementState createState() =>
      __AnnouncementManagementState();
}

class __AnnouncementManagementState extends State<_AnnouncementManagement> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  bool _secret = false;
  int _id;
  Future<List<Announcement>> _announcementsFuture;

  @override
  void initState() {
    super.initState();
    _announcementsFuture = fetch();
  }

  Future<List<Announcement>> fetch() =>
      context.read<FamilyService>().announcement();

  @override
  Widget build(BuildContext context) {
    Widget footer = OutlineButton(
      child: Text(S.submit),
      onPressed: () {
        if (!_formKey.currentState.validate()) return; // form is not valid
        FocusScope.of(context).unfocus();

        var service = context.read<FamilyService>();
        service
            .saveAnnouncement(
              _titleController.text,
              _contentController.text,
              _secret,
            )
            .then(
              (_) => setState(() {
                _reset();
                _announcementsFuture = fetch();
              }),
            )
            .catchError((e) => ErrorHandler.showError(context, e));
      },
    );

    if (_id != null) {
      footer = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RaisedButton(
            child: Text(S.edit),
            onPressed: () {
              if (!_formKey.currentState.validate())
                return; // form is not valid
              FocusScope.of(context).unfocus();

              var service = context.read<FamilyService>();
              service
                  .editAnnouncement(
                _id,
                _titleController.text,
                _contentController.text,
                _secret,
              )
                  .then(
                (_) {
                  _reset();
                  setState(() {
                    _announcementsFuture = fetch();
                  });
                },
              ).catchError((e) => ErrorHandler.showError(context, e));
            },
          ),
          SizedBox(width: 8.0),
          RaisedButton(
            child: Text(S.clear),
            color: Colors.amber,
            onPressed: _reset,
          ),
          SizedBox(width: 8.0),
          RaisedButton(
            child: Text(S.delete),
            color: Colors.red,
            onPressed: () {
              FocusScope.of(context).unfocus();

              showConfirmationDialog(
                context,
                S.announcementDeleteConfirmationTitle,
                S.announcementDeleteConfirmationContent,
                S.accept,
                S.cancel,
                () {
                  var service = context.read<FamilyService>();
                  return service
                      .deleteAnnouncement(_id)
                      .then((_) => setState(() {
                            _reset();
                            _announcementsFuture = fetch();
                            Navigator.pop(context, true);
                          }))
                      .catchError((e) => ErrorHandler.showError(context, e));
                },
              );
            },
          ),
        ],
      );
    }

    return Scaffold(
      appBar: W.defaultAppBar,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(labelText: S.titleHintText),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                        controller: _titleController,
                        onFieldSubmitted: (value) =>
                            FocusScope.of(context).nextFocus(),
                        validator: (value) {
                          if (value.isEmpty) return S.validationRequired;
                          return null;
                        },
                      ),
                      SizedBox(height: 8.0),
                      TextFormField(
                        decoration:
                            InputDecoration(hintText: S.contentHintText),
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: 5,
                        controller: _contentController,
                        onFieldSubmitted: (value) =>
                            FocusScope.of(context).nextFocus(),
                        validator: (value) {
                          if (value.isEmpty) return S.validationRequired;
                          return null;
                        },
                      ),
                      SizedBox(height: 8.0),
                      CheckboxListTile(
                        title: Text(S.secret),
                        subtitle: Text(S.announcementSecretInfo),
                        contentPadding: EdgeInsets.zero,
                        value: _secret,
                        onChanged: (value) => setState(() => _secret = value),
                      ),
                      SizedBox(height: 8.0),
                      footer,
                    ],
                  ),
                ),
              ),
              LoadingFutureBuilder<List<Announcement>>(
                future: _announcementsFuture,
                onError: () => setState(() {
                  _announcementsFuture = fetch();
                }),
                builder: (context, snapshot) {
                  var announcements = snapshot.data;

                  return ListView.separated(
                    shrinkWrap: true,
                    primary: false,
                    itemCount: announcements.length,
                    separatorBuilder: (_, __) => Divider(),
                    itemBuilder: (context, index) {
                      var announcement = announcements[index];

                      Widget title = Text(announcement.title);
                      if (announcement.secret) {
                        var textStyle = Theme.of(context)
                            .textTheme
                            .bodyText1
                            .copyWith(fontWeight: FontWeight.bold);
                        title = Row(
                          children: [
                            title,
                            SizedBox(width: 8.0),
                            Chip(
                              label: Text(S.secret, style: textStyle),
                              backgroundColor: Colors.red,
                            )
                          ],
                        );
                      }

                      return ListTile(
                        title: title,
                        subtitle: Text(announcement.content),
                        onTap: () {
                          _titleController.text = announcement.title;
                          _contentController.text = announcement.content;
                          setState(() {
                            _id = announcement.id;
                            _secret = announcement.secret;
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _reset() {
    _titleController.clear();
    _contentController.clear();
    setState(() {
      _id = null;
      _secret = false;
    });
  }
}

class HumanResourceRoute<T> extends MaterialPageRoute<T> {
  final Family family;

  HumanResourceRoute(this.family)
      : super(builder: (BuildContext context) => _HumanResource(family));
}

class InvitationRoute<T> extends MaterialPageRoute<T> {
  final Family family;

  InvitationRoute(this.family)
      : super(builder: (BuildContext context) => _Invitation(family));
}

class ChiefManagementRoute<T> extends MaterialPageRoute<T> {
  final Family family;

  ChiefManagementRoute(this.family)
      : super(builder: (BuildContext context) => _ChiefManagement(family));
}

class AnnouncementRoute<T> extends MaterialPageRoute<T> {
  AnnouncementRoute()
      : super(builder: (BuildContext context) => _AnnouncementManagement());
}

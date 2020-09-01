import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/family/family.dart';
import 'package:resurgence/family/service.dart';
import 'package:resurgence/family/state.dart';
import 'package:resurgence/ui/error_handler.dart';
import 'package:resurgence/ui/shared.dart';

typedef OnInvitationButtonPress = Function(bool accepted);

class _Invitation extends StatefulWidget {
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
                    invitation,
                    onComplete: (accepted) {
                      if (accepted) {
                        var service = context.read<FamilyService>();
                        service.info().then((family) {
                          context.read<FamilyState>().family = family;
                          return Navigator.pushReplacement(
                              context, FamilyDetailRoute(family));
                        });
                      } else {
                        setState(() {
                          invitationsFuture = fetch();
                        });
                      }
                    },
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
    this.invitation, {
    Key key,
    this.onComplete,
  }) : super(key: key);

  final Invitation invitation;
  final OnInvitationButtonPress onComplete;

  @override
  Widget build(BuildContext context) {
    if (invitation.direction == Direction.player) {
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
                  .then((_) => onComplete(true))
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
                  .then((_) => onComplete(false))
                  .catchError((e) => ErrorHandler.showError(context, e));
            },
          ),
        ],
      );
    } else if (invitation.direction == Direction.family) {
      return RaisedButton(
        child: Text(S.revoke),
        onPressed: () {
          context
              .read<FamilyService>()
              .cancel(invitation.id)
              .then((_) => onComplete(false))
              .catchError((e) => ErrorHandler.showError(context, e));
        },
      );
    }
    return Container();
  }
}

class PlayerInvitationRoute<T> extends MaterialPageRoute<T> {
  PlayerInvitationRoute()
      : super(
            builder: (BuildContext context) =>
                FamilyController(child: _Invitation()));
}

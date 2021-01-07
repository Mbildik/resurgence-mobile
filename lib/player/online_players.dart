import 'package:duration/duration.dart';
import 'package:duration/locale.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/chat/chat.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/player/profile.dart';

class OnlinePlayers extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aktif Kullanıcılar'),
      ),
      body: Selector<ChatState, List<Presence>>(
        selector: (_, s) => s.presences,
        builder: (context, userStats, child) {
          return ListView.separated(
            itemCount: userStats.length,
            itemBuilder: (context, index) {
              var userStat = userStats.elementAt(index);
              return _ListItem(userStat: userStat);
            },
            separatorBuilder: (_, __) => Divider(height: 0),
          );
        },
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  const _ListItem({
    Key key,
    @required this.userStat,
  }) : super(key: key);

  final Presence userStat;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.network(S.playerImage(userStat.name)),
      title: Text(
        userStat.name,
        maxLines: 2,
        overflow: TextOverflow.fade,
      ),
      subtitle: Row(
        children: [
          Container(
            width: 16.0,
            height: 16.0,
            decoration: BoxDecoration(
              color: userStat.online ? Colors.green[700] : Colors.red[700],
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          SizedBox(width: 4.0),
          Flexible(
            child: Text(
              prettyDuration(
                userStat.duration,
                locale: TurkishDurationLocale(),
              ),
            ),
          ),
        ],
      ),
      trailing: Icon(Icons.chevron_right),
      onTap: () => Navigator.pushNamed(
        context,
        Routes.USER_PROFILE,
        arguments: PlayerProfileRouteArguments(userStat.name),
      ),
    );
  }
}

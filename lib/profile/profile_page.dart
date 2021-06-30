import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/chat/chat.dart';
import 'package:resurgence/chat/client.dart';
import 'package:resurgence/chat/model.dart';
import 'package:resurgence/chat/state.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/money.dart';
import 'package:resurgence/player/player.dart';
import 'package:resurgence/player/service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class ProfilePage extends StatelessWidget {
  final Player player;

  const ProfilePage({
    Key key,
    @required this.player,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 4.0),
      child: Column(
        children: [
          Row(
            children: [
              // image
              ProfileImage(),
              SizedBox(width: 16.0),
              // info
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            player.balance != null
                                ? InfoContentText(Money.format(player.balance))
                                : InfoContentText(player.wealth.value),
                            SizedBox(height: 2.0),
                            InfoTitleText(S.money),
                          ],
                        ),
                        Container(
                          width: 1,
                          height: 48,
                          color: Colors.grey,
                        ),
                        Column(
                          children: [
                            InfoContentText(player.honor.toString()),
                            SizedBox(height: 2.0),
                            InfoTitleText(S.honor),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: _PlayerOnlineInfo(player: player),
          ),
        ],
      ),
    );
  }
}

class _PlayerOnlineInfo extends StatelessWidget {
  const _PlayerOnlineInfo({
    Key key,
    @required this.player,
  }) : super(key: key);

  final Player player;

  @override
  Widget build(BuildContext context) {
    if (player.nickname == PlayerState.playerName) return Container();

    return Selector<ChatState, List<Presence>>(
      selector: (_, state) => state.presences,
      builder: (_, presences, __) {
        var presence = presences.singleWhere((p) => p.name == player.nickname,
            orElse: () => null);

        if (presence == null) return Container();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 16.0,
                  height: 16.0,
                  decoration: BoxDecoration(
                    color:
                        presence.online ? Colors.green[700] : Colors.red[700],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                SizedBox(width: 4.0),
                InfoTitleText(presence.online ? 'Çevrimiçi' : 'Çevrimdışı'),
              ],
            ),
            OutlineButton.icon(
              // padding: EdgeInsets.zero,
              onPressed: () {
                var chatClient = context.read<Client>();

                chatClient.searchAndSubscribe(player.nickname).then((subs) {
                  Navigator.push(context, MessageRoute(subs));
                }).catchError((e) {
                  Sentry.captureException(e,
                      hint: 'An error occur while searc and subscribe a topic');
                  log(
                    'An error occur while searc and subscribe a topic',
                    error: e,
                  );
                });
              },
              icon: Icon(Icons.messenger_outline),
              label: Text(S.sendMessage),
            )
          ],
        );
      },
    );
  }
}

class InfoRow extends StatelessWidget {
  final List<Widget> children;

  const InfoRow({
    Key key,
    @required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children,
    );
  }
}

class InfoTitleText extends StatelessWidget {
  final String text;

  const InfoTitleText(
    this.text, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyText1.copyWith(color: Colors.grey),
    );
  }
}

class InfoContentText extends StatelessWidget {
  final String text;

  const InfoContentText(
    this.text, {
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headline6,
    );
  }
}

class ProfileImage extends StatelessWidget {
  final _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        var pickedFile = await _picker.getImage(source: ImageSource.gallery);
        if (pickedFile == null || pickedFile.path == null) {
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Resim seçmediğin için herhangi bir güncelleme yapılmadı.'),
            ),
          );
          return;
        }
        var file = File(pickedFile.path);
        context
            .read<PlayerService>()
            .editImage(file)
            .then(context.read<PlayerState>().updatePlayer);
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18.0),
            child: Consumer<PlayerState>(
              builder: (context, state, child) {
                return Image.network(
                  S.baseUrl + 'player/image/${state.player.nickname}',
                  height: 128,
                  width: 128,
                );
              },
            ),
          ),
          Positioned(
            bottom: 6.0,
            right: 6.0,
            child: Icon(Icons.add_circle),
          ),
        ],
      ),
    );
  }
}

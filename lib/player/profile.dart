import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/multiplayer-task/data.dart';
import 'package:resurgence/multiplayer-task/service.dart';
import 'package:resurgence/multiplayer-task/state.dart';
import 'package:resurgence/player/player.dart';
import 'package:resurgence/player/service.dart';
import 'package:resurgence/profile/profile_page.dart';
import 'package:resurgence/ui/shared.dart';

class PlayerProfile extends StatefulWidget {
  final String player;

  const PlayerProfile(
    this.player, {
    Key key,
  }) : super(key: key);

  @override
  _PlayerProfileState createState() {
    return _PlayerProfileState();
  }
}

class _PlayerProfileState extends State<PlayerProfile> {
  Future<Player> _playerFuture;
  PlayerService _playerService;
  MultiplayerService _multiplayerService;
  Future<List<MultiplayerTaskPlayerInfo>> _tasks;

  @override
  void initState() {
    super.initState();

    this._playerService = context.read<PlayerService>();
    this._playerFuture = _fetch();

    this._multiplayerService = context.read<MultiplayerService>();
    this._tasks = this._multiplayerService.playerInfo(widget.player);
  }

  @override
  Widget build(BuildContext context) {
    bool isCurrentPlayer = widget.player == PlayerState.playerName;

    return Scaffold(
      appBar: AppBar(
        title: Text('Oyuncu Profili'),
      ),
      body: Center(
        child: LoadingFutureBuilder<Player>(
          onError: () => setState(() {
            this._playerFuture = this._fetch();
          }),
          future: this._playerFuture,
          builder: (context, snapshot) {
            return Column(
              children: [
                ProfilePage(player: snapshot.data),
                if (!isCurrentPlayer)
                  LoadingFutureBuilder<List<MultiplayerTaskPlayerInfo>>(
                    future: this._tasks,
                    onError: () => setState(() {
                      this._tasks =
                          this._multiplayerService.playerInfo(widget.player);
                    }),
                    builder: (context, snapshot) {
                      return Flexible(
                        child: GridView.count(
                          crossAxisCount: 2,
                          padding: EdgeInsets.all(16.0),
                          childAspectRatio: 2.0,
                          children: snapshot.data.map((e) {
                            return _MultiplayerInfo(
                              task: e.task.value,
                              image: e.image,
                              canPerform: e.perform,
                              playerName: widget.player,
                            );
                          }).toList(growable: false),
                        ),
                      );
                    },
                  )
              ],
            );
          },
        ),
      ),
    );
  }

  Future<Player> _fetch() => _playerService.info(player: widget.player);
}

class _MultiplayerInfo extends StatelessWidget {
  const _MultiplayerInfo({
    Key key,
    @required this.task,
    @required this.playerName,
    @required this.canPerform,
    @required this.image,
  }) : super(key: key);

  final String task;
  final String playerName;
  final bool canPerform;
  final String image;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: canPerform
          ? () {
              Navigator.pushNamed(context, Routes.MULTIPLAYER_TASKS);
              Clipboard.setData(new ClipboardData(text: playerName));
              MultiplayerClipboardState.isPlayerNameCopied = true;
              toast('Oyuncu ismi koplayandı.', duration: Duration(seconds: 1));
            }
          : null,
      child: Card(
        color: Colors.grey[canPerform ? 800 : 900],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Image.network(image, width: 72.0),
            SizedBox(width: 8.0),
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task, style: Theme.of(context).textTheme.headline6),
                  Text(
                    canPerform ? 'Yapabilir' : 'Yorgun',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlayerProfileRouteArguments {
  final String player;

  PlayerProfileRouteArguments(this.player);

  @override
  String toString() {
    return 'PlayerProfileRouteArguments{player: $player}';
  }
}

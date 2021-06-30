import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/authentication/state.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/family/family.dart';
import 'package:resurgence/navigation.dart';
import 'package:resurgence/player/player.dart';
import 'package:resurgence/player/player_creation_page.dart';
import 'package:resurgence/player/service.dart';
import 'package:resurgence/ui/button.dart';
import 'package:resurgence/ui/shared.dart';

class PlayerControlPage extends StatefulWidget {
  @override
  _PlayerControlPageState createState() => _PlayerControlPageState();
}

class _PlayerControlPageState extends State<PlayerControlPage> {
  Future<Player> futurePlayer;

  @override
  void initState() {
    super.initState();
    futurePlayer = fetchPlayer();
  }

  Future<Player> fetchPlayer() => context
      .read<PlayerService>()
      .info()
      .then((player) => onPlayerInfoSucceed(player))
      .catchError((e) => onPlayerInfoError(e));

  Player onPlayerInfoSucceed(Player player) {
    context.read<PlayerState>().updatePlayer(player);
    return player;
  }

  void onPlayerInfoError(e) {
    if (e is DioError &&
        e.type == DioErrorType.response &&
        e.response.statusCode == 404) {
      throw PlayerNotCreatedError();
    }
    // todo maybe dead player comes here to re-create new player
    throw e;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Player>(
      future: futurePlayer,
      builder: (BuildContext context, AsyncSnapshot<Player> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: const LoadingWidget());
        } else if (snapshot.hasError) {
          if (snapshot.error is PlayerNotCreatedError) {
            return PlayerCreationPage(
              onDone: () => setState(() {
                futurePlayer = fetchPlayer();
              }),
            );
          }
          return Scaffold(
            appBar: W.defaultAppBar,
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                RefreshOnErrorWidget(
                  onPressed: () => setState(() {
                    futurePlayer = fetchPlayer();
                  }),
                ),
                Button(
                  child: Text(S.logout),
                  onPressed: () => context.read<AuthenticationState>().logout(),
                ),
              ],
            ),
          );
        }
        return FamilyController(child: MainNavigation());
      },
    );
  }
}

class PlayerNotCreatedError extends Error {}

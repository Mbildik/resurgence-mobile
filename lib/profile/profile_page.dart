import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/authentication/service.dart';
import 'package:resurgence/authentication/state.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/money.dart';
import 'package:resurgence/player/player.dart';
import 'package:resurgence/player/service.dart';
import 'package:resurgence/ui/shared.dart';

class ProfilePage extends StatelessWidget {
  final Player player;

  const ProfilePage({
    Key key,
    @required this.player,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.profile),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // image
                ProfileImage(),
                SizedBox(width: 16.0),
                // info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.nickname,
                        style: Theme.of(context).textTheme.headline6,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      InfoTitleText(player.title.value),
                      InfoTitleText(player.race.value),
                    ],
                  ),
                ),
              ],
            ),
            Card(
              margin: EdgeInsets.only(top: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    InfoRow(
                      children: [
                        InfoTitleText(S.money),
                        InfoContentText(Money.format(player.balance)),
                      ],
                    ),
                    if (player.family != null) Divider(),
                    if (player.family != null)
                      InfoRow(
                        children: [
                          InfoTitleText(S.family),
                          InfoContentText(player.family),
                        ],
                      ),
                    Divider(),
                    InfoRow(
                      children: [
                        InfoTitleText(S.health),
                        InfoContentText(player.health.toString()),
                      ],
                    ),
                    Divider(),
                    InfoRow(
                      children: [
                        InfoTitleText(S.honor),
                        InfoContentText(player.honor.toString()),
                      ],
                    ),
                    Divider(),
                    InfoRow(
                      children: [
                        InfoTitleText(S.usableHonor),
                        InfoContentText(player.usableHonor.toString()),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(child: Container()),
            Row(
              children: [
                RaisedButton(
                  child: Text(S.logout),
                  color: Colors.red[700],
                  onPressed: () {
                    showConfirmationDialog(
                      context,
                      S.logoutConfirmationTitle,
                      S.logoutConfirmationContent,
                      S.logout,
                      S.cancel,
                      () {
                        context.read<AuthenticationState>().logout();
                        context.read<AuthenticationService>().logout();
                        Navigator.pop(context);
                        return Future.value();
                      },
                    );
                  },
                ),
              ],
            )
          ],
        ),
      ),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.0),
        child: Consumer<PlayerState>(
          builder: (context, state, child) {
            return Image.network(
              state.player.image ?? S.baseUrl + 'static/player/default_image.png',
              height: 128,
              width: 128,
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }
}

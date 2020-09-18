import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/authentication/state.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/money.dart';
import 'package:resurgence/player/player.dart';
import 'package:resurgence/ui/button.dart';

class ProfilePage extends StatelessWidget {
  Widget build(BuildContext context) {
    var player = context.watch<PlayerState>().player;
    return Scaffold(
      appBar: W.defaultAppBar,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: <Widget>[
              margin(16),
              Image.network(
                'https://picsum.photos/150',
              ),
              margin(16),
              Text(
                player.nickname,
                style: Theme.of(context).textTheme.headline4,
              ),
              Text(
                player.title.value,
                style: Theme.of(context).textTheme.headline6,
              ),
              margin(16),
              Table(
                border: TableBorder.all(
                  color: Colors.white,
                ),
                defaultVerticalAlignment: TableCellVerticalAlignment.bottom,
                children: [
                  keyValueTableRow(context, S.race, player.race.value),
                  keyValueTableRow(context, S.balance, Money.format(player.balance)),
                  keyValueTableRow(context, S.health, player.health),
                  keyValueTableRow(context, S.honor, player.honor),
                  keyValueTableRow(context, S.experience, player.experience),
                ],
              ),
              Button(
                onPressed: () => context.read<AuthenticationState>().logout(),
                child: Text(S.logout),
              )
            ],
          ),
        ),
      ),
    );
  }

  TableRow keyValueTableRow(BuildContext context, key, value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: keyCell(context, key),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: valueCell(context, value),
        ),
      ],
    );
  }

  Widget keyCell(BuildContext context, value) {
    return Text(
      value.toString(),
      style: Theme.of(context).textTheme.headline6,
    );
  }

  Widget valueCell(BuildContext context, value) {
    return Text(
      value.toString(),
      style: Theme.of(context).textTheme.bodyText2,
    );
  }

  Widget margin(double vertical) {
    return Container(margin: EdgeInsets.symmetric(vertical: vertical));
  }
}

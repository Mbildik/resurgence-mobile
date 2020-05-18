import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/authentication/state.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/enum.dart';
import 'package:resurgence/player/service.dart';
import 'package:resurgence/ui/button.dart';
import 'package:resurgence/ui/error_handler.dart';

class PlayerCreationPage extends StatefulWidget {
  @override
  _PlayerCreationPageState createState() => _PlayerCreationPageState();
}

class _PlayerCreationPageState extends State<PlayerCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final nicknameController = TextEditingController(text: 'Shelby');

  AbstractEnum race;
  Future<List<AbstractEnum>> futureRaces;

  @override
  void initState() {
    super.initState();
    futureRaces = fetchRaces();
  }

  Future<List<AbstractEnum>> fetchRaces() =>
      context.read<PlayerService>().races();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: W.defaultAppBar,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  margin(48),
                  Text(
                    S.playerCreationTitle,
                    style: Theme.of(context).primaryTextTheme.headline6,
                  ),
                  margin(48),
                  raceDropdown(),
                  margin(16),
                  nicknameFormField(),
                  margin(16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      createPlayerButton(),
                      logoutButton(),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget nicknameFormField() {
    return TextFormField(
      decoration: InputDecoration(labelText: S.nickname),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      controller: nicknameController,
      onFieldSubmitted: (value) => FocusScope.of(context).nextFocus(),
      validator: (value) {
        if (value.isEmpty) return S.validationRequired;
        return null;
      },
    );
  }

  Widget raceDropdown() {
    return FutureBuilder<List<AbstractEnum>>(
      future: futureRaces,
      builder: (context, snapshot) {
        // todo investigate ConnectionState.active
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return onDropdownValueFetchError();
        }
        var races = snapshot.data;

        return DropdownButtonFormField<AbstractEnum>(
          value: race,
          hint: Text(S.race),
          validator: (value) {
            if (value == null) return S.validationRequired;
            return null;
          },
          onChanged: (AbstractEnum newValue) {
            setState(() {
              race = newValue;
            });
          },
          items: races.map<DropdownMenuItem<AbstractEnum>>((race) {
            return DropdownMenuItem<AbstractEnum>(
              value: race,
              child: Text(race.value),
            );
          }).toList(growable: false),
        );
      },
    );
  }

  Widget onDropdownValueFetchError() {
    return Column(
      children: [
        Text(S.errorOccurred),
        Button(
          onPressed: () => setState(() {
            futureRaces = fetchRaces();
          }),
          child: Text(S.reload),
        )
      ],
    );
  }

  Widget createPlayerButton() {
    return Button(
      onPressed: () {
        if (!_formKey.currentState.validate()) return; // form is not valid

        var nickname = nicknameController.text;
        context
            .read<PlayerService>()
            .create(nickname, race)
            .then((player) => Navigator.pop(context))
            .catchError((e) => ErrorHandler.showError(context, e));
      },
      child: Text(S.create),
    );
  }

  Widget logoutButton() {
    return Button(
      onPressed: () {
        context.read<AuthenticationState>().logout();
        Navigator.pop(context);
      },
      child: Text(S.logout),
    );
  }

  Widget margin(double vertical) {
    return Container(margin: EdgeInsets.symmetric(vertical: vertical));
  }
}

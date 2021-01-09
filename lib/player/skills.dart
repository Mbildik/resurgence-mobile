import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/enum.dart';
import 'package:resurgence/player/service.dart';
import 'package:resurgence/ui/shared.dart';

class Skills extends StatefulWidget {
  @override
  _SkillsState createState() => _SkillsState();
}

class _SkillsState extends State<Skills> {
  Future<List<Skill>> _skills;
  PlayerService _playerService;

  @override
  void initState() {
    super.initState();
    this._playerService = context.read<PlayerService>();
    this._skills = this._playerService.skills();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beceriler'),
        actions: [
          Tooltip(
            message: S.help,
            child: IconButton(
              icon: Icon(Icons.info),
              onPressed: () {
                showHelpDialog(
                  context: context,
                  // todo improve help
                  title: 'Beceriler',
                  content: 'Ekranda tüm becerileri görebilirsin.\n'
                      'Senin sahip olduğun becerilerin '
                      'içerisinde değer yazar ve daha '
                      'açık bir tonda gözükür.',
                );
              },
            ),
          ),
        ],
      ),
      body: LoadingFutureBuilder<List<Skill>>(
        future: this._skills,
        onError: () => setState(() {
          this._skills = this._playerService.skills();
        }),
        builder: (context, snapshot) {
          var skills = snapshot.data;

          var children =
              skills.map((e) => _SkillInfo(e)).toList(growable: false);

          return GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
            children: children,
          );
        },
      ),
    );
  }
}

class _SkillInfo extends StatelessWidget {
  const _SkillInfo(
    this.skill, {
    Key key,
  }) : super(key: key);

  final Skill skill;

  @override
  Widget build(BuildContext context) {
    const skillColor = const Color(0xFFC8786A);
    // const skillColor = const Color(0xFF5F9DBF);
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.grey, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FittedBox(
              child: Text(
                skill.value,
                style: Theme.of(context).textTheme.headline5.copyWith(
                      fontWeight: FontWeight.bold,
                      color: skillColor,
                    ),
              ),
            ),
            Text(
              skill.description,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  .copyWith(color: Colors.grey),
            ),
            // if (enabled)
            RichText(
              text: TextSpan(
                text: skill.expertise.toString(),
                style: Theme.of(context).textTheme.bodyText1.copyWith(
                      color: skillColor,
                      fontWeight: FontWeight.bold,
                    ),
                children: [
                  TextSpan(
                    text: ' / ',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: Colors.grey),
                  ),
                  TextSpan(
                    text: '100',
                    style: Theme.of(context)
                        .textTheme
                        .bodyText1
                        .copyWith(color: Colors.grey),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Skill extends AbstractEnum {
  final String description;
  final double expertise;

  Skill(this.description, this.expertise, key, value)
      : super(key: key, value: value);

  factory Skill.fromJson(Map<String, dynamic> json) {
    var aEnum = AbstractEnum.fromJson(json);
    return Skill(
      json['description'],
      json['expertise'],
      aEnum.key,
      aEnum.value,
    );
  }
}

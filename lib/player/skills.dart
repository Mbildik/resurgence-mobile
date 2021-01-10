import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    return LoadingFutureBuilder<List<Skill>>(
      future: this._skills,
      onError: () => setState(() {
        this._skills = this._playerService.skills();
      }),
      builder: (context, snapshot) {
        var skills = snapshot.data;

        var children = skills.map((e) => _SkillInfo(e)).toList(growable: false);

        return GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.4,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          children: children,
        );
      },
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
    const skillColor = Colors.white;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Icon(Icons.shield),
            FittedBox(
              child: Text(
                skill.value,
                style: Theme.of(context).textTheme.headline6.copyWith(
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

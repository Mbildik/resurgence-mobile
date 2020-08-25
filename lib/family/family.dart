import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/enum.dart';
import 'package:resurgence/family/service.dart';
import 'package:resurgence/player/player.dart';
import 'package:resurgence/ui/shared.dart';

class Family {
  String name;
  String image;
  String boss;
  String consultant;
  Building building;
  List<String> members;
  AbstractEnum race;
  List<Chief> chiefs;
  int bank;

  Family({
    this.name,
    this.image,
    this.boss,
    this.consultant,
    this.building,
    this.members,
    this.race,
    this.chiefs,
    this.bank,
  });

  Family.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    image = json['image'];
    boss = json['boss'];
    consultant = json['consultant'];
    building =
        json['building'] != null ? Building.fromJson(json['building']) : null;
    members = json['members'].cast<String>();
    race = json['race'] != null ? AbstractEnum.fromJson(json['race']) : null;
    if (json['chiefs'] != null) {
      chiefs = List<Chief>();
      json['chiefs'].forEach((v) {
        chiefs.add(Chief.fromJson(v));
      });
    }
    bank = json['bank'];
  }

  String available() {
    return '${members.length} / ${building.size}';
  }
}

class Chief {
  String name;
  List<String> members;

  Chief({this.name, this.members});

  Chief.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    members = json['members'].cast<String>();
  }
}

class Building extends AbstractEnum {
  int size;
  int price;

  Building({String key, String value, this.size, this.price})
      : super(key: key, value: value);

  Building.fromJson(Map<String, dynamic> json) {
    var abstractEnum = AbstractEnum.fromJson(json);
    key = abstractEnum.key;
    value = abstractEnum.value;
    size = json['size'];
    price = json['price'];
  }
}

class Announcement {
  Announcement({
    this.id,
    this.title,
    this.content,
    this.secret,
    this.time,
  });

  final int id;
  final String title;
  final String content;
  final bool secret;
  final DateTime time;

  factory Announcement.fromJson(Map<String, dynamic> json) => Announcement(
        id: json["id"] == null ? null : json["id"],
        title: json["title"] == null ? null : json["title"],
        content: json["content"] == null ? null : json["content"],
        secret: json["secret"] == null ? null : json["secret"],
        time: json["time"] == null ? null : DateTime.parse(json["time"]),
      );
}

class FamilyPage extends StatefulWidget {
  @override
  _FamilyPageState createState() => _FamilyPageState();
}

class _FamilyPageState extends State<FamilyPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: 'Families'),
              Tab(text: 'Invitations'),
              Tab(text: 'Applications'),
            ],
          ),
          title: Text(S.family),
        ),
        body: TabBarView(
          children: [
            _Families(),
            Icon(Icons.directions_transit),
            Icon(Icons.directions_bike),
          ],
        ),
      ),
    );
  }
}

class _Families extends StatefulWidget {
  @override
  __FamiliesState createState() => __FamiliesState();
}

class __FamiliesState extends State<_Families> {
  Future<List<Family>> familiesFuture;

  @override
  void initState() {
    super.initState();
    familiesFuture = fetchFamilies();
  }

  Future<List<Family>> fetchFamilies() =>
      context.read<FamilyService>().allFamily();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Family>>(
      future: familiesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingWidget();
        } else if (snapshot.hasError) {
          return RefreshOnErrorWidget(onPressed: () {
            setState(() {
              familiesFuture = fetchFamilies();
            });
          });
        }

        var families = snapshot.data;

        return RefreshIndicator(
          onRefresh: () {
            var families = fetchFamilies();
            setState(() {
              familiesFuture = families;
            });
            return families;
          },
          child: ListView.builder(
            itemCount: families.length,
            itemBuilder: (context, index) {
              var family = families[index];
              return _FamilyListTile(family: family);
            },
          ),
        );
      },
    );
  }
}

class _FamilyListTile extends StatelessWidget {
  const _FamilyListTile({Key key, this.family}) : super(key: key);

  final Family family;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Hero(
        tag: family.name,
        child: Image.network(family.image),
      ),
      title: Text(
        family.name,
        style: Theme.of(context).textTheme.headline6,
      ),
      subtitle: Text(family.race.value),
      trailing: Text(family.available()),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => _FamilyDetail(family: family),
          ),
        );
      },
    );
  }
}

class _FamilyDetail extends StatelessWidget {
  const _FamilyDetail({Key key, this.family}) : super(key: key);

  final Family family;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: W.defaultAppBar,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: Column(
                children: [
                  Container(
                    child: Center(
                      child: Hero(
                        tag: family.name,
                        child: Image.network(
                          family.image,
                          width: min(400, MediaQuery.of(context).size.width),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        family.name,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.child_care),
                          const SizedBox(width: 8.0),
                          Text(
                            family.boss,
                            style: Theme.of(context).textTheme.subtitle1,
                          ),
                        ],
                      ),
                      family.consultant != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.book),
                                const SizedBox(width: 8.0),
                                Text(
                                  family.consultant,
                                  style: Theme.of(context).textTheme.subtitle1,
                                ),
                              ],
                            )
                          : Container(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home),
                          SizedBox(width: 8.0),
                          Text(family.building.value),
                        ],
                      ),
                      Text(
                        family.race.value,
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              title: Text(S.regimes),
              trailing: const Icon(Icons.navigate_next),
              onTap: () => Navigator.push(context, _RegimesRoute(family)),
            ),
            ListTile(
              title: Text(S.members),
              trailing: const Icon(Icons.navigate_next),
              onTap: () => Navigator.push(context, _MembersRoute(family)),
            ),
            ListTile(
              title: Text(S.announcements),
              trailing: const Icon(Icons.navigate_next),
              onTap: () =>
                  Navigator.push(context, _AnnouncementsRoute(family.name)),
            ),
          ],
        ),
      ),
      floatingActionButton: Consumer<PlayerState>(
        builder: (context, state, child) {
          if (state.player.nickname == family.boss) {
            return child;
          }
          return Container();
        },
        child: FloatingActionButton(
          child: Icon(Icons.build),
          onPressed: () {
            // todo navigate to family setting page
          },
        ),
      ),
    );
  }
}

class RegimesWidget extends StatelessWidget {
  const RegimesWidget({Key key, this.family}) : super(key: key);

  final Family family;

  @override
  Widget build(BuildContext context) {
    var bossRegime = List.of(family.members);
    var chiefRegimes =
        family.chiefs.map((c) => c.members).expand((m) => m).toSet();
    bossRegime.removeWhere((m) => chiefRegimes.contains(m));
    bossRegime.remove(family.boss);

    return Scaffold(
      appBar: AppBar(
        title: Text('${family.name} ${S.regimes}'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ExpansionTile(
              initiallyExpanded: true,
              title: Text(family.boss),
              subtitle: Text(
                S.boss,
                style: Theme.of(context).textTheme.subtitle2,
              ),
              children: bossRegime.map((m) => Text(m)).toList(growable: false),
            ),
            ...family.chiefs.map((chief) {
              return ExpansionTile(
                title: Text(chief.name),
                subtitle: Text(
                  'Chief',
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                children:
                    chief.members.map((m) => Text(m)).toList(growable: false),
              );
            }).toList(growable: false),
          ],
        ),
      ),
    );
  }
}

class AnnouncementsWidget extends StatefulWidget {
  final String familyName;

  const AnnouncementsWidget(this.familyName, {Key key}) : super(key: key);

  @override
  _AnnouncementsWidgetState createState() => _AnnouncementsWidgetState();
}

class _AnnouncementsWidgetState extends State<AnnouncementsWidget> {
  Future<List<Announcement>> announcementsFuture;

  @override
  void initState() {
    super.initState();
    announcementsFuture = fetch();
  }

  Future<List<Announcement>> fetch() =>
      context.read<FamilyService>().announcement(family: widget.familyName);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: W.defaultAppBar,
      body: FutureBuilder<List<Announcement>>(
        future: announcementsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          } else if (snapshot.hasError) {
            return RefreshOnErrorWidget(onPressed: () {
              setState(() {
                announcementsFuture = fetch();
              });
            });
          }

          var announcements = snapshot.data;

          return RefreshIndicator(
            onRefresh: () {
              var feature = fetch();
              setState(() {
                announcementsFuture = feature;
              });
              return feature;
            },
            child: ListView.separated(
              separatorBuilder: (_, __) => Divider(),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                var announcement = announcements[index];
                return ListTile(
                  title: announcement.secret
                      ? Row(
                          children: [
                            Text(announcement.title),
                            SizedBox(width: 8.0),
                            Chip(
                              label: Text(
                                S.secret,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyText1
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              backgroundColor: Colors.red,
                            )
                          ],
                        )
                      : Text(announcement.title),
                  subtitle: Text(announcement.content),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _MembersWidget extends StatelessWidget {
  const _MembersWidget(this.family, {Key key}) : super(key: key);

  final Family family;

  @override
  Widget build(BuildContext context) {
    var members = List.of(family.members);
    members.removeWhere((member) {
      return member == family.boss ||
          member == family.consultant ||
          family.chiefs.map((e) => e.name).contains(member);
    });
    members.insert(0, family.boss);
    members.insert(1, family.consultant);
    var chiefs = family.chiefs.map((e) => e.name).toList(growable: false);
    chiefs.sort();
    members.insertAll(2, chiefs);

    return Scaffold(
      appBar: W.defaultAppBar,
      body: ListView.separated(
        itemCount: members.length,
        separatorBuilder: (_, __) => Divider(),
        itemBuilder: (context, index) {
          var member = members[index];
          Widget subTitle;

          if (member == family.boss) {
            subTitle = Text(S.boss);
          } else if (member == family.consultant) {
            subTitle = Text(S.consultant);
          } else if (family.chiefs.map((c) => c.name).contains(member)) {
            subTitle = Text(S.chief);
          }

          return ListTile(
            title: Text(member),
            subtitle: subTitle,
          );
        },
      ),
    );
  }
}

class FamilyPageRoute<T> extends MaterialPageRoute<T> {
  FamilyPageRoute() : super(builder: (BuildContext context) => FamilyPage());
}

class _RegimesRoute<T> extends MaterialPageRoute<T> {
  final Family family;

  _RegimesRoute(this.family)
      : super(builder: (BuildContext context) => RegimesWidget(family: family));
}

class _AnnouncementsRoute<T> extends MaterialPageRoute<T> {
  final String family;

  _AnnouncementsRoute(this.family)
      : super(builder: (BuildContext context) => AnnouncementsWidget(family));
}

class _MembersRoute<T> extends MaterialPageRoute<T> {
  final Family family;

  _MembersRoute(this.family)
      : super(builder: (BuildContext context) => _MembersWidget(family));
}

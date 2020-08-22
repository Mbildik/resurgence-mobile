import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/enum.dart';
import 'package:resurgence/family/service.dart';
import 'package:resurgence/ui/button.dart';

class Family {
  String name;
  String boss;
  String consultant;
  Building building;
  List<String> members;
  AbstractEnum race;
  List<Chief> chiefs;
  int bank;

  Family({
    this.name,
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
          return loadingWidget();
        } else if (snapshot.hasError) {
          return errorWidget();
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

  Widget loadingWidget() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget errorWidget() {
    return Center(
      child: Column(
        children: <Widget>[
          Button(
            child: Text(S.reload),
            onPressed: () => setState(() {
              familiesFuture = fetchFamilies();
            }),
          ),
          Text(S.errorOccurred),
        ],
      ),
    );
  }
}

class _FamilyListTile extends StatelessWidget {
  const _FamilyListTile({Key key, this.family}) : super(key: key);

  final Family family;

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 8.0),
            color: Theme.of(context).colorScheme.primary,
            child: Column(
              children: <Widget>[
                Text(
                  family.name,
                  style: Theme.of(context).textTheme.headline4,
                ),
                SizedBox(height: 8.0),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                  padding: EdgeInsets.all(4.0),
                  child: Text(family.race.value),
                ),
              ],
            ),
          ),
          Text(family.boss),
          Text(family.consultant ?? ''),
          Text(family.building.value),
          ...family.members.map((e) => Text(e)).toList(growable: false),
        ],
      ),
    );
  }
}

class FamilyPageRoute<T> extends MaterialPageRoute<T> {
  FamilyPageRoute() : super(builder: (BuildContext context) => FamilyPage());
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resurgence/constants.dart';
import 'package:resurgence/duration.dart';
import 'package:resurgence/enum.dart';
import 'package:resurgence/item/item.dart';
import 'package:resurgence/money.dart';
import 'package:resurgence/player/player.dart';
import 'package:resurgence/real-estate/service.dart';
import 'package:resurgence/ui/error_handler.dart';

class RealEstate {
  Building building;
  String owner;

  RealEstate({this.building, this.owner});

  RealEstate.fromJson(Map<String, dynamic> json) {
    building = json['building'] != null
        ? new Building.fromJson(json['building'])
        : null;
    owner = json['owner'];
  }
}

class Building extends AbstractEnum {
  int price;
  ISO8601Duration duration;
  Set<Produce> produces;

  Building({this.price, this.duration, this.produces, key, value})
      : super(key: key, value: value);

  Building.fromJson(Map<String, dynamic> json) {
    var abstractEnum = AbstractEnum.fromJson(json);
    key = abstractEnum.key;
    value = abstractEnum.value;
    price = json['price'];
    duration = ISO8601Duration(json['duration']);
    if (json['produces'] != null) {
      produces = (json['produces'] as List).map((v) {
        return Produce(Item.fromJson(v['item']), v['value']);
      }).toSet();
    }
  }
}

class Produce {
  Item item;
  int value;

  Produce(this.item, this.value);
}

class RealEstatePage extends StatefulWidget {
  @override
  _RealEstatePageState createState() => _RealEstatePageState();
}

class _RealEstatePageState extends State<RealEstatePage> {
  Future<List<RealEstate>> realEstateFuture;

  @override
  void initState() {
    super.initState();
    realEstateFuture = context.read<RealEstateService>().all();
  }

  void _refresh() {
    setState(() {
      realEstateFuture = context.read<RealEstateService>().all();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.realEstate),
      ),
      body: FutureBuilder<List<RealEstate>>(
        future: realEstateFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
            return Text('Error');
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          var realEstates = snapshot.data;
          return ListView.builder(
            itemCount: realEstates.length,
            itemBuilder: (context, index) {
              var realEstate = realEstates[index];
              return ExpansionTile(
                leading: Image.network('https://hezaryar.com/static/bank.png'),
                title: Text(realEstate.building.value),
                subtitle: MoneyWidget(realEstate.building.price),
                children: [
                  ...realEstate.building.produces.map((e) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(e.item.value),
                          ),
                        ),
                        Text(' x '),
                        Text(e.value.toString()),
                      ],
                    );
                  }).toList(growable: false),
                ],
                trailing: _buyButton(context, realEstate),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buyButton(BuildContext context, RealEstate realEstate) {
    if (realEstate.owner != null) {
      var player = Provider.of<PlayerState>(context, listen: false).player;

      bool isOwner = player.nickname == realEstate.owner;

      if (isOwner) {
        return FlatButton(
          child: Text(S.sell),
          color: Colors.red[700],
          onPressed: () => context
              .read<RealEstateService>()
              .sell(realEstate.building)
              .catchError((e) => ErrorHandler.showError<Null>(context, e))
              .then((_) => this._refresh()),
        );
      }

      return FlatButton(
        child: Text(realEstate.owner),
        onPressed: null,
      );
    }

    return FlatButton(
      child: Text(S.buy),
      color: Colors.green,
      onPressed: () => context
          .read<RealEstateService>()
          .buy(realEstate.building)
          .catchError((e) => ErrorHandler.showError<Null>(context, e))
          .then((_) => this._refresh()),
    );
  }
}

class RealEstatePageRoute<T> extends MaterialPageRoute<T> {
  RealEstatePageRoute()
      : super(builder: (BuildContext context) => new RealEstatePage());
}

import 'package:flutter/material.dart';
import 'package:resurgence/enum.dart';

class Player {
  String nickname;
  AbstractEnum race;
  int balance;
  String family;
  int health;
  int honor;
  int usableHonor;
  AbstractEnum title;
  int experience;
  String image;
  AbstractEnum wealth;

  Player({
    this.nickname,
    this.race,
    this.balance,
    this.family,
    this.health,
    this.honor,
    this.usableHonor,
    this.title,
    this.experience,
    this.image,
  });

  Player.fromJson(Map<String, dynamic> json) {
    nickname = json['nickname'];
    race = json['race'] != null ? AbstractEnum.fromJson(json['race']) : null;
    balance = json['balance'];
    family = json['family'];
    health = json['health'] == null ? null : json['health'];
    honor = json['honor'];
    usableHonor = json['usable_honor'] == null ? null : json['usable_honor'];
    title = json['title'] != null ? AbstractEnum.fromJson(json['title']) : null;
    experience = json['experience'];
    image = json['image'];
    wealth =
        json['wealth'] != null ? AbstractEnum.fromJson(json['wealth']) : null;
  }
}

class PlayerState extends ChangeNotifier {
  static String playerName;
  Player _player;

  void updatePlayer(Player player) {
    _player = player;
    playerName = name;
    notifyListeners();
  }

  Player get player => _player;

  String get name => _player?.nickname;
}

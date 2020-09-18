import 'package:flutter/material.dart';
import 'package:resurgence/enum.dart';

class Player {
  String nickname;
  AbstractEnum race;
  int balance;
  int health;
  int honor;
  AbstractEnum title;
  int experience;

  Player(
      {this.nickname,
      this.race,
      this.balance,
      this.health,
      this.honor,
      this.title,
      this.experience});

  Player.fromJson(Map<String, dynamic> json) {
    nickname = json['nickname'];
    race = json['race'] != null ? AbstractEnum.fromJson(json['race']) : null;
    balance = json['balance'];
    health = json['health'];
    honor = json['honor'];
    title = json['title'] != null ? AbstractEnum.fromJson(json['title']) : null;
    experience = json['experience'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['nickname'] = this.nickname;
    if (this.race != null) {
      data['race'] = this.race.toJson();
    }
    data['balance'] = this.balance;
    data['health'] = this.health;
    data['honor'] = this.honor;
    if (this.title != null) {
      data['title'] = this.title.toJson();
    }
    data['experience'] = this.experience;
    return data;
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

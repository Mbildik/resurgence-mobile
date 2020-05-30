import 'package:flutter/material.dart';

/// Application String Constants
class S {
  // Misc
  static var applicationTitle = 'Resurgence';
  static var applicationDescription = 'Text-Based Mafia Game';
  static var version = '1.0.0+1'; // todo retrieve from pubspec.yaml

  // Validation
  static var validationRequired = 'validation.required';

  // Label
  static var email = 'email';
  static var nickname = 'nickname';
  static var create = 'create';
  static var sendEmail = 'send.email';
  static var submit = 'submit';
  static var password = 'password';
  static var passwordForgot = 'password.forgot';
  static var passwordForgotInfo = 'password.forgot.info';
  static var login = 'login';
  static var logout = 'logout';
  static var loginGoogle = 'login.google';
  static var signUp = 'sign_up';
  static var signUpInfo = 'sign_up.info';
  static var playerCreationTitle = 'player.creation.title';
  static var race = 'race';
  static var balance = 'balance';
  static var health = 'health';
  static var honor = 'honor';
  static var experience = 'experience';
  static var reload = 'reload';
  static var errorOccurred = 'error.occurred';
  static var profile = 'profile';
  static var task = 'task';
  static var soloTask = 'solo.task';
  static var info = 'info';
  static var perform = 'perform';
  static var duration = 'duration';
  static var auxiliary = 'auxiliary';
  static var skillGain = 'skillGain';
  static var drop = 'drop';
  static var requiredItemCategory = 'required.item.category';
  static var difficulty = 'difficulty';
  static var easy = 'easy';
  static var medium = 'medium';
  static var hard = 'hard';
  static var playerItemEmpty = 'player.item.empty';
  static var failedTaskResult = 'failed.task.result';
  static var bank = 'bank';
  static var bankBalance = 'bank.balance';
  static var currentBalance = 'current.balance';
  static var bankTitle = 'bank';
  static var money = 'money';
  static var withdraw = 'withdraw';
  static var deposit = 'deposit';
  static var integerRequired = 'integer.required';
  static var interest = 'interest';
  static var transfer = 'transfer';
  static var bankAccount = 'bank.account';
}

class W {
  static var defaultAppBar = AppBar(
    title: Text(S.applicationTitle),
  );
}

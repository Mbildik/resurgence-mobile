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
  static var email = 'Email';
  static var nickname = 'nickname';
  static var create = 'create';
  static var sendEmail = 'send.email';
  static var submit = 'submit';
  static var cancel = 'cancel';
  static var password = 'Password';
  static var passwordForgot = 'Forgot password?';
  static var passwordForgotInfo = 'password.forgot.info';
  static var logout = 'logout';
  static var signUpGoogle = 'Sign up with Google';
  static var signUp = 'Sign Up';
  static var signIn = 'Sign In';
  static var doNotHaveAnAccount = 'Don\'t have an account';
  static var alreadyHaveAnAccount = 'Already have an account';
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
  static var min = 'min';
  static var max = 'max';
  static var noActiveInterest = 'no.active.interest';
  static var currentInterest = 'current.interest';
  static var description = 'description';
  static var to = 'to';
  static var mail = 'mail';
  static var send = 'send';
  static var sent = 'sent';
  static var received = 'received';
  static var delete = 'delete';
  static var read = 'read';
  static var noMail = 'no.mail';
  static var sentSuccessfully = 'sent.successfully';
  static var reportMail = 'report.mail';
  static var reportMailDetail = 'report.mail.detail';
  static var realEstate = 'real.estate';
  static var buy = 'buy';
  static var sell = 'sell';
  static var signInPageTitle = 'Welcome back!';
  static var signInPageDescription = 'Sign in to your account';
  static var signUpPageTitle = 'Welcome!';
  static var signUpPageDescription = 'Sign up with email';
}

class W {
  static var defaultAppBar = AppBar(
    title: Text(S.applicationTitle),
  );
}

/// Assets constants
class A {
  static var applicationLogo = 'assets/img/flutter_logo.png';
  static var googleLogo = 'assets/img/google.png';
  static var bankLogo = 'assets/img/bank.png';
}

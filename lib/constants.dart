import 'package:flutter/material.dart';
import 'package:resurgence/money.dart';

enum _Env { local, dev }

/// Application String Constants
class S {
  // Environment
  static var _env = _Env.local;

  // Urls
  static var baseUrl = () {
    switch (_env) {
      case _Env.local:
        return 'http://192.168.1.101:8080/';
      case _Env.dev:
        return 'https://hezaryar.com/';
    }
  }();
  static var wsUrl = () {
    switch (_env) {
      case _Env.local:
        return 'ws://192.168.1.101:6060/v0/channels?apikey=AQEAAAABAAD_rAp4DJh05a1HAwFT3A6K';
      case _Env.dev:
        return 'wss://hezaryar.com:2053/v0/channels?apikey=AQEAAAABAAD_rAp4DJh05a1HAwFT3A6K';
    }
  }();

  // Misc
  static var applicationTitle = 'Resurgence';
  static var applicationDescription = 'Text-Based Mafia Game';
  static var version = '1.0.0+1'; // todo retrieve from pubspec.yaml
  static var userAgent = 'ResurgenceMobile/$version';
  static var dateFormat = 'y-MM-dd HH:mm';

  // todo static var dateFormat = 'dd/MM/y HH:mm';

  // Validation
  static var validationRequired = 'Required';

  // Label
  static var email = 'Email';
  static var nickname = 'nickname';
  static var create = 'Create';
  static var sendEmail = 'send.email';
  static var submit = 'Submit';
  static var password = 'Password';
  static var passwordForgot = 'Forgot password?';
  static var passwordForgotInfo = 'password.forgot.info';
  static var logout = 'logout';
  static var signUpGoogle = 'Sign up with Google';
  static var signUpEmail = 'Sign up with Email';
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
  static var reload = 'Reload';
  static var errorOccurred = 'An error occurred!';
  static var profile = 'Profile';
  static var task = 'Task';
  static var tasks = 'Tasks';
  static var soloTask = 'solo.task';
  static var info = 'Information';
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
  static var bank = 'Bank';
  static var bankBalance = 'bank.balance';
  static var currentBalance = 'Current Balance';
  static var bankTitle = 'Bank';
  static var money = 'Money';
  static var withdraw = 'Withdraw';
  static var deposit = 'Deposit';
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
  static var realEstate = 'Real Estate';
  static var buy = 'buy';
  static var sell = 'sell';
  static var signInPageTitle = 'Welcome back!';
  static var signInPageDescription = 'Sign in to your account';
  static var signUpPageTitle = 'Welcome!';
  static var signUpPageDescription = 'Sign up with email';
  static var family = 'Family';
  static var families = 'Families';

  static var ok = 'Ok';
  static var delete = 'Delete';
  static var cancel = 'Cancel';

  static var chat = 'Chat';
  static var messages = 'Messages';
  static var search = 'Search';
  static var offline = 'Offline';
  static var online = 'Online';
  static var typeSomething = 'Type something...';

  static var boss = 'Boss';
  static var consultant = 'Consultant';
  static var chief = 'Chief';
  static var secret = 'Secret';
  static var regimes = 'Regimes';
  static var members = 'Members';
  static var announcements = 'Announcements';
  static var memberDeleteTitle = 'Are you sure!';
  static var memberDeleteContent = 'You are firing a member!';
  static var fire = 'Fire';
  static var disqualify = 'Disqualify';
  static var consultantDisqualifyTitle = memberDeleteTitle;
  static var consultantDisqualifyContent = 'You are disqualify a consultant';
  static var chiefDisqualifyTitle = memberDeleteTitle;
  static var chiefDisqualifyContent = 'You are disqualify a chief';
  static var promoteToConsultant = 'Consultant';
  static var promoteToChief = 'Chief';
  static var accept = 'Accept';
  static var revoke = 'Revoke';
  static var noData = 'There is nothing here!';
  static var noInvitations = 'There is no invitations!';
  static var assign = 'Assign';
  static var titleHintText = 'Enter your announcement title';
  static var contentHintText = 'Enter your announcement content';
  static var announcementSecretInfo =
      'Only family member can see this announcement.';
  static var management = 'Management';
  static var humanResources = 'Human Resources';
  static var applicationsInvitations = 'Applications Invitations';
  static var regimeManagement = 'Regime Management';
  static var announcement = 'Announcement';
  static var destroy = 'Destroy';
  static var familyDestroyConfirmationTitle = 'Are you sure!';
  static var familyDestroyConfirmationContent =
      'You are gonna destroy the whole family.';
  static var discharge = 'Discharge';
  static var assignChiefDialogTitle = 'Choose an chief to assign';
  static var memberDischargeConfirmationTitle = 'Are you sure!';

  static memberDischargeConfirmationContent(String member, String chief) =>
      'You are going to discharge $member from $chief';
  static var edit = 'Edit';
  static var clear = 'Clear';
  static var announcementDeleteConfirmationTitle = 'Are you sure!';
  static var announcementDeleteConfirmationContent =
      'You are going to delete this announcement!';
  static var leave = 'Leave';
  static var leaveFamilyConfirmationTitle = 'Leaving family!';
  static var leaveFamilyConfirmationContent = 'You are leaving the family.';
  static var apply = 'Apply';
  static var applySuccessInfo = 'Your application has been made.';
  static var myFamily = 'My Family';
  static var noFamilyAnymore = 'You don\'t have a family anymore.';
  static var familyCreationTitle =
      'To create a crime family you must meet this requirements.';
  static var familyCreationMoneyRequirement =
      '${Money.format(5000000)} in your pocket.';
  static var familyCreationHonorRequirement = '1K HP (Honour Points)';
  static var familyName = 'Family name';
  static var createNewFamily = 'Create new family';
  static var chooseImage = 'Choose an image';

  static var organize = 'Organize';
  static var planNotFoundOrCompleted =
      'Plan lider tarafından tamamlandı veya iptal edildi.';
  static var quit = 'Çık';
  static var planQuitConfirmationTitle = 'Çıkmak istediğinden emin misin?';
  static var planQuitConfirmationContent =
      'Göreve davet ettiğin herkes görevden ayrılacak!';
  static var refresh = 'Yenile';
  static var selectItem = 'İtem seç';
  static var changeItem = 'Item değiştir';
  static var planPreconditionErrorTitle =
      'Ekiptekilerin bazılarının malzemeleri eksik';

  static planPrecondition(String member, String category) =>
      '$member kategoride item seçmedi: $category';
  static var invitePlayer = 'Oyuncu Davet Et';
  static var add = 'Ekle';
  static var item = 'Item';

  static var planRemoveMemberConfirmationTitle = 'Plan üyesi çıkarılacak';

  static planRemoveMemberConfirmationContent(String member) =>
      '$member gerçekten çıkaracak mısın?';

  static var sentAMessageNotificationContent = 'Mesaj gönderdi';
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

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

  static const DSN =
      'https://a08e58dade624766a001060e647ff585@o411000.ingest.sentry.io/5443874';

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
  static const changePassword = 'Şifreyi Değiştir';
  static const logout = 'Çıkış Yap';
  static const logoutConfirmationTitle = 'Çıkış yapmak üzeresiniz!';
  static const logoutConfirmationContent =
      'Uygulamadan çıkış yapmak istediğinize emin misiniz?';
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
  static const health = 'Sağlık';
  static const honor = 'Onur';
  static const usableHonor = 'Kullanılabilir Onur Puanı';
  static var experience = 'experience';
  static var reload = 'Reload';
  static var errorOccurred = 'Bir hata oluştu.';
  static const profile = 'Profil';
  static var task = 'Task';
  static var tasks = 'Tasks';
  static var soloTask = 'Solo Görevler';
  static var info = 'Information';
  static var perform = 'Yap';
  static var duration = 'duration';
  static var auxiliary = 'Yardımcı Skiller';
  static var skillGain = 'Kazanılacak Skiller';
  static var skillGained = 'Kazanılan Skiller';
  static var drop = 'Drop';
  static var requiredItemCategory = 'required.item.category';
  static var difficulty = 'difficulty';
  static var easy = 'easy';
  static var medium = 'medium';
  static var hard = 'hard';
  static const playerItemEmpty = 'Hiç itemin yok.';

  static playerItemEmptyCategories(Set<String> categories) {
    if (categories.isEmpty) return playerItemEmpty;

    if (categories.length == 1)
      return '${categories.first} kategorisine ait hiç itemin yok.';

    return '${categories.join(', ')} kategorilerine ait hiç itemin yok.';
  }

  static const failedTaskResult = 'Beceremedin.';
  static String failedTaskResultMember(String member) => '$member beceremedi.';
  static var bank = 'Bank';
  static var bankBalance = 'Banka Bakiyesi';
  static var currentBalance = 'Nakit';
  static var bankTitle = 'Bank';
  static const money = 'Para';
  static const moneyToInterest = 'Faize yatırılacak para';
  static const withdraw = 'Çek';
  static const deposit = 'Yatır';
  static var integerRequired = 'integer.required';
  static var interest = 'Faiz';
  static var interestHelp =
      'Faize yatırmak istediğin tutara göre tablodaki faiz karşılığını bir günün sonunda alırsın.';
  static var transfer = 'Transfer';
  static var transferHelp =
      'Para transferi etmek istediğin oyuncunun adını ve transfer edeceğin miktarı gir. Eğer istersen açıklama girebilirsin.';
  static var bankAccount = 'Banka Hesabı';
  static var bankAccountHelp =
      'Saldırı alırsanız cebinizdeki para saldırgana geçer. Paranı korumak için bankaya yatırmalısın.';
  static var min = 'min';
  static var max = 'max';
  static var noActiveInterest = 'no.active.interest';
  static var currentInterest = 'current.interest';
  static var description = 'Açıklama';
  static var to = 'to';
  static var realEstate = 'Real Estate';
  static var buy = 'Satın Al';
  static var sell = 'Sat';
  static var signInPageTitle = 'Tekrar hoş geldin!';
  static var signInPageDescription = 'Hesabınıza giriş yapın';
  static var signUpPageTitle = 'Hoş geldin!';
  static var signUpPageDescription = 'Email ile kayıt ol';
  static var family = 'Aile';
  static var families = 'Aileler';

  static var ok = 'Tamam';
  static var delete = 'Sil';
  static var cancel = 'İptal';

  static var chat = 'Sohbet';
  static var messages = 'Mesajlar';
  static var search = 'Ara';
  static var offline = 'Çevrimdışı';
  static var online = 'Çevrimiçi';
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
  static var help = 'Yardım';

  static var multiplayerTaskHelp =
      'Ekibin durumunu kontrol etmek için yenile tuşunu kullan.'
      '\n\nGörevi tamamladığında üyelerin sonuçlarını görebilirsin.'
      '\n\nİstersen görevi çıkış butonuna basarak iptal edebilirsin.';

  static var soloTaskHelp = 'Suç işleyerek para, malzeme ve seviye'
      ' kazanabilirsin. Her suç belirli bir süre sonra tekrar aktif hale gelir.'
      '\nBazı suçları işlemek için bir takım malzemelere ihtiyaç duyabilirsin.'
      ' Gerekli kategorideki malzemenin tamamını seçmek için + butonuna basılı'
      ' tut.'
      '\nResimlere tıklayarak suça ait detayları öğrenebilirsin.';

  static var timeToLeftToInterestComplete = 'Faizin tamamlanmasına kalan süre';

  static haveItem(quantity) {
    if (quantity < 1) return 'Kalmadı';
    return '$quantity tane kaldı';
  }

  static const npc = 'NPC';
  static const npcHelp =
      'NPC\'den oyun içerisinde bulunan bazı item\'ları alabilirsin.\n'
      'Almak istediğin item\'lara tıkla ve satın al.\n'
      'Sepetten istemediğin item\'ları tıklayarak teker teker veya '
      'uzun basarak hepsini çıkabilirsin.\n';

  static const multiplayerTaskGainMember = 'şunları kazandı.';
  static const multiplayerTaskGainSelf = 'Şunları kazandın.';
}

class W {
  static var defaultAppBar = AppBar(
    title: Text(S.applicationTitle),
  );
}

/// Assets constants
class A {
  static const FOLDER = 'assets/img';
  static const applicationLogo = '$FOLDER/flutter_logo.png';
  static const googleLogo = '$FOLDER/google.png';
  static const bankLogo = '$FOLDER/bank.png';
  static const EMPTY_IMAGE = '$FOLDER/no-item.png';
  static const BUSTED = '$FOLDER/busted.png';
  static const MONEY = '$FOLDER/money.png';
}

import 'package:flutter/material.dart';
import 'package:resurgence/enum.dart';
import 'package:resurgence/money.dart';

enum _Env { local, dev }

/// Application String Constants
class S {
  // Environment
  static const _env = _Env.dev;

  // Urls
  static var baseUrl = () {
    switch (_env) {
      case _Env.local:
        return 'http://192.168.1.101:8080/';
      case _Env.dev:
        return 'https://resurgence.ugalt.com/';
    }
  }();

  static bool isInDebugMode = _env == _Env.local;

  static const DSN =
      'https://a08e58dade624766a001060e647ff585@o411000.ingest.sentry.io/5443874';

  // Misc
  static const applicationTitle = 'Resurgence';
  static const applicationDescription = 'Text-Tabanlı Mafya Oyunu';
  static const version = '0.1.1+12'; // todo retrieve from pubspec.yaml
  static const userAgent = 'ResurgenceMobile/$version';
  static const dateFormat = 'dd.MM.y HH:mm';

  // Validation
  static const validationRequired = 'Zorunlu';

  // Label
  static const email = 'Email';
  static const nickname = 'Lakabın';
  static const create = 'Oluştur';
  static const sendEmail = 'send.email';
  static const submit = 'Submit';
  static const password = 'Şifre';
  static const passwordForgot = 'Şifremi Unuttum';
  static const logout = 'Çıkış Yap';
  static const logoutConfirmationTitle = 'Çıkış yapmak üzeresiniz!';
  static const logoutConfirmationContent =
      'Uygulamadan çıkış yapmak istediğinize emin misiniz?';
  static const signUpGoogle = 'Google ile giriş yap';
  static const signUpEmail = 'Email ile kayıt ol';
  static const signUp = 'Kayıt ol';
  static const signIn = 'Giriş yap';
  static const doNotHaveAnAccount = 'Hesabın yok mu?';
  static const alreadyHaveAnAccount = 'Hesabın var mı?';
  static const playerCreationTitle =
      'Mafya dünyasının zorlu günleri seni bekliyor';
  static const playerCreationDescription = 'Hesabını oluşturdun.\n'
      'Şimdi sıra ırkını ve lakabını seçerek \n'
      'bu karanlık dünyaya girme vakti!';
  static const race = 'race';
  static const balance = 'balance';
  static const health = 'Sağlık';
  static const honor = 'Onur';
  static const usableHonor = 'Kullanılabilir Onur Puanı';
  static const experience = 'experience';
  static const reload = 'Yeniden yükle';
  static const errorOccurred = 'Bir hata oluştu.';
  static const profile = 'Profil';
  static const task = 'Task';
  static const tasks = 'Görevler';
  static const soloTask = 'Solo';
  static const info = 'Information';
  static const perform = 'Yap';
  static const duration = 'duration';
  static const auxiliary = 'Yardımcı Skiller';
  static const skillGain = 'Kazanılacak Skiller';
  static const skillGained = 'Kazanılan Skiller';
  static const drop = 'Drop';
  static const requiredItemCategory = 'required.item.category';
  static const difficulty = 'difficulty';
  static const easy = 'easy';
  static const medium = 'medium';
  static const hard = 'hard';
  static const playerItemEmpty = 'Hiç itemin yok.';

  static playerItemEmptyCategories(Set<String> categories) {
    if (categories.isEmpty) return playerItemEmpty;

    if (categories.length == 1)
      return '${categories.first} kategorisine ait hiç itemin yok.';

    return '${categories.join(', ')} kategorilerine ait hiç itemin yok.';
  }

  static const failedTaskResult = 'Beceremedin.';

  static String failedTaskResultMember(String member) => '$member beceremedi.';
  static const bank = 'Banka';
  static const bankBalance = 'Banka Bakiyesi';
  static const currentBalance = 'Nakit';
  static const bankTitle = 'Bank';
  static const money = 'Para';
  static const moneyToInterest = 'Faize yatırılacak para';
  static const withdraw = 'Çek';
  static const deposit = 'Yatır';
  static const integerRequired = 'integer.required';
  static const interest = 'Faiz';
  static const interestHelp =
      '$helpBullet Tablodaki faiz karşılığını yarın aynı saatte alırsın.';
  static const transfer = 'Transfer';
  static const transferHelp =
      'Para transferi etmek istediğin oyuncunun adını ve transfer edeceğin miktarı gir. Eğer istersen açıklama girebilirsin.';
  static const bankAccount = 'Banka Hesabı';
  static const bankAccountHelp =
      '$helpBullet Saldırı alırsanız cebinizdeki para saldırgana geçer.'
      '$helpSeparator Paranı korumak için bankaya yatırmalısın.';
  static const min = 'min';
  static const max = 'max';
  static const noActiveInterest = 'no.active.interest';
  static const currentInterest = 'current.interest';
  static const description = 'Açıklama';
  static const to = 'to';
  static const realEstate = 'Real Estate';
  static const buy = 'Satın Al';
  static const sell = 'Sat';
  static const signInPageTitle = 'Tekrar hoş geldin!';
  static const signInPageDescription = 'Hesabınıza giriş yapın';
  static const signUpPageTitle = 'Hoş geldin!';
  static const signUpPageDescription = 'Email ile kayıt ol';
  static const family = 'Aile';
  static const families = 'Aileler';

  static const ok = 'Tamam';
  static const delete = 'Sil';
  static const cancel = 'İptal';

  static const chat = 'Sohbet';
  static const messages = 'Bildirimler';
  static const sendMessage = 'Mesaj Gönder';
  static const search = 'Ara';
  static const offline = 'Çevrimdışı';
  static const online = 'Çevrimiçi';
  static const typeSomething = 'Bir şeyler yaz...';

  static const boss = 'Boss';
  static const consultant = 'Consultant';
  static const chief = 'Chief';
  static const secret = 'Secret';
  static const regimes = 'Regimes';
  static const members = 'Members';
  static const announcements = 'Announcements';
  static const memberDeleteTitle = 'Are you sure!';
  static const memberDeleteContent = 'You are firing a member!';
  static const fire = 'Fire';
  static const disqualify = 'Disqualify';
  static const consultantDisqualifyTitle = memberDeleteTitle;
  static const consultantDisqualifyContent = 'You are disqualify a consultant';
  static const chiefDisqualifyTitle = memberDeleteTitle;
  static const chiefDisqualifyContent = 'You are disqualify a chief';
  static const promoteToConsultant = 'Consultant';
  static const promoteToChief = 'Chief';
  static const accept = 'Accept';
  static const revoke = 'Revoke';
  static const noData = 'Burada henüz görebileceğin bir şey yok!';
  static const noInvitations = 'There is no invitations!';
  static const assign = 'Assign';
  static const titleHintText = 'Enter your announcement title';
  static const contentHintText = 'Enter your announcement content';
  static const announcementSecretInfo =
      'Only family member can see this announcement.';
  static const management = 'Management';
  static const humanResources = 'Human Resources';
  static const applicationsInvitations = 'Applications Invitations';
  static const regimeManagement = 'Regime Management';
  static const announcement = 'Announcement';
  static const destroy = 'Destroy';
  static const familyDestroyConfirmationTitle = 'Are you sure!';
  static const familyDestroyConfirmationContent =
      'You are gonna destroy the whole family.';
  static const discharge = 'Discharge';
  static const assignChiefDialogTitle = 'Choose an chief to assign';
  static const memberDischargeConfirmationTitle = 'Are you sure!';

  static memberDischargeConfirmationContent(String member, String chief) =>
      'You are going to discharge $member from $chief';
  static const edit = 'Edit';
  static const clear = 'Clear';
  static const announcementDeleteConfirmationTitle = 'Are you sure!';
  static const announcementDeleteConfirmationContent =
      'You are going to delete this announcement!';
  static const leave = 'Leave';
  static const leaveFamilyConfirmationTitle = 'Leaving family!';
  static const leaveFamilyConfirmationContent = 'You are leaving the family.';
  static const apply = 'Apply';
  static const applySuccessInfo = 'Your application has been made.';
  static const myFamily = 'My Family';
  static const noFamilyAnymore = 'You don\'t have a family anymore.';
  static const familyCreationTitle =
      'To create a crime family you must meet this requirements.';
  static var familyCreationMoneyRequirement =
      '${Money.format(5000000)} in your pocket.';
  static const familyCreationHonorRequirement = '1K HP (Honour Points)';
  static const familyName = 'Family name';
  static const createNewFamily = 'Create new family';
  static const chooseImage = 'Choose an image';

  static const organize = 'Organize';
  static const planNotFoundOrCompleted =
      'Plan lider tarafından tamamlandı veya iptal edildi.';
  static const quit = 'Çık';
  static const planQuitConfirmationTitle = 'Çıkmak istediğinden emin misin?';
  static const planQuitConfirmationContent =
      'Göreve davet ettiğin herkes görevden ayrılacak!';
  static const refresh = 'Yenile';
  static const selectItem = 'İtem seç';
  static const changeItem = 'Item değiştir';
  static const planPreconditionErrorTitle =
      'Ekiptekilerin bazılarının malzemeleri eksik';

  static planPrecondition(String member, String category) =>
      '$member kategoride item seçmedi: $category';
  static const invitePlayer = 'Oyuncu Davet Et';
  static const add = 'Ekle';
  static const item = 'Item';

  static const planRemoveMemberConfirmationTitle = 'Plan üyesi çıkarılacak';

  static planRemoveMemberConfirmationContent(String member) =>
      '$member gerçekten çıkaracak mısın?';

  static const sentAMessageNotificationContent = 'Mesaj gönderdi';
  static const help = 'Yardım';

  static const helpBullet = '‣ ';
  static const helpSeparator = '\n\n$helpBullet';

  static const multiplayerTaskHelp =
      '$helpBullet Ekibin durumunu kontrol etmek için yenile tuşunu kullan.'
      '$helpSeparator Görevi tamamladığında üyelerin sonuçlarını görebilirsin.'
      '$helpSeparator İstersen görevi çıkış butonuna basarak iptal edebilirsin.';

  static const soloTaskHelp =
      '$helpBullet Suç işleyerek para, malzeme ve seviye'
      ' kazanabilirsin. Her suç belirli bir süre sonra tekrar aktif hale gelir.'
      '$helpSeparator Maksimum kazanacağın parayı ekranda görebilirsin.'
      '$helpSeparator Bazı suçları işlemek için bir takım malzemelere ihtiyaç duyabilirsin.'
      ' Gerekli kategorideki malzemenin tamamını seçmek için + butonuna basılı'
      ' tut.'
      '$helpSeparator Resimlere tıklayarak suça ait detayları öğrenebilirsin.';

  static const timeToLeftToInterestComplete =
      'Faizin tamamlanmasına kalan süre';

  static haveItem(quantity) {
    if (quantity < 1) return 'Kalmadı';
    return '$quantity tane kaldı';
  }

  static const npc = 'Market';
  static const npcHelp =
      '$helpBullet NPC\'den oyun içerisinde bulunan bazı item\'ları alabilirsin.'
      '$helpSeparator Almak istediğin item\'lara tıkla ve satın al.'
      '$helpSeparator Sepetten istemediğin item\'ları tıklayarak teker teker veya '
      'uzun basarak hepsini çıkabilirsin.';

  static const multiplayerTasks = 'Organize';
  static const multiplayerTaskGainMember = 'şunları kazandı.';
  static const multiplayerTaskGainSelf = 'Şunları kazandın.';

  static String groupName(String name) {
    if ('general' == name) {
      return 'Genel Sohbet';
    }
    return name;
  }

  static const cosaNostra = 'Cosa Nostra';
  static const yakuza = 'Yakuza';

  static const onlineUserCount = 'Online oyuncu sayısı';

  static raceDescription(AbstractEnum race) {
    if (race.key == 'COSA_NOSTRA') {
      return 'İtalyan Irkı';
    }

    return 'Japon Irkı';
  }

  static playerImage(String player) => baseUrl + 'player/image/$player';

  static const skills = 'Beceriler';
  static const news = 'Gelişmeler';
  static const inventory = 'Envanter';
  static const quests = 'Görevler';

}

class W {
  static var defaultAppBar = AppBar(
    title: Text(S.applicationTitle),
  );
}

/// Assets constants
class A {
  static const FOLDER = 'assets/img';
  static const applicationLogo = '$FOLDER/welcome_logo.png';
  static const googleLogo = '$FOLDER/google.png';
  static const EMPTY_IMAGE = '$FOLDER/no-item.png';
  static const BUSTED = '$FOLDER/busted.png';
  static const MONEY = '$FOLDER/money.png';
  static const cosaNostra = '$FOLDER/cosa_nostra-128.png';
  static const cosaNostra2x = '$FOLDER/cosa_nostra-256.png';
  static const yakuza = '$FOLDER/yakuza-128.png';
  static const yakuza2x = '$FOLDER/yakuza-256.png';
}

class Routes {
  static const ONLINE_USERS = 'online_users';
  static const USER_PROFILE = 'user_profile';
  static const MULTIPLAYER_TASKS = 'multiplayer_tasks';
  static const SKILLS = 'skills';
}

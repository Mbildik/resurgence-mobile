import 'package:duration/duration.dart';
import 'package:duration/locale.dart';
import 'package:flutter/cupertino.dart';

class ISO8601Duration {
  String _durationString;
  Duration _duration;

  ISO8601Duration(this._durationString) {
    _duration = toDuration();
  }

  ISO8601Duration.from(Duration duration) {
    _duration = duration;
  }

  Duration toDuration() {
    if (!RegExp(r"^P((\d+W)?(\d+D)?)(T(\d+H)?(\d+M)?(\d+S)?)?$")
        .hasMatch(_durationString)) {
      throw ArgumentError("String does not follow correct format");
    }

    final weeks = _parseTime(_durationString, "W");
    final days = _parseTime(_durationString, "D");
    final hours = _parseTime(_durationString, "H");
    final minutes = _parseTime(_durationString, "M");
    final seconds = _parseTime(_durationString, "S");

    return Duration(
      days: days + (weeks * 7),
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }

  String pretty({Locale locale = const Locale('en')}) {
    return prettyDuration(
      _duration,
      locale: _locale(locale),
    );
  }

  DurationLocale _locale(Locale locale) {
    switch (locale.languageCode) {
      case 'tr':
        return const TurkishDurationLocale();
      case 'en':
      default:
        return const EnglishDurationLocale();
    }
  }

  _parseTime(String duration, String timeUnit) {
    final timeMatch = RegExp(r"\d+" + timeUnit).firstMatch(duration);

    if (timeMatch == null) {
      return 0;
    }
    final timeString = timeMatch.group(0);
    return int.parse(timeString.substring(0, timeString.length - 1));
  }
}

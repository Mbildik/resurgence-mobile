import 'package:duration/duration.dart';
import 'package:duration/locale.dart';
import 'package:flutter/material.dart';
import 'package:resurgence/constants.dart';

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

  String pretty({Locale locale = const Locale('en'), abbreviated: false}) {
    return prettyDuration(
      _duration,
      locale: _locale(locale),
      abbreviated: abbreviated,
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

class DurationWidget extends StatelessWidget {
  final ISO8601Duration duration;

  const DurationWidget(this.duration, {Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: S.duration,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.timer),
          Container(margin: EdgeInsets.symmetric(horizontal: 2.0)),
          Text(duration.pretty()),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:on_chain_wallet/app/utils/datetime/datetime.dart';

extension QuickDateTimeFormater on DateTime {
  static String _twoDigits(int n) {
    return n.toString().padLeft(2, "0");
    // if (n >= 10) {
    //   return "$n";
    // } else {
    //   return "0$n";
    // }
  }

  String toDateAndTimeWithSecound() {
    return "$year-${_twoDigits(month)}-${_twoDigits(day)} "
        "${_twoDigits(hour)}:${_twoDigits(minute)}:${_twoDigits(second)}";
  }

  String toDateAndTime() {
    return "$year-${_twoDigits(month)}-${_twoDigits(day)} "
        "${_twoDigits(hour)}:${_twoDigits(minute)}";
  }

  String toTimeOnlyStr() {
    return "${_twoDigits(hour)}:${_twoDigits(minute)}";
  }

  String toOnlyDateStr() {
    return "$year-${_twoDigits(month)}-${_twoDigits(day)}";
  }

  DateTime toOnlyDate() {
    return DateTime(year, month, day);
  }

  TimeOfDay timeOfDay() {
    return TimeOfDay(hour: hour, minute: minute);
  }

  int get secondsSinceEpoch => DateTimeUtils.secondsSinceEpoch(this);
  bool get isAfterNow => toUtc().isAfter(DateTime.now().toUtc());
}

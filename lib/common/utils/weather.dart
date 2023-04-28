import 'package:flutter/material.dart';

enum Weather {
  unknown,
  sunny,
  windy,
  raining;

  String toChinese() {
    switch (this) {
      case sunny:
        return '晴天';
      case windy:
        return '有风';
      case raining:
        return '下雨';
      default:
        return '未知天气';
    }
  }

  DropdownMenuEntry<Weather> get dropdownItem =>
      DropdownMenuEntry(value: this, label: toChinese());
}

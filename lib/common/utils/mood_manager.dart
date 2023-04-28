import 'package:flutter/material.dart';
import 'package:thinwrite/common/utils/mood.dart';

class MoodManager {
  static List<Mood> moodList = [
    Mood(icon: Icons.star_border, name: '开心'),
    Mood(icon: Icons.water_drop_sharp, name: '伤心'),
  ];

  static List<DropdownMenuEntry<Mood>> get moodEntryList {
    List<DropdownMenuEntry<Mood>> ret = [];
    for (var mood in moodList) {
      ret.add(mood.dropdownItem);
    }
    return ret;
  }
}

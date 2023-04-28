import 'package:flutter/material.dart';
import 'package:thinwrite/common/utils/utils.dart';

class WeatherManager {
  static List<Weather> weatherList = [...Weather.values];

  static List<DropdownMenuEntry<Weather>> get weatherEntryList {
    List<DropdownMenuEntry<Weather>> ret = [];
    for (var weather in weatherList) {
      ret.add(weather.dropdownItem);
    }
    return ret;
  }
}

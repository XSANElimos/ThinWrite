// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:thinwrite/common/entity/entity.dart';
import 'package:thinwrite/common/utils/utils.dart';

class DiaryManager {
  late Map<String, DiaryBook> diaryList;
  late Map<String, ConfigFile> configList;
  late PathManager _pm;

  DiaryManager() {
    diaryList = {};
    configList = {};
    _pm.init();
  }

  Future<bool> createNewDiaryBook(
      {required String diaryName,
      required String description,
      String? coverPath}) async {
    if (diaryList.containsKey(diaryName)) {
      ConfigFile newConfig = ConfigFile(
          diaryName: diaryName,
          coverPath: coverPath ?? '',
          description: description,
          tocList: []);
      configList[diaryName] = newConfig;
      DiaryBook newDiary = DiaryBook(
          configFile: newConfig,
          contentList: [],
          isHasCover: coverPath == null ? false : true);
      diaryList[diaryName] = newDiary;
      await newDiary.initLocal(_pm.localRootPath);
      newDiary.uploadToServer();
      return true;
    } else {
      return false;
    }
  }

  DiaryManager copyWith({
    Map<String, DiaryBook>? diaryList,
  }) {
    return DiaryManager();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'diaryList': diaryList,
    };
  }

  factory DiaryManager.fromMap(Map<String, dynamic> map) {
    return DiaryManager();
  }

  String toJson() => json.encode(toMap());

  factory DiaryManager.fromJson(String source) =>
      DiaryManager.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'DiaryManager(diaryList: $diaryList)';

  @override
  bool operator ==(covariant DiaryManager other) {
    if (identical(this, other)) return true;

    return mapEquals(other.diaryList, diaryList);
  }

  @override
  int get hashCode => diaryList.hashCode;
}

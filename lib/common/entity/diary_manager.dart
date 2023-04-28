// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:thinwrite/main.dart';

import 'package:webdav_client/webdav_client.dart' as webdav;

import 'package:path/path.dart' as p;
import 'package:thinwrite/common/entity/entity.dart';
import 'package:thinwrite/common/utils/utils.dart';

class DiaryManager {
  Map<String, DiaryBook> diaryList = {};
  Map<String, ConfigFile> configList = {};
  final PathManager _pm = sPathManager;

  DiaryManager() {
    _pm.init();
  }

  Future<void> uploadDiary(String diaryName, webdav.Client webdavClient) async {
    if (diaryList[diaryName] != null) {
      await diaryList[diaryName]!.uploadToServer(
          rootPath: _pm.localRootPath, webdavClient: webdavClient);
    }
  }

  Future<void> fullUpload(webdav.Client webdavClient) async {
    configList.forEach((name, conf) async {
      await uploadDiary(name, webdavClient);
    });
  }

  Future<void> saveDiary(String diaryName, DiaryContent newContent) async {
    if (configList[diaryName] != null) {
      configList[diaryName]!.updateTocList(newContent);
    }
    if (diaryList[diaryName] != null) {
      await diaryList[diaryName]!.writeLocalDiaryFile(
          PathManager.newDiaryPagePathS(
              _pm.localRootPath, diaryName, newContent.targetTime),
          newContent);
      await diaryList[diaryName]!
          .writeLocalConfigFile(_pm.getLocalConfigPath(diaryName));
    }
  }

  String? getLocalCoverPath(String diaryName) => configList[diaryName] != null
      ? _pm.getLocalCoverPath(diaryName, configList[diaryName]!.coverPath)
      : null;

  List<Toc> getTocList(String diaryName) {
    List<Toc> ret = [];
    if (configList[diaryName] != null) {
      return configList[diaryName]!.tocList;
    } else {
      return ret;
    }
  }

  Future<Map<String, ConfigFile>> loadWebConfigList(
      webdav.Client webDavClient) async {
    List<webdav.File> wFileList =
        await webDavClient.readDir(PathManager.getRemoteProfilePath);
    for (var wFile in wFileList) {
      if (wFile.path != null) {
        await webDavClient.read2File(wFile.path!,
            p.join(_pm.getLocalProfilePath, p.basename(wFile.path!)));
      }
    }
    return loadLocalConfigList();
  }

  Future<Map<String, ConfigFile>> loadLocalConfigList() async {
    configList.clear();
    Directory profileDir =
        Directory(PathManager.getLocalProfilePathS(_pm.localRootPath));
    if (!await profileDir.exists()) {
      return configList;
    }
    await profileDir.list().forEach((element) async {
      if (element is File && p.extension(element.path) == '.config') {
        ConfigFile confFile =
            ConfigFile.fromJson(await File(element.path).readAsString());
        configList[confFile.diaryName] = confFile;
      }
    });
    return configList;
  }

  Future<DiaryBook> loadWebDiary(
      String diaryName, webdav.Client webDavClient) async {
    return await DiaryBook.downloadFromServer(
            diaryName: diaryName,
            rootPath: _pm.localRootPath,
            webdavClient: webDavClient) ??
        DiaryBook.empty();
  }

  Future<DiaryBook> loadLocalDiary(String diaryName) async {
    if (diaryList.containsKey(diaryName)) {
      return diaryList[diaryName]!;
    }
    Directory diaryDir =
        Directory(PathManager.getLocalDiaryPathS(_pm.localRootPath, diaryName));
    if (!await diaryDir.exists()) {
      return DiaryBook.empty();
    }
    DiaryBook? book =
        await DiaryBook.readFromLocal(_pm.localRootPath, diaryName);
    if (book != null) {
      diaryList[diaryName] = book;
      return book;
    } else {
      return DiaryBook.empty();
    }
  }

  Future<bool> createNewDiaryBook(
      {required String diaryName,
      required String description,
      String? coverPath}) async {
    if (!configList.containsKey(diaryName)) {
      //&& !await Directory(_pm.getLocalConfigPath(diaryName)).exists()
      ConfigFile newConfig = ConfigFile(
          diaryName: diaryName,
          coverPath: coverPath ?? '',
          description: description,
          tocList: []);
      configList[diaryName] = newConfig;
      DiaryBook newDiary = DiaryBook(
          configFile: newConfig,
          contentList: {},
          isHasCover: coverPath == null ? false : true);
      diaryList[diaryName] = newDiary;
      await newDiary.initLocal(_pm.localRootPath);
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

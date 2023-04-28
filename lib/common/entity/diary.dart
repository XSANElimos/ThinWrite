// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;
import 'package:path/path.dart' as p;

import 'package:thinwrite/common/entity/entity.dart';
import 'package:thinwrite/common/utils/utils.dart';

class DiaryBook {
  ConfigFile configFile;
  Map<DateTime, DiaryContent> contentList;
  bool isHasCover;

  DiaryBook({
    required this.configFile,
    required this.contentList,
    required this.isHasCover,
  });

  static String timeToString(DateTime time) =>
      '${time.year}${time.month}${time.day}';

  bool get isEmpty => configFile == ConfigFile.empty() ? true : false;

  DiaryContent? getContent(DateTime date) {
    DiaryContent? ret;
    contentList.forEach((dataTime, content) {
      if (timeToString(dataTime) == timeToString(date)) {
        ret = content;
      }
    });
    return ret;
  }

  DiaryContent newPage(DateTime date) {
    DiaryContent? ret;
    contentList.forEach((key, value) {
      if (timeToString(key) == timeToString(date)) {
        ret = value;
      }
    });
    ret ??= DiaryContent.time(date);
    configFile.updateTocList(ret!);
    contentList[date] = ret!;
    return ret!;
  }

  factory DiaryBook.empty() => DiaryBook(
      configFile: ConfigFile.empty(), contentList: {}, isHasCover: false);

  Future<void> initLocal(String rootPath) async {
    Directory localDiaryDir = Directory(
        PathManager.getLocalDiaryPathS(rootPath, configFile.diaryName));
    await localDiaryDir.create(recursive: true);
    await writeLocalConfigFile(
        PathManager.getLocalConfigPathS(rootPath, configFile.diaryName));
    if (configFile.coverPath.isNotEmpty) {
      await writeLocalCoverFile(
          PathManager.getLocalCoverPathS(
              rootPath, configFile.diaryName, configFile.coverPath),
          await File(configFile.coverPath).readAsBytes());
    }
  }

  String getLocalCoverPath(String rootPath) => PathManager.getLocalCoverPathS(
      rootPath, configFile.diaryName, configFile.coverPath);

  static Future<DiaryBook?> readFromLocal(
      String rootPath, String diaryName) async {
    Directory dir =
        Directory(PathManager.getLocalDiaryPathS(rootPath, diaryName));
    if (!await dir.exists()) {
      return null;
    }
    File confFile = File(PathManager.getLocalConfigPathS(rootPath, diaryName));
    if (!await confFile.exists()) {
      return null;
    }
    ConfigFile config = ConfigFile.fromJson(await confFile.readAsString());
    Map<DateTime, DiaryContent> contentList = {};
    var subDirList = dir.list();
    subDirList.forEach((entity) async {
      if (entity is File &&
          p.basenameWithoutExtension(entity.path) != 'cover') {
        DiaryContent diaryContent =
            DiaryContent.fromJson(await entity.readAsString());
        DateTime fileTime = diaryContent.targetTime;
        contentList[fileTime] = diaryContent;
      }
    });
    return DiaryBook(
        configFile: config,
        contentList: contentList,
        isHasCover: config.isHasCover);
  }

  static Future<DiaryBook?> downloadFromServer(
      {required String diaryName,
      required String rootPath,
      required webdav.Client webdavClient}) async {
    Directory localDiaryDir =
        Directory(PathManager.getLocalDiaryPathS(rootPath, diaryName));
    if (!await localDiaryDir.exists()) {
      await localDiaryDir.create(recursive: true);
    }
    List<webdav.File> fileList =
        await webdavClient.readDir(PathManager.getRemoteDiaryPath(diaryName));
    for (webdav.File file in fileList) {
      if (file.name != null) {
        await webdavClient.read2File(
            file.path!,
            p.join(PathManager.getLocalDiaryPathS(rootPath, diaryName),
                file.name!));
      }
    }
    return await readFromLocal(rootPath, diaryName);
  }

  Future<void> uploadToServer(
      {required String rootPath, required webdav.Client webdavClient}) async {
    Directory localDiaryDir = Directory(
        PathManager.getLocalDiaryPathS(rootPath, configFile.diaryName));
    localDiaryDir.list().forEach((element) async {
      if (element is File) {
        await webdavClient.writeFromFile(element.path,
            '${PathManager.getRemoteDiaryPath(configFile.diaryName)}/${p.basename(element.path)}');
      }
    });
    await webdavClient.writeFromFile(
        PathManager.getLocalConfigPathS(rootPath, configFile.diaryName),
        PathManager.getRemoteConfigPath(configFile.diaryName));
    if (configFile.isHasCover) {
      await webdavClient.writeFromFile(
          PathManager.getLocalCoverPathS(
              rootPath, configFile.diaryName, configFile.coverPath),
          PathManager.getRemoteCoverPath(
              configFile.diaryName, configFile.coverPath));
    }
  }

  Future<void> writeLocalDiaryFile(
      String localDiaryPath, DiaryContent diaryContent) async {
    File diaryFile = File(localDiaryPath);
    if (!await diaryFile.exists()) {
      await diaryFile.create(recursive: true, exclusive: false);
    }
    await diaryFile.writeAsString(diaryContent.toJson());
  }

  Future<void> writeWebDiaryFile(
          String filePath, webdav.Client webdavClient) async =>
      await webdavClient.writeFromFile(
          filePath,
          PathManager.getRemoteDiaryPagePath(
              configFile.diaryName, PathManager.getDiaryPageName(filePath)));

  Future<void> writeLocalCoverFile(
      String localCoverPath, Uint8List imageData) async {
    File coverFile = File(localCoverPath);
    if (!await coverFile.exists()) {
      await coverFile.create(recursive: true, exclusive: true);
      await coverFile.writeAsBytes(imageData);
    }
  }

  Future<void> writeWebCoverFile(
          String filePath, webdav.Client webdavClient) async =>
      await webdavClient.writeFromFile(filePath,
          PathManager.getRemoteCoverPath(configFile.diaryName, filePath));

  Future<void> writeLocalConfigFile(String filePath) async {
    File confFile = File(filePath);
    if (!await confFile.exists()) {
      await confFile.create(recursive: true, exclusive: true);
    }
    await confFile.writeAsString(configFile.toJson());
  }

  Future<void> writeWebConfigFile(
          String filePath, webdav.Client webdavClient) async =>
      await webdavClient.write(
          filePath, Uint8List.fromList(configFile.toJson().codeUnits));

  @override
  String toString() =>
      'Diary(configFile: $configFile, contentList: $contentList, isHasCover: $isHasCover)';
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;
import 'package:path/path.dart' as p;

import 'package:thinwrite/common/entity/entity.dart';
import 'package:thinwrite/common/utils/utils.dart';

class DiaryBook {
  ConfigFile configFile;
  List<DiaryContent> contentList;
  bool isHasCover;

  DiaryBook({
    required this.configFile,
    required this.contentList,
    required this.isHasCover,
  });

  Future<void> initLocal(String rootPath) async {
    Directory localDiaryDir = Directory(
        PathManager.getLocalDiaryPathS(rootPath, configFile.diaryName));
    await localDiaryDir.create(recursive: true);
    await writeLocalConfigFile(
        PathManager.getLocalConfigPathS(rootPath, configFile.diaryName));
    if (configFile.coverPath.isNotEmpty) {
      writeLocalCoverFile(
          PathManager.getLocalCoverPathS(
              rootPath, configFile.diaryName, configFile.coverPath),
          await File(configFile.coverPath).readAsBytes());
    }
  }

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
    List<DiaryContent> contentList = [];
    var subDirList = dir.list();
    subDirList.forEach((entity) async {
      if (entity is File) {
        DiaryContent diaryContent =
            DiaryContent.fromJson(await entity.readAsString());
        contentList.add(diaryContent);
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
    await localDiaryDir.create(recursive: true);
    List<webdav.File> fileList =
        await webdavClient.readDir(PathManager.getRemoteDiaryPath(diaryName));
    for (webdav.File file in fileList) {
      if (file.name != null) {
        await webdavClient.read2File(
            file.name!,
            p.join(PathManager.getLocalDiaryPathS(rootPath, diaryName),
                file.name!));
      }
    }
    return await readFromLocal(rootPath, diaryName);
  }

  Future<void> uploadToServer() async {}

  Future<void> writeLocalDiaryFile(
      String localDiaryPath, DiaryContent diaryContent) async {
    File diaryFile = File(localDiaryPath);
    await diaryFile.create(recursive: true, exclusive: true);
    await diaryFile.writeAsString(diaryContent.toJson());
  }

  Future<void> writeWebDiaryFile(
          String filePath, webdav.Client webdavClient) async =>
      await webdavClient.writeFromFile(
          filePath,
          PathManager.getRemoteDiaryPagePath(
              configFile.diaryName, PathManager.getDiaryPageName(filePath)));

  Future<void> writeLocalCoverFile(
      String localCoverPath, List<int> imageData) async {
    File coverFile = File(localCoverPath);
    await coverFile.create(recursive: true, exclusive: true);
    await coverFile.writeAsBytes(imageData);
  }

  Future<void> writeWebCoverFile(
          String filePath, webdav.Client webdavClient) async =>
      await webdavClient.writeFromFile(filePath,
          PathManager.getRemoteCoverPath(configFile.diaryName, filePath));

  Future<void> writeLocalConfigFile(String filePath) async {
    File confFile = File(filePath);
    await confFile.create(recursive: true, exclusive: true);
    await confFile.writeAsString(configFile.toJson());
  }

  Future<void> writeWebConfigFile(
          String filePath, webdav.Client webdavClient) async =>
      await webdavClient.write(
          filePath, Uint8List.fromList(configFile.toJson().codeUnits));

  DiaryBook copyWith({
    ConfigFile? configFile,
    List<DiaryContent>? contentList,
    bool? isHasCover,
  }) {
    return DiaryBook(
      configFile: configFile ?? this.configFile,
      contentList: contentList ?? this.contentList,
      isHasCover: isHasCover ?? this.isHasCover,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'configFile': configFile.toMap(),
      'contentList': contentList.map((x) => x.toMap()).toList(),
      'isHasCover': isHasCover,
    };
  }

  factory DiaryBook.fromMap(Map<String, dynamic> map) {
    return DiaryBook(
      configFile: ConfigFile.fromMap(map['configFile'] as Map<String, dynamic>),
      contentList: List<DiaryContent>.from(
        (map['contentList'] as List<int>).map<DiaryContent>(
          (x) => DiaryContent.fromMap(x as Map<String, dynamic>),
        ),
      ),
      isHasCover: map['isHasCover'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory DiaryBook.fromJson(String source) =>
      DiaryBook.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'Diary(configFile: $configFile, contentList: $contentList, isHasCover: $isHasCover)';

  @override
  bool operator ==(covariant DiaryBook other) {
    if (identical(this, other)) return true;

    return other.configFile == configFile &&
        listEquals(other.contentList, contentList) &&
        other.isHasCover == isHasCover;
  }

  @override
  int get hashCode =>
      configFile.hashCode ^ contentList.hashCode ^ isHasCover.hashCode;
}

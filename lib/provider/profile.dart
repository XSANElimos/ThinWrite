import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:thinwrite/class/config_file.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;
import 'package:path/path.dart' as spath;

const isDebugEnable = false;

const String diaryDir = '/ThinWrite/Diary/';

class ProfileProvider extends ChangeNotifier {
  late bool isEnableWebDav;
  String? webdavServer;
  String? webdavAccount;
  String? webdavPassword;
  webdav.Client? webdavClient;

  final List<ConfigFile> _diaryInfoList = [];
  final Map<String, List<String>> _diaryFileNameList = {};
  Directory? _cachePath;

  webdav.Client linkWebDAV(
      {required String server,
      required String account,
      required String password}) {
    return webdav.newClient(
      server,
      user: account,
      password: password,
      debug: isDebugEnable,
    );
  }

  ProfileProvider(
      {required this.isEnableWebDav,
      this.webdavServer,
      this.webdavAccount,
      this.webdavPassword}) {
    if (isEnableWebDav) {
      webdavClient = linkWebDAV(
          server: webdavServer!,
          account: webdavAccount!,
          password: webdavPassword!);
    }
  }

  void enableWebDAV() async {
    if (webdavClient != null) {
      isEnableWebDav = true;
      updateDiaryInfoList();
    } else {
      throw Exception('webdavClient not ready');
    }
  }

  Uint8List string2Uint8List(String data) => const Utf8Encoder().convert(data);

  String uint8List2String(Uint8List data) => const Utf8Decoder().convert(data);

  Future<bool> changeServerProfile(
      {required String server,
      required String account,
      required String password}) async {
    final webdav.Client? cliBak = webdavClient;
    bool isNeedInit = true;
    webdavClient =
        linkWebDAV(server: server, account: account, password: password);
    try {
      await webdavClient!.ping();
    } catch (e) {
      webdavClient = cliBak;
      return false;
    }
    if (!isEnableWebDav) {
      enableWebDAV();
      webdavServer = server;
      webdavAccount = account;
      webdavPassword = password;
    }
    List<webdav.File> serverDirList = await webdavClient!.readDir('/');
    for (webdav.File file in serverDirList) {
      if (file.isDir != null || file.name != null) {
        if (file.isDir! && file.name == 'ThinWrite') {
          isNeedInit = false;
        }
      }
    }
    if (isNeedInit) {
      await _initWebDAVStoreDir();
    }
    notifyListeners();
    return true;
  }

  Future<void> _initWebDAVStoreDir() async {
    assert(isEnableWebDav);
    await webdavClient!.mkdir('/ThinWrite');
    await webdavClient!.mkdir('/ThinWrite/Diary');
    await webdavClient!.mkdir('/ThinWrite/Profile');
  }

  factory ProfileProvider.local() => ProfileProvider(isEnableWebDav: false);

  factory ProfileProvider.link(
          {required String server,
          required String account,
          required String password}) =>
      ProfileProvider(
          isEnableWebDav: true,
          webdavServer: server,
          webdavAccount: account,
          webdavPassword: password);

  void _listDir() {
    assert(isEnableWebDav);
    webdavClient!.readDir('/').then((value) {
      for (webdav.File file in value) {
        print(file.name);
      }
    });
  }

  String curDiaryPath(String diaryName) => '$diaryDir$diaryName';
  String curDiaryCoverPath(String diaryName, String ext) =>
      '$diaryDir$diaryName/cover.$ext';
  String curDiaryConfigPath(String diaryName) => '$diaryDir$diaryName/.config';

  String getExtFromPath(String path) => path.split('.').last;
  String getCacheCoverPath(String coverPath) => _cachePath!.path + coverPath;

  List<ConfigFile> get diaryInfoList => _diaryInfoList;

  Future<void> _createWebNewDiary(
      String diaryName, String localImagePath, String description) async {
    assert(isEnableWebDav);
    ConfigFile configfile = ConfigFile(
        diaryName: diaryName,
        coverPath: curDiaryCoverPath(diaryName, getExtFromPath(localImagePath)),
        description: description);
    await webdavClient!.mkdir(curDiaryPath(diaryName));
    await webdavClient!.writeFromFile(localImagePath,
        curDiaryCoverPath(diaryName, getExtFromPath(localImagePath)));
    await webdavClient!.write(
        curDiaryConfigPath(diaryName), string2Uint8List(configfile.toData()));
    _diaryInfoList.add(configfile);
    notifyListeners();
  }

  Future<void> _removeWebDiary(String diaryName) async {
    assert(isEnableWebDav);
    await webdavClient!
        .rename('$diaryDir$diaryName', '$diaryDir<$diaryName', true);
  }

  Future<void> _deleteWebDiary(String diaryName) async {
    assert(isEnableWebDav);
    await webdavClient!.remove('$diaryDir<$diaryName');
  }

  Future<void> _updateWebDiaryName(
      String diaryName, String diaryNewName) async {
    assert(isEnableWebDav);
    await webdavClient!
        .rename('$diaryDir$diaryName', '$diaryDir$diaryNewName', false);
  }

  Future<void> _updateWebDiaryCover(
      String diaryName, String newCoverPath) async {
    assert(isEnableWebDav);
    final String oldPath =
        await _getWebConfigFileItemValue(diaryName, ConfigItem.coverPath);
    await webdavClient!.remove(oldPath);
    await _updateWebConfigFile(diaryName, ConfigItem.coverPath,
        curDiaryCoverPath(diaryName, getExtFromPath(newCoverPath)));
  }

  Future<ConfigFile> getConfigFile(String diaryName) async {
    return ConfigFile.fromData(uint8List2String(Uint8List.fromList(
        await webdavClient!.read(curDiaryConfigPath(diaryName)))));
  }

  Future<String> _getWebConfigFileItemValue(
      String diaryName, ConfigItem item) async {
    ConfigFile configfile = await getConfigFile(diaryName);
    return configfile.getArgv(item);
  }

  Future<void> _updateWebConfigFile(
      String diaryName, ConfigItem item, String newValue) async {
    assert(isEnableWebDav);
    late ConfigFile configfile;
    webdavClient!.read(curDiaryConfigPath(diaryName)).then((value) {
      configfile = ConfigFile.fromData(String.fromCharCodes(value));
    });
    configfile.setArgv(item, newValue);
    await webdavClient!.remove(curDiaryConfigPath(diaryName));
    Uint8List data = Uint8List.fromList(configfile.toData().codeUnits);
    await webdavClient!.write(curDiaryConfigPath(diaryName), data);
  }

  Future<void> createNewDiary(
      String diaryName, String localImagePath, String description) {
    return _createWebNewDiary(diaryName, localImagePath, description);
  }

  Future<void> downloadCover(String diaryName, String localCoverPath) async {
    return _saveWebCover2Cache(
        curDiaryCoverPath(diaryName, getExtFromPath(localCoverPath)));
  }

  Future<void> saveCoverCache(String diaryName, String localCoverPath) async {
    File localCover = File(localCoverPath);
    File newCoverFile = File(getCacheCoverPath(
        curDiaryCoverPath(diaryName, getExtFromPath(localCoverPath))));
    await newCoverFile.create(recursive: true);
    await localCover.copy(getCacheCoverPath(
        curDiaryCoverPath(diaryName, getExtFromPath(localCoverPath))));
  }

  Future<void> _saveWebCover2Cache(String webCoverPath) async {
    assert(isEnableWebDav);
    if (await File(getCacheCoverPath(webCoverPath)).exists() == false) {
      await webdavClient!
          .read2File(webCoverPath, getCacheCoverPath(webCoverPath));
    }
  }

  List<String>? getDiaryFileNameList(String diaryName) =>
      _diaryFileNameList[diaryName];

  Future<void> _getWebDiaryInfoList() async {
    assert(isEnableWebDav);
    _diaryInfoList.clear();
    getApplicationDocumentsDirectory().then((value) => _cachePath = value);
    List<webdav.File> fileList = await webdavClient!.readDir(diaryDir);
    for (webdav.File file in fileList) {
      ConfigFile conf = await getConfigFile(file.name!);
      await _saveWebCover2Cache(conf.coverPath);
      _diaryInfoList.add(conf);
    }
  }

  Future<void> updateDiaryInfoList() async {
    await _updateWebDiaryInfoList();
    notifyListeners();
  }

  Future<void> _updateWebDiaryInfoList() async {
    assert(isEnableWebDav);
    return _getWebDiaryInfoList();
  }
}

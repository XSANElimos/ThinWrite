import 'dart:async';

import 'package:flutter/material.dart';
import 'package:thinwrite/common/entity/entity.dart';
import 'package:thinwrite/common/utils/path_manager.dart';
import 'package:thinwrite/common/values/values.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

const bool isDebugEnable = false;

class ProfileProvider extends ChangeNotifier {
  late LocalStorage localStorage;
  late DiaryManager diaryManager;
  late List<webdav.File> serverDirList;
  webdav.Client? webdavClient;

  Future<T?> updateHandleAsync<T>(
      {required Function handle,
      List<dynamic>? positionalArguments,
      Map<Symbol, dynamic>? namedArguments}) async {
    T? ret;

    ret = await Function.apply(handle, positionalArguments, namedArguments);

    notifyListeners();
    return ret;
  }

  T? updateHandle<T>(
      {required Function handle,
      List<dynamic>? positionalArguments,
      Map<Symbol, dynamic>? namedArguments}) {
    T? ret;
    ret = Function.apply(handle, positionalArguments, namedArguments);
    notifyListeners();
    return ret;
  }

  Map<String, ConfigFile> get diaryInfoList => diaryManager.configList;

  Future<DiaryBook> loadDiaryBookData(String diaryName) async {
    DiaryBook ret = await diaryManager.loadLocalDiary(diaryName);
    if (ret.isEmpty && localStorage.isEnableWebDav && webdavClient != null) {
      ret = await diaryManager.loadWebDiary(diaryName, webdavClient!);
    }
    return ret;
  }

  Future<Map<String, ConfigFile>> loadShelfData() async {
    Map<String, ConfigFile> ret = {};
    ret = await diaryManager.loadLocalConfigList();
    if (ret.isEmpty && webdavClient != null) {
      try {
        ret = await diaryManager.loadWebConfigList(webdavClient!);
      } catch (e) {}
    }
    diaryManager.configList = ret;
    notifyListeners();
    return ret;
  }

  Future<void> uploadAllDiary() async {
    assert(webdavClient != null);
    await diaryManager.fullUpload(webdavClient!);
  }

  Future<void> uploadDiary(String diaryName) async {
    assert(webdavClient != null);
    await diaryManager.uploadDiary(diaryName, webdavClient!);
  }

  Future<void> downloadAllDiary() async {
    assert(webdavClient != null);
    await diaryManager.loadWebConfigList(webdavClient!);
  }

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

  ProfileProvider() {
    localStorage = LocalStorage();
    diaryManager = DiaryManager();
  }

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
    if (!localStorage.isEnableWebDav) {
      localStorage.updateWebDav(
          server: server, account: account, password: password);
    }
    serverDirList = await webdavClient!.readDir(PathManager.remoteRootPath);
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
    await webdavClient!.mkdir('/ThinWrite');
    await webdavClient!.mkdir('/ThinWrite/Diary');
    await webdavClient!.mkdir('/ThinWrite/Profile');
  }

  factory ProfileProvider.tryLink() {
    ProfileProvider p = ProfileProvider();
    p.changeServerProfile(
        server: p.localStorage.webDavServer,
        account: p.localStorage.webDavAccount,
        password: p.localStorage.webDavPassword);
    return p;
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:thinwrite/common/entity/entity.dart';
import 'package:thinwrite/common/values/values.dart';
import 'package:webdav_client/webdav_client.dart' as webdav;

const bool isDebugEnable = false;

class ProfileProvider extends ChangeNotifier {
  late LocalStorage localStorage;
  late DiaryManager diaryManager;
  late List<webdav.File> serverDirList;
  webdav.Client? webdavClient;

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
    serverDirList = await webdavClient!.readDir('/');
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
    p.linkWebDAV(
        server: p.localStorage.webDavServer,
        account: p.localStorage.webDavAccount,
        password: p.localStorage.webDavPassword);
    return p;
  }
}

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

enum LocalData {
  isNeedInit,
  isEnableWebDav,
  webDavServer,
  webDavAccount,
  webDavPassword,
}

class LocalStorage extends ChangeNotifier {
  final _localStorage = GetStorage();

  Future<void> _writeIfNull(LocalData localData, dynamic value) {
    return _localStorage.writeIfNull(localData.toString(), value);
  }

  T _read<T>(LocalData localData) {
    return _localStorage.read(localData.toString())!;
  }

  Future<void> _write(LocalData localData, dynamic value) async =>
      await _localStorage.write(localData.toString(), value);

  LocalStorage() {
    _writeIfNull(LocalData.isNeedInit, false);
    _writeIfNull(LocalData.isEnableWebDav, false);
    if (_read<bool>(LocalData.isNeedInit)) {
      initLocalStorage();
    }
  }

  void initLocalStorage() async {
    await _write(LocalData.isNeedInit, false);
    await _write(LocalData.isEnableWebDav, false);
  }

  void updateWebDav({String? server, String? account, String? password}) {
    if (server == null || account == null || password == null) {
      _write(LocalData.isEnableWebDav, false);
    } else {
      _write(LocalData.webDavServer, server);
      _write(LocalData.webDavAccount, account);
      _write(LocalData.webDavPassword, password);
      _write(LocalData.isEnableWebDav, true);
    }
  }

  bool get isEnableWebDav => _read(LocalData.isEnableWebDav);

  String get webDavServer {
    assert(isEnableWebDav);
    return _read(LocalData.webDavServer);
  }

  String get webDavAccount {
    assert(isEnableWebDav);
    return _read(LocalData.webDavAccount);
  }

  String get webDavPassword {
    assert(isEnableWebDav);
    return _read(LocalData.webDavPassword);
  }
}

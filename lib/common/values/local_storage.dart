import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

enum CacheType {
  isNeedInit,
  isEnableWebDav,
  isWebDavReady,
  webDavServer,
  webDavAccount,
  webDavPassword,
}

class LocalStorage with ChangeNotifier {
  final _localStorage = GetStorage();
  final Map<CacheType, dynamic> _needChangeMap = {};
  final Map<CacheType, dynamic> _dataList = {};

  bool get isEnableWebDav => _dataList[CacheType.isEnableWebDav] ?? false;

  bool get isWebDavReady => _dataList[CacheType.isWebDavReady] ?? false;

  String get webDavServer => _dataList[CacheType.webDavServer] ?? '';

  String get webDavAccount => _dataList[CacheType.webDavAccount] ?? '';

  String get webDavPassword => _dataList[CacheType.webDavPassword] ?? '';

  LocalStorage() {
    _writeIfNull(CacheType.isNeedInit, true);
    _writeIfNull(CacheType.isEnableWebDav, false);
    _writeIfNull(CacheType.isWebDavReady, false);
    _writeIfNull(CacheType.webDavServer, '');
    _writeIfNull(CacheType.webDavAccount, '');
    _writeIfNull(CacheType.webDavPassword, '');
    if (_read<bool>(CacheType.isNeedInit)) {
      _initLocalStorage();
    } else {
      _loadLocalStorage();
    }
  }

  void updateWebDav({String? server, String? account, String? password}) {
    if (server == null || account == null || password == null) {
      if (isEnableWebDav == false && isWebDavReady == true) {
        _updateValue(CacheType.isEnableWebDav, true);
      } else {
        _updateValue(CacheType.isEnableWebDav, false);
      }
    } else {
      _updateValue(CacheType.webDavServer, server);
      _updateValue(CacheType.webDavAccount, account);
      _updateValue(CacheType.webDavPassword, password);
      _updateValue(CacheType.isWebDavReady, true);
      _updateValue(CacheType.isEnableWebDav, true);
      saveLocalStorage();
    }
  }

  void _initLocalStorage() async {
    await _write(CacheType.isNeedInit, false);
    await _write(CacheType.isEnableWebDav, false);
  }

  void _loadLocalStorage() {
    for (var cacheType in CacheType.values) {
      _dataList[cacheType] = _read(cacheType);
    }
  }

  Future<void> saveLocalStorage() async {
    _needChangeMap.forEach((dataType, value) async {
      await _write(dataType, value);
    });
  }

  void _updateValue(CacheType localDataType, dynamic value) {
    assert(value != null);
    _dataList[localDataType] = value;
    _needChangeMap[localDataType] = value;
  }

  Future<void> _writeIfNull(CacheType localData, dynamic value) {
    return _localStorage.writeIfNull(localData.toString(), value);
  }

  T _read<T>(CacheType localData) {
    return _localStorage.read(localData.toString())!;
  }

  Future<void> _write(CacheType localData, dynamic value) async =>
      await _localStorage.write(localData.toString(), value);
}

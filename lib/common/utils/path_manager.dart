import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PathManager {
  late String _localPath;
  static const String _remotePath = '/';

  PathManager() {
    init();
  }

  Future<void> init() async {
    _localPath = (await getApplicationDocumentsDirectory()).path;
  }

  String get localRootPath => _localPath;

  static final String diaryDir = p.join('ThinWrite', 'Diary');

  static final String profileDir = p.join('ThinWrite', 'Profile');

  static String _getDiaryPath(String diaryName) => p.join(diaryDir, diaryName);

  String get getLocalProfilePath => p.join(_localPath, profileDir);

  static String get getRemoteProfilePath => '/ThinWrite/Profile';

  static String getRemoteDiaryPath(String diaryName) =>
      '/ThinWrite/Diary/$diaryName';

  static String _getCoverPath(String diaryName, String ext) =>
      p.joinAll([profileDir, '$diaryName$ext']);

  static String _getConfigPath(String diaryName) =>
      p.joinAll([...p.split(profileDir), '$diaryName.config']);

  static String getRemoteConfigPath(String diaryName) =>
      '$getRemoteProfilePath/$diaryName.config';

  static String getExt(String path) => p.extension(path);

  String getLocalCoverPath(String diaryName, String coverPath) =>
      p.join(_localPath, _getCoverPath(diaryName, getExt(coverPath)));

  static String getLocalCoverPathS(
          String localPath, String diaryName, String coverPath) =>
      p.join(localPath, _getCoverPath(diaryName, getExt(coverPath)));

  static String getRemoteCoverPath(String diaryName, String coverPath) =>
      '$getRemoteProfilePath/$diaryName${getExt(coverPath)}';

  String getLocalConfigPath(String diaryName) =>
      p.join(_localPath, _getConfigPath(diaryName));

  static String getLocalConfigPathS(String localPath, String diaryName) =>
      p.join(localPath, _getConfigPath(diaryName));

  static String getLocalDiaryPathS(String localPath, String diaryName) =>
      p.join(localPath, _getDiaryPath(diaryName));

  static String getDiaryPageName(String filePath) => p.basename(filePath);

  static String getRemoteDiaryPagePath(String diaryName, String pageName) =>
      "${getRemoteDiaryPath(diaryName)}/$pageName";

  static String getLocalProfilePathS(String localPath) =>
      p.join(localPath, profileDir);

  static String get remoteRootPath => _remotePath;

  static String newDiaryPagePathS(
          String localPath, String diaryName, DateTime date) =>
      p.join(getLocalDiaryPathS(localPath, diaryName),
          '${date.year}${date.month}${date.day}');
}

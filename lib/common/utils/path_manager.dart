import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PathManager {
  late String _localPath;
  static const String _remotePath = '/';

  Future<void> init() async {
    _localPath = (await getApplicationDocumentsDirectory()).path;
  }

  String get localRootPath => _localPath;

  static final String diaryDir = p.join('ThinWrite', 'Diary');

  static String _getDiaryPath(String diaryName) => p.join(diaryDir, diaryName);

  static String _getCoverPath(String diaryName, String ext) =>
      p.joinAll([...p.split(_getDiaryPath(diaryName)), 'cover.$ext']);

  static String _getConfigPath(String diaryName) =>
      p.joinAll([...p.split(_getDiaryPath(diaryName)), '.config']);

  static String getExt(String path) => p.extension(path);

  String getLocalCoverPath(String diaryName, String coverPath) =>
      _localPath + _getCoverPath(diaryName, getExt(coverPath));

  static String getLocalCoverPathS(
          String localPath, String diaryName, String coverPath) =>
      localPath + _getCoverPath(diaryName, getExt(coverPath));

  static String getRemoteCoverPath(String diaryName, String coverPath) =>
      _remotePath + _getCoverPath(diaryName, getExt(coverPath));

  String getLocalConfigPath(String diaryName) =>
      _localPath + _getConfigPath(diaryName);

  static String getLocalConfigPathS(String localPath, String diaryName) =>
      localPath + _getConfigPath(diaryName);

  static String getRemoteConfigPath(String diaryName) =>
      _remotePath + _getConfigPath(diaryName);

  static String getLocalDiaryPathS(String localPath, String diaryName) =>
      localPath + _getDiaryPath(diaryName);

  static String getDiaryPageName(String filePath) => p.basename(filePath);

  static String getRemoteDiaryPagePath(String diaryName, String pageName) =>
      "$_remotePath${_getDiaryPath(diaryName)}/$pageName";

  static String getRemoteDiaryPath(String diaryName) =>
      _getDiaryPath(diaryName);
}

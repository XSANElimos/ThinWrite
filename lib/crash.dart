/// writer
///
///
///
// String header = '';
// String content = '';

// String datetimeToString(DateTime time) {
//   String ret = "${time.year}年${time.month}月${time.day}日";
//   return ret;
// }

// String markdownHeaderCreater(DateTime time, Weather weather, String mood) {
//   String strTime = datetimeToString(time);
//   String ret = '''
//   # $strTime ${weather.toChinese()}
//   ### $mood

//   ---

//   ''';

//   return ret;
// }

///     floatingActionButton: ControlStick(
//   pageController: pageCtrler,
//   controlStickController: csCtrler,
// ),
// floatingActionButtonAnimator: ScalingAnimation(),
// floatingActionButtonLocation: CustomFloatingActionButtonLocation(
//     FloatingActionButtonLocation.endFloat, csCtrler.offset),

// class ScalingAnimation extends FloatingActionButtonAnimator {
//   @override
//   Offset getOffset(
//           {required Offset begin,
//           required Offset end,
//           required double progress}) =>
//       end;

//   @override
//   Animation<double> getRotationAnimation({required Animation<double> parent}) {
//     return Tween<double>(begin: 1.0, end: 1.0).animate(parent);
//   }

//   @override
//   Animation<double> getScaleAnimation({required Animation<double> parent}) {
//     return Tween<double>(begin: 1.0, end: 1.0).animate(parent);
//   }
// }

// class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
//   FloatingActionButtonLocation location;
//   Offset baseOffset;
//   CustomFloatingActionButtonLocation(this.location, this.baseOffset);

//   @override
//   Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
//     Offset offset = location.getOffset(scaffoldGeometry);
//     return Offset(offset.dx + baseOffset.dx, offset.dy + baseOffset.dy);
//   }
// }

/// class ControlStickController with ChangeNotifier {
//   late Offset _offset;
//   final originOffset = const Offset(0, 0);
//   Offset get offset => _offset;

//   ControlStickController({Offset? offset}) {
//     _offset = offset ?? originOffset;
//   }
//   void updateOffset(Offset offset) {
//     _offset = offset;
//     notifyListeners();
//   }

//   void resetOffset() {
//     _offset = originOffset;
//     notifyListeners();
//   }
// }

// class ControlStick extends StatefulWidget {
//   const ControlStick(
//       {super.key,
//       required this.pageController,
//       required this.controlStickController});
//   final PageController pageController;
//   final ControlStickController controlStickController;
//   @override
//   State<ControlStick> createState() => _ControlStickState();
// }

// class _ControlStickState extends State<ControlStick> {
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//         onHorizontalDragEnd: (details) {
//           print('Horizontal:${details.primaryVelocity}');
//           widget.controlStickController.resetOffset();
//         },
//         onVerticalDragEnd: (details) {
//           print('Vertical:${details.primaryVelocity}');
//           widget.controlStickController.resetOffset();
//         },
//         child: IconButton(
//             onPressed: () {
//               widget.pageController.animateToPage(9,
//                   duration: const Duration(milliseconds: 400),
//                   curve: Curves.linear);
//             },
//             icon: const Icon(Icons.edit)));
//   }
// }

// class TabSelector extends StatefulWidget {
//   const TabSelector({Key? key}) : super(key: key);

//   @override
//   TabSelectorState createState() => TabSelectorState();
// }

// class TabSelectorState extends State<TabSelector> {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Stack(
//           children: <Widget>[
//             IgnorePointer(
//               child: Opacity(
//                   opacity: 0.0,
//                   child: Chip(
//                       onDeleted: () {},
//                       avatar: const Icon(Icons.text_format_rounded),
//                       label: const Text('UnderLine'))),
//             ),
//             const SizedBox(width: double.infinity),
//             Positioned.fill(
//               child: ListView(
//                 scrollDirection: Axis.horizontal,
//                 children: <Widget>[
//                   for (int i = 0; i < 5; i++)
//                     InkWell(
//                       onTap: () {},
//                       child: Chip(
//                           onDeleted: () {},
//                           avatar: const Icon(Icons.text_format_rounded),
//                           label: const Text('UnderLine')),
//                     )
//                 ],
//               ),
//             )
//           ],
//         ));
//   }
// }


/// --------------------------------------------
/// 
/// old profile 
/// 
/// 
/// 
///   
/// 
// void _listDir() {
//   assert(isEnableWebDav);
//   webdavClient!.readDir('/').then((value) {
//     for (webdav.File file in value) {
//       print(file.name);
//     }
//   });
// }
//
// Future<void> _createWebNewDiary(
//     String diaryName, String localImagePath, String description) async {
//   assert(isEnableWebDav);
//   ConfigFile configfile = ConfigFile(
//       diaryName: diaryName,
//       coverPath: curDiaryCoverPath(diaryName, getExtFromPath(localImagePath)),
//       description: description);
//   await webdavClient!.mkdir(curDiaryPath(diaryName));
//   await webdavClient!.writeFromFile(localImagePath,
//       curDiaryCoverPath(diaryName, getExtFromPath(localImagePath)));
//   await webdavClient!.write(
//       curDiaryConfigPath(diaryName), string2Uint8List(configfile.toData()));
//   _diaryInfoList.add(configfile);
//   notifyListeners();
// }

// Future<void> _removeWebDiary(String diaryName) async {
//   assert(isEnableWebDav);
//   await webdavClient!
//       .rename('$diaryDir$diaryName', '$diaryDir<$diaryName', true);
// }

// Future<void> _deleteWebDiary(String diaryName) async {
//   assert(isEnableWebDav);
//   await webdavClient!.remove('$diaryDir<$diaryName');
// }

// Future<void> _updateWebDiaryName(
//     String diaryName, String diaryNewName) async {
//   assert(isEnableWebDav);
//   await webdavClient!
//       .rename('$diaryDir$diaryName', '$diaryDir$diaryNewName', false);
// }

// Future<void> _updateWebDiaryCover(
//     String diaryName, String newCoverPath) async {
//   assert(isEnableWebDav);
//   final String oldPath =
//       await _getWebConfigFileItemValue(diaryName, ConfigItem.coverPath);
//   await webdavClient!.remove(oldPath);
//   await _updateWebConfigFile(diaryName, ConfigItem.coverPath,
//       curDiaryCoverPath(diaryName, getExtFromPath(newCoverPath)));
// }

// Future<ConfigFile> getConfigFile(String diaryName) async {
//   return ConfigFile.fromData(uint8List2String(Uint8List.fromList(
//       await webdavClient!.read(curDiaryConfigPath(diaryName)))));
// }

// Future<String> _getWebConfigFileItemValue(
//     String diaryName, ConfigItem item) async {
//   ConfigFile configfile = await getConfigFile(diaryName);
//   return configfile.getArgv(item);
// }

// Future<void> _updateWebConfigFile(
//     String diaryName, ConfigItem item, String newValue) async {
//   assert(isEnableWebDav);
//   late ConfigFile configfile;
//   webdavClient!.read(curDiaryConfigPath(diaryName)).then((value) {
//     configfile = ConfigFile.fromData(String.fromCharCodes(value));
//   });
//   configfile.setArgv(item, newValue);
//   await webdavClient!.remove(curDiaryConfigPath(diaryName));
//   Uint8List data = Uint8List.fromList(configfile.toData().codeUnits);
//   await webdavClient!.write(curDiaryConfigPath(diaryName), data);
// }

// Future<void> createNewDiary(
//     String diaryName, String localImagePath, String description) {
//   return _createWebNewDiary(diaryName, localImagePath, description);
// }

// Future<void> downloadCover(String diaryName, String localCoverPath) async {
//   return _saveWebCover2Cache(
//       curDiaryCoverPath(diaryName, getExtFromPath(localCoverPath)));
// }

// Future<void> saveCoverCache(String diaryName, String localCoverPath) async {
//   File localCover = File(localCoverPath);
//   File newCoverFile = File(getCacheCoverPath(
//       curDiaryCoverPath(diaryName, getExtFromPath(localCoverPath))));
//   await newCoverFile.create(recursive: true);
//   await localCover.copy(getCacheCoverPath(
//       curDiaryCoverPath(diaryName, getExtFromPath(localCoverPath))));
// }

// Future<void> _saveWebCover2Cache(String webCoverPath) async {
//   assert(isEnableWebDav);
//   if (await File(getCacheCoverPath(webCoverPath)).exists() == false) {
//     await webdavClient!
//         .read2File(webCoverPath, getCacheCoverPath(webCoverPath));
//   }
// }

// List<String>? getDiaryFileNameList(String diaryName) =>
//     _diaryFileNameList[diaryName];

// Future<void> _getWebDiaryInfoList() async {
//   assert(isEnableWebDav);
//   _diaryInfoList.clear();
//   getApplicationDocumentsDirectory().then((value) => _cachePath = value);
//   List<webdav.File> fileList = await webdavClient!.readDir(diaryDir);
//   for (webdav.File file in fileList) {
//     ConfigFile conf = await getConfigFile(file.name!);
//     await _saveWebCover2Cache(conf.coverPath);
//     _diaryInfoList.add(conf);
//   }
// }
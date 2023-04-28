import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:thinwrite/common/entity/entity.dart';
import 'package:thinwrite/common/utils/mood_manager.dart';
import 'package:thinwrite/common/utils/weather_manager.dart';
import 'package:thinwrite/common/values/values.dart';
import 'package:thinwrite/main.dart';

class WriterPage extends StatefulWidget {
  const WriterPage({Key? key, required this.diaryName}) : super(key: key);
  final String diaryName;
  @override
  State<WriterPage> createState() => _WriterPageState();
}

class _WriterPageState extends State<WriterPage> {
  late DateTime curDatetime = DateTime.now();
  late String curDate = timeToString(curDatetime);
  bool isEditMode = false;
  late DiaryManager dm;
  late DiaryBook diaryBook;
  DiaryContent? diaryContent;
  late List<Toc> tocList = [];

  void _switchViewMode() {
    setState(() {
      isEditMode = !isEditMode;
    });
  }

  void switchPage(DiaryContent newContent) {
    _saveContent();
    diaryContent = newContent;
    curDatetime = newContent.targetTime;
    curDate = timeToString(curDatetime);
    tocList = dm.getTocList(widget.diaryName);
  }

  void _saveContent() {
    if (diaryContent != null) dm.saveDiary(widget.diaryName, diaryContent!);
  }

  String timeToString(DateTime time) {
    return '${time.year}${time.month}${time.day}';
  }

  Future<void> switchNewPage({DateTime? date}) async {
    if (date == null) {
      DateTime initDate = DateTime.now();
      DateTime firstDate = initDate.subtract(const Duration(days: 30));
      DateTime lastDate = initDate;

      date = await showDatePicker(
          context: context,
          initialDate: initDate,
          firstDate: firstDate,
          lastDate: lastDate);
    } else {
      date = DateTime.now();
    }

    if (date == null) {
      return;
    } else {
      DiaryContent content = diaryBook.newPage(date);
      switchPage(content);
    }
  }

  List<ListTile> getTileListFromTocList(
      List<Toc> tocList, VoidCallback onSelect) {
    List<ListTile> ret = [];
    ret.add(
        ListTile(title: Center(child: Text(diaryBook.configFile.description))));
    ret.add(ListTile(
        title: const Center(child: Text('新起一篇')),
        onTap: () async {
          await switchNewPage();
          setState(() {
            onSelect();
          });
        }));
    if (tocList.isEmpty) {
      return ret;
    }
    for (Toc toc in tocList) {
      ret.add(ListTile(
          selected: toc.date == curDatetime,
          title: Text('${toc.date.year}年${toc.date.month}月${toc.date.day}日'),
          subtitle: Text(toc.preview),
          onTap: () {
            setState(() {
              switchPage(diaryBook.getContent(toc.date)!);
            });
            onSelect();
          }));
    }

    return ret;
  }

  AppBar _appBarBuilder() => AppBar(
        title: Text(widget.diaryName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ProfileProvider profile = context.read<ProfileProvider>();
            if (profile.localStorage.isEnableWebDav) {
              profile.uploadDiary(widget.diaryName);
            }
            context.pop();
          },
        ),
        actions: [
          IconButton(
            icon: isEditMode
                ? const Icon(Icons.chrome_reader_mode_outlined)
                : const Icon(Icons.edit),
            onPressed: () {
              _saveContent();
              _switchViewMode();
            },
          ),
          Builder(
              builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  ))
        ],
      );

  Drawer _drawerBuilder(List<Toc> tocList, VoidCallback onSelect) {
    List<ListTile> tocTileList = getTileListFromTocList(tocList, onSelect);
    return Drawer(
      child: ListView.builder(
          itemCount: tocTileList.length,
          itemBuilder: (_, index) => tocTileList[index]),
    );
  }

  void onSave() => setState(() {});

  Widget _buildMainView() => Scaffold(
        appBar: _appBarBuilder(),
        endDrawer: Builder(
          builder: (context) => _drawerBuilder(
              tocList, () => Scaffold.of(context).closeEndDrawer()),
        ),
        body: isEditMode
            ? EditModeView(diaryContent: diaryContent!, onSave: onSave)
            : ReadModeView(diaryContent: diaryContent!, onSave: onSave),
      );

  void _initWriter(DiaryBook diaryBook) {
    DiaryContent? tempContent = diaryBook.getContent(curDatetime);
    if (tempContent != null) {
      switchPage(tempContent);
    } else {
      switchNewPage(date: curDatetime);
    }
  }

  @override
  Widget build(BuildContext context) {
    ProfileProvider profile = context.read<ProfileProvider>();
    dm = profile.diaryManager;
    return SafeArea(
        child: FutureBuilder(
            future: profile.loadDiaryBookData(widget.diaryName),
            builder: (context, snapshort) {
              if (!snapshort.hasData) {
                return const Center(
                    child: Card(child: CircularProgressIndicator()));
              } else {
                diaryBook = snapshort.data!;
                _initWriter(diaryBook);
                return _buildMainView();
              }
            }));
  }
}

class ReadModeView extends StatelessWidget {
  const ReadModeView(
      {Key? key, required this.diaryContent, required this.onSave})
      : super(key: key);
  final DiaryContent diaryContent;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HeaderView(diaryContent: diaryContent, onSave: onSave),
        Text(diaryContent.body)
      ],
    );
  }
}

class EditModeView extends StatelessWidget {
  EditModeView({Key? key, required this.diaryContent, required this.onSave})
      : super(key: key);
  final VoidCallback onSave;
  final DiaryContent diaryContent;
  final TextEditingController contentController = TextEditingController();

  onSaveText() {
    diaryContent.body = contentController.text;
    onSave();
  }

  @override
  Widget build(BuildContext context) {
    contentController.text = diaryContent.body;
    return TextField(
      controller: contentController,
      expands: true,
      onTapOutside: (event) => onSaveText(),
      onEditingComplete: () => onSaveText(),
      maxLines: null,
    );
  }
}

class HeaderView extends StatefulWidget {
  const HeaderView({Key? key, required this.diaryContent, required this.onSave})
      : super(key: key);
  final DiaryContent diaryContent;
  final VoidCallback onSave;

  @override
  State<HeaderView> createState() => _HeaderViewState();
}

class _HeaderViewState extends State<HeaderView> {
  bool isEditMode = false;
  TextEditingController oneWordController = TextEditingController(text: '');
  List<DropdownMenuEntry> weatherDropdownList = [];
  List<DropdownMenuEntry> moodDropdownList = [];
  onSaveText() {
    widget.diaryContent.oneSentenceSummary = oneWordController.text;
    widget.onSave();
  }

  void _switchEditMode() => setState(() {
        isEditMode = !isEditMode;
        onSaveText();
      });

  @override
  void initState() {
    weatherDropdownList = WeatherManager.weatherEntryList;
    moodDropdownList = MoodManager.moodEntryList;
    oneWordController.text = widget.diaryContent.oneSentenceSummary;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.all(8),
        child: InkWell(
            onLongPress: () => _switchEditMode(),
            child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: isEditMode
                    ? Row(
                        children: [
                          Expanded(
                            child: TextField(
                              maxLines: 3,
                              decoration: const InputDecoration(
                                  label: Text('为这天的自己做个总结'),
                                  border: OutlineInputBorder()),
                              controller: oneWordController,
                              onTapOutside: (_) => onSaveText(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              DropdownMenu(
                                  label: const Text('天气'),
                                  initialSelection: widget.diaryContent.weather,
                                  onSelected: (value) =>
                                      widget.diaryContent.weather = value,
                                  inputDecorationTheme:
                                      const InputDecorationTheme(
                                          isDense: true,
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(50)))),
                                  dropdownMenuEntries: weatherDropdownList),
                              const SizedBox(
                                height: 15,
                              ),
                              DropdownMenu(
                                  label: const Text('心情'),
                                  initialSelection: widget.diaryContent.mood,
                                  onSelected: (value) {
                                    widget.diaryContent.mood = value;
                                  },
                                  inputDecorationTheme:
                                      const InputDecorationTheme(
                                          isDense: true,
                                          border: OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(50)))),
                                  dropdownMenuEntries: moodDropdownList),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(widget.diaryContent.getHeaderTime),
                              Text(widget.diaryContent.weather.toChinese()),
                              Text(widget.diaryContent.mood.name),
                            ],
                          ),
                          Text(widget.diaryContent.oneSentenceSummary),
                        ],
                      ))));
  }
}

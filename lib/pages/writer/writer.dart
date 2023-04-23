import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:thinwrite/common/values/values.dart';

class WriterPage extends StatefulWidget {
  const WriterPage({Key? key, required this.diaryName}) : super(key: key);
  final String diaryName;
  @override
  State<WriterPage> createState() => _WriterPageState();
}

class _WriterPageState extends State<WriterPage> {
  final DateTime curDatetime = DateTime.now();
  late String curDate =
      '${curDatetime.year}.${curDatetime.month}.${curDatetime.day}';
  bool isEditMode = false;

  void _switchViewMode() {
    setState(() {
      isEditMode = !isEditMode;
    });
  }

  List<ListTile> getTocFromNameList(List<String>? nameList) {
    List<ListTile> ret = [];
    if (nameList == null) {
      return ret;
    }
    for (var fileName in nameList) {
      ret.add(ListTile(
        title: Text(fileName),
        onTap: () {
          setState(() {
            curDate = fileName;
          });
        },
      ));
    }
    return ret;
  }

  AppBar _appBarBuilder() => AppBar(
        title: Text(widget.diaryName),
        actions: [
          IconButton(
            icon: isEditMode
                ? const Icon(Icons.chrome_reader_mode_outlined)
                : const Icon(Icons.edit),
            onPressed: () => _switchViewMode(),
          ),
          Builder(
              builder: (context) => IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                  ))
        ],
      );

  Drawer _drawerBuilder(ProfileProvider profile) => Drawer(
        child: ListView.builder(
            itemCount: getTocFromNameList(
                    profile.getDiaryFileNameList(widget.diaryName))
                .length,
            itemBuilder: (_, index) => getTocFromNameList(
                profile.getDiaryFileNameList(widget.diaryName))[index]),
      );

  @override
  Widget build(BuildContext context) {
    ProfileProvider profile = context.read<ProfileProvider>();

    return SafeArea(
        child: Scaffold(
      appBar: _appBarBuilder(),
      endDrawer: _drawerBuilder(profile),
      body:
          isEditMode ? const EditModeView() : Markdown(data: header + content),
    ));
  }
}

class EditModeView extends StatelessWidget {
  const EditModeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController contentController =
        TextEditingController(text: content);
    return TextField(
      controller: contentController,
      expands: true,
      onTapOutside: (event) {
        content = contentController.text;
      },
      onEditingComplete: () {
        content = contentController.text;
      },
      maxLines: null,
    );
  }
}

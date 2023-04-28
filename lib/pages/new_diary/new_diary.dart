import 'package:expandable/expandable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:thinwrite/common/entity/diary_manager.dart';
import 'package:thinwrite/common/entity/entity.dart';
import 'package:thinwrite/common/values/profile.dart';
import 'package:thinwrite/pages/new_diary/item_widgets.dart';

class PageNewDiary extends StatefulWidget {
  const PageNewDiary({Key? key}) : super(key: key);

  @override
  _PageNewDiaryState createState() => _PageNewDiaryState();
}

class _PageNewDiaryState extends State<PageNewDiary> {
  TextEditingController diaryNameController =
      TextEditingController(text: '新建日记本');
  TextEditingController diaryDescController =
      TextEditingController(text: '介绍一下吧');
  ExpandableController themeController = ExpandableController();
  String? imageFilePath;
  String? bgFilePath;

  /// 1 imageFile 0 bgFile
  void _loadCover(bool imageType) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        if (imageType) {
          imageFilePath = result.files.single.path;
        } else {
          bgFilePath = result.files.single.path;
        }
      });
    }
  }

  void _cancelCover(bool imageType) {
    setState(() {
      imageType ? imageFilePath = null : bgFilePath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    ProfileProvider profile = context.watch<ProfileProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加新日记'),
        actions: [
          TextButton.icon(
            onPressed: () async {
              showToastWidget(const SavingDlg(),
                  duration: const Duration(minutes: 1));
              if (diaryNameController.text.isNotEmpty) {
                profile.updateHandleAsync<bool>(
                  handle: profile.diaryManager.createNewDiaryBook,
                  namedArguments: {
                    #diaryName: diaryNameController.text,
                    #description: diaryDescController.text,
                    #coverPath: imageFilePath
                  },
                ).then((result) {
                  dismissAllToast();
                  if (result != null && result) {
                    showToast('保存成功');
                  } else {
                    showToast('保存失败，可能已有同名日记本');
                  }
                  context.pop();
                });
              }
            },
            label: const Text('提交'),
            icon: const Icon(Icons.check),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.all(8),
            child: Card(
                child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: <Widget>[
                  TextField(
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      hintText: '请输入新的日记本的名称',
                      label: Text('日记本名'),
                    ),
                    controller: diaryNameController,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 5),
                  TextField(
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      label: Text('日记本描述'),
                      hintText: '输入描述',
                    ),
                    controller: diaryDescController,
                    minLines: 3,
                    maxLines: 3,
                  ),
                ],
              ),
            )),
          ),
          Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.all(8),
              child: Card(
                child: ExpandablePanel(
                  header: const ListTile(
                    title: Text('个性化选项'),
                  ),
                  controller: themeController,
                  collapsed: Container(),
                  expanded: Row(
                    children: <Widget>[
                      Expanded(
                          child: ImageSelector(
                        label: '添加封面',
                        cover: imageFilePath,
                        onTap: () => _loadCover(true),
                        onCancel: () => _cancelCover(true),
                      )),
                      Expanded(
                          child: ImageSelector(
                        label: '添加背景图',
                        cover: bgFilePath,
                        onTap: () => _loadCover(false),
                        onCancel: () => _cancelCover(false),
                      )),
                    ],
                  ),
                ),
              ))
        ],
      ),
    );
  }
}

class SavingDlg extends StatelessWidget {
  const SavingDlg({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(vertical: 20.0, horizontal: 100.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              CircularProgressIndicator(),
              Text('保存中...')
            ],
          ),
        ),
      ),
    );
  }
}

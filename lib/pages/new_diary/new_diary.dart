import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:go_router/go_router.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:thinwrite/common/values/profile.dart';

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
  String? imageFilePath;

  void _loadCover() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        imageFilePath = result.files.single.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ProfileProvider profile = context.watch<ProfileProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('添加新日记'),
        actions: [
          GFButton(
            onPressed: () async {
              showToastWidget(const SavingDlg(),
                  duration: const Duration(minutes: 1));
              if (diaryNameController.text.isNotEmpty) {
                profile.diaryManager
                    .createNewDiaryBook(
                        diaryName: diaryNameController.text,
                        description: diaryDescController.text,
                        coverPath: imageFilePath)
                    .then((result) {
                  dismissAllToast();
                  if (result) {
                    showToast('保存成功');
                  } else {
                    showToast('保存失败，可能已有同名日记本');
                  }
                  context.pop();
                });
              }
            },
            text: '提交',
            icon: const Icon(Icons.check),
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                constraints:
                    const BoxConstraints(maxHeight: 150, maxWidth: 150),
                child: TextButton(
                  onPressed: () => _loadCover(),
                  child: imageFilePath == null
                      ? const Text('添加封面')
                      : Image.file(
                          File(imageFilePath!),
                        ),
                ),
              ),
              Expanded(
                child: TextField(
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: '请输入新的日记本的名称',
                    label: Text('日记本名'),
                  ),
                  controller: diaryNameController,
                  maxLines: 1,
                ),
              )
            ],
          ),
          const SizedBox(height: 5),
          TextField(
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
                hintText: '输入描述', border: OutlineInputBorder()),
            controller: diaryDescController,
            minLines: 3,
            maxLines: 3,
          ),
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

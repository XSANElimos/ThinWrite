import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rich_editor/rich_editor.dart';

class WriterPage extends StatelessWidget {
  const WriterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            InkWell(
              onTap: () {},
              child: Chip(
                  onDeleted: () {},
                  avatar: const Icon(Icons.text_format_rounded),
                  label: const Text('UnderLine')),
            )
          ],
        ),
        Expanded(
            child: RichEditor(
          key: GlobalKey(),
          value: 'initial html here',
          editorOptions: RichEditorOptions(
            placeholder: 'Start typing',
            padding: EdgeInsets.symmetric(horizontal: 5.0),
            baseFontFamily: 'sans-serif',
            barPosition: BarPosition.TOP,
          ),
          getImageUrl: (image) {
            String link =
                'https://avatars.githubusercontent.com/u/24323581?v=4';
            String base64 = base64Encode(image.readAsBytesSync());
            String base64String = 'data:image/png;base64, $base64';
            return base64String;
          },
        ))
      ],
    ));
  }
}
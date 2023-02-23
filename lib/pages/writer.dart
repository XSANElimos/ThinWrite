import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rich_editor/rich_editor.dart';

class WriterPage extends StatelessWidget {
  const WriterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ListView(
              scrollDirection: Axis.horizontal,
              prototypeItem: InkWell(
                onTap: () {},
                child: Chip(
                    onDeleted: () {},
                    avatar: const Icon(Icons.text_format_rounded),
                    label: const Text('UnderLine')),
              ),
              children: <Widget>[
                for (int i = 0; i < 5; i++)
                  InkWell(
                    onTap: () {},
                    child: Chip(
                        onDeleted: () {},
                        avatar: const Icon(Icons.text_format_rounded),
                        label: const Text('UnderLine')),
                  )
              ],
            ),
          ),
          Expanded(
              child: RichEditor(
            key: GlobalKey(),
            value: '',
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
      )),
    );
  }
}

import 'dart:io';
import 'dart:math';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

class ShelfItem extends StatefulWidget {
  const ShelfItem({Key? key, required this.title, this.cover})
      : super(key: key);
  final String title;
  final String? cover;

  @override
  ShelfItemState createState() => ShelfItemState();
}

final List<Color> colorList = [
  Colors.deepOrange.shade300,
  Colors.green.shade700,
  Colors.purple.shade50,
];

class ShelfItemState extends State<ShelfItem> {
  Widget errorBuilder(
      BuildContext context, Object object, StackTrace? stackTrace) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Icon(Icons.nearby_error_rounded),
          Text('图片加载失败')
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String? coverPath = widget.cover;
    if (coverPath != null &&
        p.basename(coverPath) == p.basenameWithoutExtension(coverPath)) {
      coverPath = null;
    }
    return Card(
      color: null == coverPath
          ? colorList[Random(DateTime.now().millisecondsSinceEpoch)
              .nextInt(colorList.length)]
          : null,
      margin: const EdgeInsets.all(8),
      child: InkWell(
        onTap: () => context.go('/shelf/writer', extra: widget.title),
        child: null == coverPath
            ? Center(child: Text(widget.title))
            : Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  Image.file(File(coverPath),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          errorBuilder(context, error, stackTrace)),
                  Positioned(
                    bottom: -1.0,
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      style: const TextStyle(backgroundColor: Colors.white70),
                    ),
                  )
                ],
              ),
      ),
    );
  }
}

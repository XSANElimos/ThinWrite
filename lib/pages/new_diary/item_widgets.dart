import 'dart:io';

import 'package:flutter/material.dart';
import 'package:thinwrite/common/values/colors.dart';

class ImageSelector extends StatefulWidget {
  const ImageSelector(
      {Key? key,
      required this.label,
      this.cover,
      required this.onTap,
      required this.onCancel})
      : super(key: key);
  final String label;
  final String? cover;
  final VoidCallback onTap;
  final VoidCallback onCancel;

  @override
  ImageSelectorState createState() => ImageSelectorState();
}

class ImageSelectorState extends State<ImageSelector> {
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AspectRatio(
          aspectRatio: 3 / 4,
          child: InkWell(
            onTap: () => widget.onTap(),
            child: null == widget.cover
                ? Center(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [const Icon(Icons.add), Text(widget.label)],
                  ))
                : Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      Image.file(File(widget.cover!),
                          fit: BoxFit.cover, errorBuilder: errorBuilder),
                      Positioned(
                        bottom: -1.0,
                        child: Opacity(
                          opacity: 0.8,
                          child: Container(
                            color: ThinWriteColor.alertColor,
                            child: IconButton(
                                color: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 120),
                                onPressed: () => widget.onCancel(),
                                icon: const Icon(Icons.cancel_outlined)),
                          ),
                        ),
                      )
                    ],
                  ),
          )),
    );
  }
}

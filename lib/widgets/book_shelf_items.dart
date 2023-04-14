import 'dart:math';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/shelf/writer'),
      child: Card(
        color: null == widget.cover
            ? colorList[Random(DateTime.now().millisecondsSinceEpoch)
                .nextInt(colorList.length)]
            : null,
        margin: const EdgeInsets.all(8),
        child: null == widget.cover
            ? Center(child: Text(widget.title))
            : Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  Image.network(widget.cover!,
                      fit: BoxFit.fill,
                      errorBuilder: (context, error, stackTrace) => Center(
                            child: TextButton.icon(
                                onPressed: () {},
                                onLongPress: () {},
                                icon: const Icon(Icons.nearby_error_rounded),
                                label: const Text('图片加载失败,长按重试')),
                          ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (null == loadingProgress) {
                          return child;
                        } else {
                          return Center(
                            child: CircularProgressIndicator(
                              value:
                                  (null == loadingProgress.expectedTotalBytes)
                                      ? null
                                      : loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!,
                            ),
                          );
                        }
                      }),
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

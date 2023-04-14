enum EnumContentType {
  text,
  icon,
  image,
  time,
}

class Content {
  EnumContentType type;
  String? content;

  Content({required this.type, this.content});

  factory Content.text(String text) {
    return Content(type: EnumContentType.text, content: text);
  }

  factory Content.icon(String iconPath) {
    return Content(type: EnumContentType.icon, content: iconPath);
  }

  factory Content.image(String imagePath) {
    return Content(type: EnumContentType.image, content: imagePath);
  }

  factory Content.time(DateTime time) {
    return Content(type: EnumContentType.time, content: time.toString());
  }
}

class ContentDataNode {
  final Content content;
  List<ContentDataNode> subContentNode = [];

  ContentDataNode(this.content);
}

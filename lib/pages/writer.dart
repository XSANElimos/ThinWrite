import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:thinwrite/class/weather.dart';
import 'package:thinwrite/provider/profile.dart';

String header = '';
String content = '';

String datetimeToString(DateTime time) {
  String ret = "${time.year}年${time.month}月${time.day}日";
  return ret;
}

String markdownHeaderCreater(DateTime time, Weather weather, String mood) {
  String strTime = datetimeToString(time);
  String ret = '''
  # $strTime ${weather.toChinese()}
  ### $mood

  ---

  ''';

  return ret;
}

class WriterPage extends StatefulWidget {
  const WriterPage({Key? key, required this.diaryName}) : super(key: key);
  final String diaryName;
  @override
  State<WriterPage> createState() => _WriterPageState();
}

class _WriterPageState extends State<WriterPage> {
  late PageController pageCtrler;
  late ControlStickController csCtrler;
  final DateTime curDatetime = DateTime.now();
  late String curDate;
  bool isEditMode = false;
  @override
  void initState() {
    curDate = '${curDatetime.year}.${curDatetime.month}.${curDatetime.day}';
    csCtrler = ControlStickController();
    pageCtrler = PageController();
    csCtrler.addListener(() {
      setState(() {
        csCtrler.offset;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    pageCtrler.dispose();
    csCtrler.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    ProfileProvider profile = context.read<ProfileProvider>();

    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
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
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ))
        ],
      ),
      endDrawer: Drawer(
        child: ListView.builder(
            itemCount: getTocFromNameList(
                    profile.getDiaryFileNameList(widget.diaryName))
                .length,
            itemBuilder: (_, index) => getTocFromNameList(
                profile.getDiaryFileNameList(widget.diaryName))[index]),
      ),
      body:
          isEditMode ? const EditModeView() : Markdown(data: header + content),
      // floatingActionButton: ControlStick(
      //   pageController: pageCtrler,
      //   controlStickController: csCtrler,
      // ),
      // floatingActionButtonAnimator: ScalingAnimation(),
      // floatingActionButtonLocation: CustomFloatingActionButtonLocation(
      //     FloatingActionButtonLocation.endFloat, csCtrler.offset),
    ));
  }
}

class ScalingAnimation extends FloatingActionButtonAnimator {
  @override
  Offset getOffset(
          {required Offset begin,
          required Offset end,
          required double progress}) =>
      end;

  @override
  Animation<double> getRotationAnimation({required Animation<double> parent}) {
    return Tween<double>(begin: 1.0, end: 1.0).animate(parent);
  }

  @override
  Animation<double> getScaleAnimation({required Animation<double> parent}) {
    return Tween<double>(begin: 1.0, end: 1.0).animate(parent);
  }
}

class CustomFloatingActionButtonLocation extends FloatingActionButtonLocation {
  FloatingActionButtonLocation location;
  Offset baseOffset;
  CustomFloatingActionButtonLocation(this.location, this.baseOffset);

  @override
  Offset getOffset(ScaffoldPrelayoutGeometry scaffoldGeometry) {
    Offset offset = location.getOffset(scaffoldGeometry);
    return Offset(offset.dx + baseOffset.dx, offset.dy + baseOffset.dy);
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

class ControlStickController with ChangeNotifier {
  late Offset _offset;
  final originOffset = const Offset(0, 0);
  Offset get offset => _offset;

  ControlStickController({Offset? offset}) {
    _offset = offset ?? originOffset;
  }
  void updateOffset(Offset offset) {
    _offset = offset;
    notifyListeners();
  }

  void resetOffset() {
    _offset = originOffset;
    notifyListeners();
  }
}

class ControlStick extends StatefulWidget {
  const ControlStick(
      {super.key,
      required this.pageController,
      required this.controlStickController});
  final PageController pageController;
  final ControlStickController controlStickController;
  @override
  State<ControlStick> createState() => _ControlStickState();
}

class _ControlStickState extends State<ControlStick> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onHorizontalDragEnd: (details) {
          print('Horizontal:${details.primaryVelocity}');
          widget.controlStickController.resetOffset();
        },
        onVerticalDragEnd: (details) {
          print('Vertical:${details.primaryVelocity}');
          widget.controlStickController.resetOffset();
        },
        child: IconButton(
            onPressed: () {
              widget.pageController.animateToPage(9,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.linear);
            },
            icon: const Icon(Icons.edit)));
  }
}

class TabSelector extends StatefulWidget {
  const TabSelector({Key? key}) : super(key: key);

  @override
  TabSelectorState createState() => TabSelectorState();
}

class TabSelectorState extends State<TabSelector> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: <Widget>[
            IgnorePointer(
              child: Opacity(
                  opacity: 0.0,
                  child: Chip(
                      onDeleted: () {},
                      avatar: const Icon(Icons.text_format_rounded),
                      label: const Text('UnderLine'))),
            ),
            const SizedBox(width: double.infinity),
            Positioned.fill(
              child: ListView(
                scrollDirection: Axis.horizontal,
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
            )
          ],
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:thinwrite/common/entity/config_file.dart';
import 'package:thinwrite/common/values/profile.dart';

import 'package:thinwrite/pages/shelf/item_widgets.dart';

class ShelfPage extends StatelessWidget {
  const ShelfPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: const Text('书架'),
              actions: [
                GFButton(
                  onPressed: () => context.go('/shelf/new_diary'),
                  text: '新建',
                  icon: const Icon(Icons.add),
                ),
                GFButton(
                  onPressed: () => context.go('/shelf/setting'),
                  text: '设置',
                  icon: const Icon(Icons.settings),
                )
              ],
            ),
            body: const DiaryShelfBody()));
  }
}

class DiaryShelfBody extends StatefulWidget {
  const DiaryShelfBody({Key? key}) : super(key: key);

  @override
  _DiaryShelfBodyState createState() => _DiaryShelfBodyState();
}

class _DiaryShelfBodyState extends State<DiaryShelfBody> {
  late bool isNeedInit;
  List<ShelfItem> configList2ShelfItemList(ProfileProvider profile) {
    List<ShelfItem> ret = [];
    for (ConfigFile configFile in profile.diaryInfoList) {
      ret.add(ShelfItem(
          title: configFile.diaryName,
          cover: profile.getCacheCoverPath(configFile.coverPath)));
    }
    return ret;
  }

  Future<List<ShelfItem>> getShelfData(ProfileProvider profile) async {
    await profile.updateDiaryInfoList();
    return configList2ShelfItemList(profile);
  }

  Widget contentBuilder(List<ShelfItem> itemList) {
    return GridView.builder(
      itemCount: itemList.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          childAspectRatio: 3 / 4, maxCrossAxisExtent: 150),
      itemBuilder: (context, index) => itemList[index],
    );
  }

  @override
  void initState() {
    isNeedInit = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ProfileProvider profile = context.watch<ProfileProvider>();
    return profile.diaryInfoList.isEmpty && isNeedInit
        ? FutureBuilder(
            future: getShelfData(profile),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                isNeedInit = false;
                return contentBuilder(snapshot.data!);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            })
        : contentBuilder(configList2ShelfItemList(profile));
  }
}

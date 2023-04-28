import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
                OutlinedButton.icon(
                  onPressed: () => context.go('/shelf/new_diary'),
                  label: const Text('新建'),
                  icon: const Icon(Icons.add),
                ),
                TextButton.icon(
                  onPressed: () => context.go('/shelf/setting'),
                  label: const Text('设置'),
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
  static bool isNeedInit = true;
  List<ShelfItem> configList2ShelfItemList(ProfileProvider profile) {
    List<ShelfItem> ret = [];
    profile.diaryInfoList.forEach((diaryName, configFile) {
      ret.add(ShelfItem(
          title: configFile.diaryName,
          cover: profile.diaryManager.getLocalCoverPath(diaryName)));
    });
    return ret;
  }

  Future<List<ShelfItem>> getShelfData(ProfileProvider profile) async {
    await profile.loadShelfData();
    return configList2ShelfItemList(profile);
  }

  Future<void> _onRefresh(ProfileProvider profile) async {
    if (profile.localStorage.isEnableWebDav) {
      await profile.uploadAllDiary();
      await profile.downloadAllDiary();
    }
  }

  Widget contentBuilder(List<ShelfItem> itemList) {
    ProfileProvider profile = context.watch<ProfileProvider>();

    return RefreshIndicator(
        onRefresh: () => _onRefresh(profile),
        semanticsLabel: '正在同步',
        child: itemList.isNotEmpty
            ? GridView.builder(
                itemCount: itemList.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    childAspectRatio: 3 / 4, maxCrossAxisExtent: 150),
                itemBuilder: (context, index) => itemList[index],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Text('再怎么看也没有东西啦>﹏< '),
                    Text('新建一本日记本吧!')
                  ],
                ),
              ));
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

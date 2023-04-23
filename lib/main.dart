import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';

import 'common/values/values.dart';

void main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: MultiProvider(
            providers: [
          ChangeNotifierProvider.value(value: ProfileProvider.tryLink()),
        ],
            child: MaterialApp.router(
              title: 'ThinWrite',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                useMaterial3: true,
                brightness: Brightness.light,
                primarySwatch: Colors.lightBlue,
              ),
              routerConfig: ThinWriteRouter.router,
            )));
  }
}

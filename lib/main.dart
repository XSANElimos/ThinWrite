import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:getwidget/getwidget.dart';
import 'package:go_router/go_router.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:thinwrite/provider/local_storage.dart';
import 'package:thinwrite/pages/new_diary.dart';

import 'package:thinwrite/pages/setting.dart';
import 'package:thinwrite/pages/shelf.dart';
import 'package:thinwrite/provider/profile.dart';

import 'pages/writer.dart';

void main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const MyHomePage(
          title: 'ThinWrite',
        );
      },
    ),
    GoRoute(
        path: '/shelf',
        builder: (BuildContext context, GoRouterState state) {
          return const ShelfPage();
        },
        routes: [
          GoRoute(
            path: 'new_diary',
            builder: (BuildContext context, GoRouterState state) {
              return const PageNewDiary();
            },
          ),
          GoRoute(
            path: 'writer',
            builder: (BuildContext context, GoRouterState state) {
              return const WriterPage();
            },
          ),
          GoRoute(
            path: 'setting',
            builder: (BuildContext context, GoRouterState state) {
              return const SettingPage();
            },
          ),
        ]),
  ],
);

final LocalStorage localStorage = LocalStorage();

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return OKToast(
        child: MultiProvider(
            providers: [
          ChangeNotifierProvider.value(value: localStorage),
          ChangeNotifierProvider.value(
              value: localStorage.isEnableWebDav
                  ? ProfileProvider.link(
                      server: localStorage.webDavServer,
                      account: localStorage.webDavAccount,
                      password: localStorage.webDavPassword)
                  : ProfileProvider.local()),
          // ListenableProvider<ProfileProvider>(
          //     create: (_) => ProfileProvider.local()),
        ],
            child: MaterialApp.router(
              title: 'ThinWrite',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                primarySwatch: Colors.blue,
              ),
              routerConfig: _router,
            )));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return SelectionArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            GFButtonBadge(
              color: Colors.blueAccent,
              text: 'Wirter',
              onPressed: () => context.go('/wirter'),
            ),
            GFButtonBadge(
              color: Colors.redAccent,
              text: 'Shelf',
              onPressed: () => context.go('/shelf'),
            ),
            GFButtonBadge(
              color: Colors.redAccent,
              text: 'Setting',
              onPressed: () => context.go('/setting'),
            ),
          ],
        ),
      ),
    ));
  }
}

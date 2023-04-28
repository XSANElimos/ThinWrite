import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:thinwrite/pages/pages.dart';

class ThinWriteRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/welcome',
    routes: <RouteBase>[
      GoRoute(
        path: '/welcome',
        builder: (BuildContext context, GoRouterState state) {
          return const PageWelcome();
        },
      ),
      GoRoute(
          path: '/shelf',
          builder: (BuildContext context, GoRouterState state) {
            return const ShelfPage();
          },
          routes: <RouteBase>[
            GoRoute(
              path: 'new_diary',
              builder: (BuildContext context, GoRouterState state) {
                return const PageNewDiary();
              },
            ),
            GoRoute(
              path: 'writer',
              builder: (BuildContext context, GoRouterState state) {
                assert(state.extra is String);
                return WriterPage(
                  diaryName: state.extra as String,
                );
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
}

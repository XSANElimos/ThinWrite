import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:go_router/go_router.dart';

class PageWelcome extends StatefulWidget {
  const PageWelcome({Key? key}) : super(key: key);

  @override
  PageWelcomeState createState() => PageWelcomeState();
}

class PageWelcomeState extends State<PageWelcome> {
  Widget _buildPageHeadTitle() {
    return const Text(
      'Features',
      textAlign: TextAlign.center,
      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
    );
  }

  Widget _buildPageHeaderDetail() {
    return const Text('HeaderDetail');
  }

  Widget _buildFeatureItem() {
    return const Text('FeatureItem');
  }

  Widget _buildStartButton() {
    return GFButton(
      onPressed: () => context.go('/shelf'),
      text: '开始',
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            children: <Widget>[
              _buildPageHeadTitle(),
              _buildPageHeaderDetail(),
              _buildFeatureItem(),
              _buildStartButton()
            ],
          ),
        ),
      ),
    );
  }
}

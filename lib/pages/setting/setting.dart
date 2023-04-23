import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:thinwrite/common/values/local_storage.dart';

import 'package:thinwrite/common/values/profile.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late final ExpandableController webDavCardController;
  late final TextEditingController newServerEditController;
  late final TextEditingController newAccountEditController;
  late final TextEditingController newPasswordEditController;
  @override
  void initState() {
    webDavCardController = ExpandableController(initialExpanded: false);
    newServerEditController =
        TextEditingController(text: 'https://dav.jianguoyun.com/dav/');
    newAccountEditController =
        TextEditingController(text: 'elimos@foxmail.com');
    newPasswordEditController = TextEditingController(text: 'a7btpz8n53ayi6z3');
    super.initState();
  }

  @override
  void dispose() {
    webDavCardController.dispose();
    newServerEditController.dispose();
    newAccountEditController.dispose();
    newPasswordEditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ProfileProvider profile = context.watch<ProfileProvider>();
    String wdServer = profile.localStorage.webDavServer;
    String wdAccount = profile.localStorage.webDavAccount;

    return SafeArea(
      child: Scaffold(
          appBar: AppBar(title: const Text('Setting Page')),
          body: ListView(
            children: [
              ExpandablePanel(
                header: ListTile(
                  title: const Text('WebDav Config'),
                  subtitle: Text(wdServer),
                ),
                controller: webDavCardController,
                collapsed: GFCard(
                    title: GFListTile(
                      title: Center(child: Text(wdAccount)),
                    ),
                    buttonBar: GFButtonBar(children: <Widget>[
                      GFButton(onPressed: () {}, text: 'Reset'),
                      GFButton(
                        onPressed: () {},
                        text: 'Enable',
                      )
                    ])),
                expanded: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.all(8),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: newServerEditController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                            label: Center(child: Text('Server Address'))),
                      ),
                      TextField(
                        controller: newAccountEditController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                            label: Center(child: Text('Account'))),
                      ),
                      TextField(
                        controller: newPasswordEditController,
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                            label: Center(child: Text('Password'))),
                      ),
                      ButtonBar(
                        children: [
                          const Spacer(),
                          OutlinedButton(
                            onPressed: () {
                              webDavCardController.toggle();
                            },
                            child: const Text('Cancel'),
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              if (await profile.changeServerProfile(
                                  server: newServerEditController.text,
                                  account: newAccountEditController.text,
                                  password: newPasswordEditController.text)) {
                                showToast('Connect Success!');
                              } else {
                                showToast('Connect Failed!');
                              }
                            },
                            child: const Text('Connect'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              ListTile(
                title: Text('sad'),
              ),
              ListTile(
                title: Text('sad'),
              ),
              ListTile(
                title: Text('sad'),
              ),
            ],
          )),
    );
  }
}

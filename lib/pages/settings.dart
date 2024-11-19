import 'package:aidore/others/group.dart';
import 'package:aidore/others/singleton.dart';
import 'package:aidore/others/tools.dart';
import 'package:aidore/pages/recommendsetting.dart';
import 'package:flutter/material.dart';

//推しグループ
//推しメン
//コンプ下限値

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<Group> _groups = [];
  late List<SettingItem> _settings;
  @override
  void initState() {
    super.initState();
    loadGroup();
    _settings = [
      SettingItem(
          name: '推しグループ',
          value: "未設定",
          options: ["未設定"],
          onChanged: _onGroupChanged),
    ];
  }

  Future<void> loadGroup() async {
    final groups = await GroupRepository().getAll();
    final groupName = SharedPreferencesSingleton().getString("group");
    setState(() {
      _groups = groups;
      _settings = [
        SettingItem(
            name: '推しグループ',
            value: groupName ?? "未設定",
            options: ["未設定"] + groups.map((group) => group.name).toList(),
            onChanged: _onGroupChanged),
      ];
    });
  }

  void _onGroupChanged(dynamic groupName) {
    if (groupName == "未設定") {
      SharedPreferencesSingleton().removeValue("group");
      SharedPreferencesSingleton().removeValue("group_color");
      return;
    } else {
      SharedPreferencesSingleton().setString("group", groupName as String);
      final group = _groups.firstWhere((group) => group.name == groupName);
      SharedPreferencesSingleton().setString("group_color", group.color);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorSchemes.getColorScheme(
        SharedPreferencesSingleton().getString("group_color"));
    return Scaffold(
        // backgroundColor: colorScheme.surface,
        appBar: AppBar(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          title: const Text(
            "設定",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          children: [
            ListView.builder(
              shrinkWrap: true, // ListViewのサイズを内部コンテンツに合わせる
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _settings.length,
              itemBuilder: (context, index) {
                var setting = _settings[index];
                return ListTile(
                  title: Text(setting.name),
                  trailing: DropdownButton(
                    value: setting.value,
                    onChanged: (newValue) {
                      setState(() {
                        setting.value = newValue;
                        setting.onChanged(newValue);
                      });
                    },
                    items: setting.options.map<DropdownMenuItem>((option) {
                      return DropdownMenuItem(
                        value: option,
                        child: Text(option.toString()),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
            const SizedBox(
              height: 8,
            ),
            const Text("推しメン設定"),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: _groups.length,
                itemBuilder: (context, index) {
                  var group = _groups[index];
                  return ListTile(
                    title: Text(group.name),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      // 高度設定ページに移動
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => RecommendSettingPage(
                                  group: group,
                                )),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ));
  }
}

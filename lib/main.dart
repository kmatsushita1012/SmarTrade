import 'dart:convert';
import 'package:aidore/others/group.dart';
import 'package:aidore/others/singleton.dart';
import 'package:aidore/others/tools.dart';
import 'package:aidore/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<void> loadGroup() async {
  String metadataContent =
      await rootBundle.loadString('assets/data/group_list.json');
  var metadata = jsonDecode(metadataContent);
  for (var fileInfo in metadata['files']) {
    String fileName = fileInfo['name'];
    DateTime lastUpdated = DateTime.parse(fileInfo['lastUpdated']);
    Group? group = await GroupRepository().getByFileName(fileName);
    if (group == null) {
      String filePath = 'assets/data/groups/$fileName';
      Group newGroup = await Group.loadJsonFile(filePath,
          {'lastUpdated': lastUpdated.format(), 'fileName': fileName});
      await GroupRepository().insert(newGroup);
      continue;
    }
    if (lastUpdated.isAfter(group.lastUpdated)) {
      String filePath = 'assets/data/groups/$fileName';
      await group
          .updateFromFile(filePath, {'lastUpdated': lastUpdated.format()});
      await GroupRepository().insert(group);
      continue;
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadGroup();
  await SharedPreferencesSingleton.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ホーム',
      theme: ThemeData(
        colorScheme: AppColorSchemes.getColorScheme("gray"),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'ホーム'),
    );
  }
}

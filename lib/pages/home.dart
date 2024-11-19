import 'package:aidore/others/series.dart';
import 'package:aidore/others/singleton.dart';
import 'package:aidore/others/tools.dart';
import 'package:aidore/pages/create.dart';
import 'package:aidore/pages/series.dart';
import 'package:aidore/pages/settings.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Series> _seriesList = [];

  @override
  void initState() {
    super.initState();
    _loadSeries();
  }

  Future<void> _loadSeries() async {
    List<Series> allSeries = await SeriesRepository().getAllSeries();
    setState(() {
      _seriesList = allSeries;
    });
  }

  void _onCreatePressed() async {
    await Navigator.push(
        context, MaterialPageRoute(builder: (context) => const CreatePage()));
    _loadSeries();
  }

  void _onSettingsPressed() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
    setState(() {});
  }

  void _onSeriesPressed(int index) async {
    Series series = _seriesList[index];
    await Navigator.push(context,
        MaterialPageRoute(builder: (context) => SeriesPage(series: series)));
    _loadSeries();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorSchemes.getColorScheme(
        SharedPreferencesSingleton().getString("group_color"));
    return Scaffold(
      appBar: AppBar(
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary,
        title: Text(
          widget.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _onSettingsPressed,
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Visibility(
              visible: _seriesList.isEmpty,
              child: Container(
                  width: 300,
                  height: 100,
                  alignment: Alignment.center,
                  child: Text(
                    "右下の+ボタンから新しいプロジェクト(商品)を追加しましょう",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  )),
            ),
            Expanded(
                child: ListView.builder(
                    itemCount: _seriesList.length,
                    itemBuilder: (context, index) {
                      // リスト内の各アイテムを表示する方法を定義する
                      return ListTile(
                        tileColor: AppColorSchemes.getColorScheme(
                                _seriesList[index].color)
                            .surface,
                        title: Text(
                            '${_seriesList[index].name} ${_seriesList[index].group}'), // アイテムのテキスト表示例
                        onTap: () => _onSeriesPressed(index),
                      );
                    })),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _onCreatePressed();
        },
        backgroundColor: colorScheme.primary,
        heroTag: 'createButton',
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:aidore/others/group.dart';
import 'package:aidore/others/member.dart';
import 'package:aidore/others/series.dart';
import 'package:aidore/others/tools.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

//推しグループ
//推しメン
//コンプ下限値

class RecommendSettingPage extends StatefulWidget {
  final Group group;

  const RecommendSettingPage({super.key, required this.group});

  @override
  // ignore: library_private_types_in_public_api
  _RecommendSettingPageState createState() => _RecommendSettingPageState();
}

class _RecommendSettingPageState extends State<RecommendSettingPage> {
  @override
  void initState() {
    super.initState();
  }

  void _onRecommendChanged(MemberInfo member, bool value) {
    setState(() async {
      member.recommend = value;
      GroupRepository().insert(widget.group);
      if (value) {
        List<Series> seriesList = await SeriesRepository().getAllSeries();
        seriesList.forEach((series) {
          if (series.group == widget.group) {
            MemberData? memberData = series.members.firstWhereOrNull(
                (memberData) => memberData.name == member.name);
            if (memberData != null) memberData.recommend = true;
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorSheme = AppColorSchemes.getColorScheme(widget.group.color);
    return Scaffold(
      appBar: AppBar(
        foregroundColor: colorSheme.onPrimary,
        backgroundColor: colorSheme.primary,
        title: const Text(
          "推しメン",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        itemCount: widget.group.members.length,
        itemBuilder: (context, index) {
          MemberInfo member = widget.group.members[index];
          return ListTile(
              title: Text(member.name),
              trailing: Switch(
                activeTrackColor: colorSheme.primary,
                inactiveTrackColor: colorSheme.surface,
                value: member.recommend,
                onChanged: (value) => _onRecommendChanged(member, value),
              ));
        },
      ),
    );
  }
}

import 'package:aidore/others/constants.dart';
import 'package:aidore/others/group.dart';
import 'package:aidore/others/member.dart';
import 'package:aidore/others/series.dart';
import 'package:aidore/others/singleton.dart';
import 'package:aidore/others/tools.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _formKey = GlobalKey<FormState>();
  Group? _group;
  final TextEditingController _seriesController = TextEditingController();
  PoseList? _poseList;
  int _generation = 0;
  List<Group> _groups = [];

  @override
  void initState() {
    super.initState();
    loadGroup();
  }

  Future<void> loadGroup() async {
    final groups = await GroupRepository().getAll();
    final groupName = SharedPreferencesSingleton().getString("group");
    setState(() {
      _groups = groups;
      if (groupName != null) {
        _group = _groups.firstWhereOrNull((group) => group.name == groupName);
      }
    });
  }

  void _onCreatePressed() async {
    if (_formKey.currentState?.validate() ?? false) {
      List<MemberInfo> members = _group!.members;
      List<MemberData> memberDataList = members
          .where(
              (member) => _generation == 0 || member.generation == _generation)
          .map((member) => MemberData.createFromInfo(
              member, (_poseList ?? PoseList.CD).array))
          .toList();
      var series = Series(
        name: _seriesController.text,
        group: _group!.name,
        color: _group!.color,
        poses: _poseList!.array,
        members: memberDataList,
        capacity: SERIES_INITIAL_CAPACITY,
      );
      await SeriesRepository().insertSeries(series);
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorSchemes.getColorScheme(
        SharedPreferencesSingleton().getString("group_color"));
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          foregroundColor: colorScheme.onPrimary,
          backgroundColor: colorScheme.primary,
          title: const Text(
            "新規作成",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
                width: screenWidth * 0.8,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center, // 左右中央
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                              label: Text(
                            "グループ",
                            style: TextStyle(fontSize: 18),
                          )),
                          value: _group,
                          hint: const Text('選択してください'),
                          items: _groups
                              .map((group) => DropdownMenuItem(
                                    value: group,
                                    child: Text(
                                      group.name,
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _generation = 0;
                              _group = value;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'この項目は必須です'; // エラーメッセージ
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "商品名",
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        TextFormField(
                          controller: _seriesController,
                          // バリデーションの実装ーーーーーーーーーーーーーーーー
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '1文字以上入力してください';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                              label: Text(
                            "ポーズ",
                            style: TextStyle(fontSize: 18),
                          )),
                          hint: const Text('選択してください'),
                          items: PoseList.values
                              .map((poses) => DropdownMenuItem(
                                    value: poses.text,
                                    child: Text(
                                      poses.text,
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) => {
                            _poseList = PoseList.values
                                .firstWhere((poses) => poses.text == value)
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'この項目は必須です'; // エラーメッセージ
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        DropdownButtonFormField(
                          decoration: const InputDecoration(
                              label: Text(
                            "メンバー",
                            style: TextStyle(fontSize: 18),
                          )),
                          value: _generation,
                          hint: const Text('選択してください'),
                          items: (_group == null)
                              ? []
                              : ([0] + _group!.generations)
                                  .map((generation) => DropdownMenuItem(
                                        value: generation,
                                        child: Text(
                                          generation != 0
                                              ? "${generation.toString()}期生"
                                              : "全員",
                                        ),
                                      ))
                                  .toList(),
                          onChanged: (value) => {
                            setState(() {
                              _generation = value as int;
                            })
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'この項目は必須です'; // エラーメッセージ
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: _onCreatePressed,
                            child: Text(
                              '作成',
                              style: TextStyle(color: colorScheme.primary),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ))));
  }
}

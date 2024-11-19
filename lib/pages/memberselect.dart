import 'package:aidore/others/member.dart';
import 'package:aidore/others/series.dart';
import 'package:aidore/others/tools.dart';
import 'package:aidore/pages/poseselect.dart';
import 'package:aidore/pages/registerconf.dart';
import 'package:flutter/material.dart';

class MemberSelectPage extends StatefulWidget {
  final Series series;
  const MemberSelectPage({super.key, required this.series});
  @override
  // ignore: library_private_types_in_public_api
  _MemberSelectPageState createState() => _MemberSelectPageState();
}

class _MemberSelectPageState extends State<MemberSelectPage> {
  final List<Picture> _pictures = [];

  @override
  void initState() {
    super.initState();
  }

  void _onMemberSelected(MemberData member) async {
    final Picture? result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => PoseSelectPage(
                memberData: member,
                colorScheme:
                    AppColorSchemes.getColorScheme(widget.series.color))));
    if (result != null) {
      setState(() {
        _pictures.add(result);
      });
    }
  }

  void _onDecisionPressed() async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                RegisterConfPage(series: widget.series, pictures: _pictures)))??false;
    if (result) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    Series series = widget.series;
    ColorScheme colorScheme = AppColorSchemes.getColorScheme(series.color);
    return Scaffold(
      appBar: AppBar(
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary,
        title: Text(
          "追加 ${_pictures.length + 1}枚目",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(children: [
        ListView.builder(
          itemCount: series.members.length + 2, // リストアイテムの数
          itemBuilder: (context, index) {
            if (index < series.members.length) {
              return GestureDetector(
                child: Container(
                  height: 60.0, // 固定の高さ
                  width: double.infinity, // 画面全体に広げる
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    series.members[index].name,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ),
                onTap: () => _onMemberSelected(series.members[index]),
              );
            } else {
              return const SizedBox(
                height: 60.0, // 固定の高さ
                width: double.infinity, // 画面全体に広げる
              );
            }
          },
        ),
        Visibility(
          visible: _pictures.isNotEmpty,
          child: Overlay(initialEntries: [
            OverlayEntry(
              builder: (context) => Positioned(
                  left: 30.0,
                  bottom: 30.0,
                  child: Material(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10.0,
                            spreadRadius: 5.0,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _pictures.last.name,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              Text(
                                _pictures.last.pose.text,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 32,
                          ),
                          ElevatedButton(
                            style: const ButtonStyle(
                                backgroundColor:
                                    WidgetStatePropertyAll(Colors.red)),
                            onPressed: () {
                              // ボタンが押されたときの処理
                              setState(() {
                                _pictures.removeAt(_pictures.length - 1);
                              });
                            },
                            child: const Text(
                              "取消",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            )
          ]),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _onDecisionPressed,
        heroTag: 'finishAddingButton',
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.check),
      ),
    );
  }
}

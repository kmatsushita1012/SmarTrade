import 'package:aidore/others/member.dart';
import 'package:aidore/others/tools.dart';
import 'package:flutter/material.dart';

class PoseSelectPage extends StatefulWidget {
  final MemberData memberData;
  final ColorScheme colorScheme;
  const PoseSelectPage(
      {super.key, required this.memberData, required this.colorScheme});
  @override
  // ignore: library_private_types_in_public_api
  _PoseSelectPageState createState() => _PoseSelectPageState();
}

class _PoseSelectPageState extends State<PoseSelectPage> {
  @override
  void initState() {
    super.initState();
  }

  void _onPoseSelected(Pose pose) {
    Navigator.pop(context, Picture(widget.memberData.name, pose));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: widget.colorScheme.onPrimary,
        backgroundColor: widget.colorScheme.primary,
        title: const Text(
          "ポーズ選択",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: widget.memberData.stock.keys.map((pose) {
          return GestureDetector(
            child: Container(
              height: 60.0, // 固定の高さ
              width: double.infinity, // 画面全体に広げる
              padding: const EdgeInsets.all(16.0),
              child: Text(
                pose.text,
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            onTap: () => _onPoseSelected(pose),
          );
        }).toList(),
      ),
    );
  }
}

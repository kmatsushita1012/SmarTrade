import 'package:aidore/components/purchasepopup.dart';
import 'package:aidore/others/constants.dart';
import 'package:aidore/others/member.dart';
import 'package:aidore/others/series.dart';
import 'package:aidore/others/tools.dart';
import 'package:flutter/material.dart';

class MemberPopup extends StatefulWidget {
  final MemberData memberData;
  final ColorScheme colorScheme;
  final Series series;
  const MemberPopup(
      {super.key,
      required this.memberData,
      required this.colorScheme,
      required this.series});
  @override
  // ignore: library_private_types_in_public_api
  _MemberPopupState createState() => _MemberPopupState();
}

class _MemberPopupState extends State<MemberPopup> {
  final Map<Pose, int> _stock = {};
  late bool _recommend;

  @override
  void initState() {
    super.initState();
    setState(() {
      _recommend = widget.memberData.recommend;
      widget.memberData.stock.forEach((key, value) {
        _stock[key] = value;
      });
    });
  }

  void _decrementPressed(Pose pose) {
    if ((_stock[pose] ?? 1) < 1) {
      return;
    }
    setState(() {
      _stock[pose] = (_stock[pose] ?? 1) - 1;
    });
  }

  void _incrementPressed(Pose pose) {
    setState(() {
      _stock[pose] = (_stock[pose] ?? 0) + 1;
    });
  }

  Future<bool> _checkCapacity(String message) async {
    if (widget.series.isPurchaseNeeded()) {
      final bool result = await showDialog<bool>(
              context: context,
              builder: (context) => PurchasePopup(
                    series: widget.series,
                    message: message,
                  )) ??
          false;
      setState(() {});
      return result;
    } else {
      return false;
    }
  }

  Future<void> _onConfirmPressed() async {
    _stock.forEach((key, value) {
      widget.memberData.stock[key] = value;
    });
    widget.memberData.recommend = _recommend;
    await _checkCapacity(EXCEED_MESSAGE);
    // ignore: use_build_context_synchronously
    Navigator.pop(context, false);
  }

  void _onCancelPressed() {
    Navigator.pop(context, false);
  }

  void _onDeletePressed() async {
    bool result = await _showConfirmationDialog(context);
    if (result) {
      // ignore: use_build_context_synchronously
      Navigator.pop(context, true);
    }
  }

  Future<bool> _showConfirmationDialog(BuildContext context) async {
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // ダイアログの外をタップして閉じることを防ぐ
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('確認'),
          content: Text('${widget.memberData.name} を除外しますか?'),
          actions: <Widget>[
            ElevatedButton(
              child: const Text(
                'キャンセル',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.pop(context, false); // false を返して閉じる
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true); // true を返して閉じる
              },
              style: ButtonStyle(
                backgroundColor:
                    WidgetStateProperty.all(Colors.red), // 背景色を青に設定
              ),
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(30.0),
        child: Wrap(
          alignment: WrapAlignment.center,
          children: [
            Text(
              widget.memberData.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Container(
              alignment: Alignment.center,
              height: 50,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 50,
                    alignment: Alignment.center,
                    child: const Text(
                      "収集",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  SizedBox(
                    width: 100,
                    height: 50,
                    child: Switch(
                      activeTrackColor: widget.colorScheme.primary,
                      value: _recommend,
                      onChanged: (value) {
                        setState(() {
                          _recommend = value;
                        });
                      },
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 8),
            ..._stock.entries.map((entry) {
              return Container(
                alignment: Alignment.center, // Rowを中央に寄せる
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Row全体の幅を最小限にする
                  children: [
                    Container(
                      width: 80,
                      height: 50,
                      alignment: Alignment.center,
                      child: Text(
                        entry.key.text,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Container(
                      width: 20,
                      height: 50,
                      alignment: Alignment.center,
                      child: Text(
                        entry.value.toString(),
                        style: const TextStyle(
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      child: GestureDetector(
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.blue[300],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.remove),
                        ),
                        onTap: () => _decrementPressed(entry.key),
                      ),
                    ),
                    Container(
                      width: 50,
                      height: 50,
                      alignment: Alignment.center,
                      child: GestureDetector(
                        child: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.red[300],
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add),
                        ),
                        onTap: () => _incrementPressed(entry.key),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            Container(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _onDeletePressed,
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all(Colors.white), // 背景色を青に設定
                ),
                child: const Text(
                  '除外',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              alignment: Alignment.centerRight, // Rowを中央に寄せる
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _onCancelPressed,
                      child: Text(
                        'キャンセル',
                        style: TextStyle(color: widget.colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _onConfirmPressed,
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all(
                            widget.colorScheme.primary), // 背景色を青に設定
                      ),
                      child: Text(
                        '決定',
                        style: TextStyle(
                            color: widget.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

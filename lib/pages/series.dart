import 'package:aidore/components/memberpopup.dart';
import 'package:aidore/components/purchasepopup.dart';
import 'package:aidore/components/seriespopup.dart';
import 'package:aidore/others/constants.dart';
import 'package:aidore/others/member.dart';
import 'package:aidore/others/series.dart';
import 'package:aidore/others/tools.dart';
import 'package:aidore/pages/memberselect.dart';
import 'package:aidore/pages/trade.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class SeriesPage extends StatefulWidget {
  final Series series;
  const SeriesPage({super.key, required this.series});
  @override
  // ignore: library_private_types_in_public_api
  _SeriesPageState createState() => _SeriesPageState();
}

class _SeriesPageState extends State<SeriesPage> {
  late final Series _series = widget.series;

  @override
  void initState() {
    super.initState();
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
      return true;
    }
  }

  void _onAddPressed() async {
    if (!await _checkCapacity(EXCEEDED_MESSAGE)) {
      return;
    }
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => MemberSelectPage(
                  series: widget.series,
                )));
    setState(() {});
  }

  void _onTradePressed() async {
    if (!await _checkCapacity(EXCEEDED_MESSAGE)) {
      return;
    }
    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => TradePage(
                  series: widget.series,
                )));

    setState(() {});
  }

  void _changeCollecting(MemberData member) {
    setState(() {
      member.recommend = !member.recommend;
      SeriesRepository().insertSeries(widget.series);
    });
  }

  void _showMemberPopup(MemberData member) async {
    if (!await _checkCapacity(EXCEEDED_MESSAGE)) {
      return;
    }
    final bool result = await showDialog<bool>(
            context: context,
            builder: (context) => MemberPopup(
                  memberData: member,
                  colorScheme:
                      AppColorSchemes.getColorScheme(widget.series.color),
                  series: _series,
                )) ??
        false;
    if (result) {
      _series.members.remove(member);
    }
    SeriesRepository().insertSeries(widget.series);
    setState(() {});
  }

  Future<void> _onEditPressed() async {
    final PopupResult result = await showDialog<PopupResult?>(
            context: context,
            builder: (context) => SeriesPopup(series: _series)) ??
        PopupResult.canceled;
    if (result == PopupResult.deleted) {
      Navigator.pop(
        // ignore: use_build_context_synchronously
        context,
      );
    }
    setState(() {});
  }

  Future<void> _onHelpPressed() async {
    showDialog<PopupResult?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            '商品ホーム画面',
            textAlign: TextAlign.center,
          ),
          content: Wrap(
            alignment: WrapAlignment.center,
            children: [
              const Text("現在の在庫が表示されています."),
              const Text("収集する/しないを名前をタップすることで切り替えることができます."),
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: AppColorSchemes.wantColorScheme.surface),
                  ),
                  const Expanded(
                    child: Text(
                      "求メン:収集するメンバー(1コンプを確保)",
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                        color: AppColorSchemes.offerColorScheme.surface),
                  ),
                  const Expanded(
                    child: Text(
                      "譲メン:収集しないメンバー",
                    ),
                  )
                ],
              ),
              const Text("名前を長押しするとそのメンバーの在庫を編集できます."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Icon(Icons.close),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorSchemes.getColorScheme(widget.series.color);
    return Scaffold(
      appBar: AppBar(
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary,
        title: Text(
          "${_series.group}  ${_series.name}",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _onEditPressed,
          ),
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: _onHelpPressed,
          ),
        ],
      ),
      body: Column(
        children: [
          // ヘッダー行をここに固定
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: 30,
                color: Colors.black54,
                alignment: Alignment.center,
                child: const Text(
                  'メンバー',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              ...List.generate(
                _series.poses.length,
                (index) => Container(
                  width: MediaQuery.of(context).size.width *
                      (0.6 / _series.poses.length),
                  height: 30,
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: AutoSizeText(
                    _series.poses[index].text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
          // データ行をスクロール可能に
          Expanded(
            child: ListView.builder(
              itemCount: _series.members.length,
              itemBuilder: (context, index) {
                final member = _series.members[index];
                Color color = (member.recommend
                    ? (member.isCompleted
                        ? AppColorSchemes.wantColorScheme.secondary
                        : AppColorSchemes.wantColorScheme.surface)
                    : AppColorSchemes.offerColorScheme.surface);
                return Row(
                  children: [
                    GestureDetector(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 40,
                        color: color,
                        alignment: Alignment.center,
                        child: AutoSizeText(
                          member.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: member.isCompleted
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 16),
                        ),
                      ),
                      onTap: () => _changeCollecting(member),
                      onLongPress: () => _showMemberPopup(member),
                    ),
                    ...widget.series.poses.map((pose) {
                      return Container(
                        width: MediaQuery.of(context).size.width *
                            (0.6 / _series.poses.length),
                        height: 40,
                        color: color,
                        alignment: Alignment.center,
                        child: Text(
                          member.stock[pose].toString(),
                          style: TextStyle(
                              color: member.isCompleted
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 16),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: colorScheme.secondary,
        height: 50,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: _onAddPressed,
              icon: const Icon(Icons.add),
              color: colorScheme.onSecondary,
            ),
            IconButton(
              onPressed: _onTradePressed,
              icon: const Icon(Icons.sync_alt),
              color: colorScheme.onSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

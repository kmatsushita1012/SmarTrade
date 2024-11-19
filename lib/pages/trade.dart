import 'package:aidore/others/member.dart';
import 'package:aidore/others/series.dart';
import 'package:aidore/others/tools.dart';
import 'package:aidore/pages/tradeconf.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class TradePage extends StatefulWidget {
  final Series series;
  const TradePage({super.key, required this.series});
  @override
  // ignore: library_private_types_in_public_api
  _TradePageState createState() => _TradePageState();
}

class _TradePageState extends State<TradePage> {
  bool _isRequest = true;
  bool _isFiltered = true;
  final Map<Picture, bool> _wantedMap = {};
  final Map<Picture, bool> _offeredMap = {};
  late final Series _series = widget.series;
  late final ColorScheme _colorScheme =
      AppColorSchemes.getColorScheme(_series.color);

  @override
  void initState() {
    super.initState();
    setState(() {
      widget.series.members.map((member) {
        for (var pose in widget.series.poses) {
          _wantedMap[Picture(member.name, pose)] = false;
          _offeredMap[Picture(member.name, pose)] = false;
        }
      }).toList();
    });
  }

  void _onDecisionPressed() async {
    List<Picture> wantedItems = _wantedMap.entries
        .where((item) => item.value)
        .map((item) => item.key)
        .toList();
    List<Picture> offeredItems = _offeredMap.entries
        .where((item) => item.value)
        .map((item) => item.key)
        .toList();
    final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TradeConfPage(
                    series: widget.series,
                    wantedItems: wantedItems,
                    offeredItems: offeredItems))) ??
        false;

    setState(() {
      if (result) {
        _wantedMap.forEach((key, value) {
          _wantedMap[key] = false;
        });
        _offeredMap.forEach((key, value) {
          _offeredMap[key] = false;
        });
      }
    });
  }

  Future<void> _onHelpPressed() async {
    showDialog<PopupResult?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'トレード画面',
            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Text("トレード用ページです タブを切り替えて欲しいメンバーと譲るメンバーを選択します"),
                ),
                SizedBox(
                  height: 8,
                ),
                Container(
                  child: Text("タブ"),
                ),
                Container(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColorSchemes.wantColorScheme.primary,
                        ),
                        child: const Text(
                          "求",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const Expanded(
                        child: Text(
                          "求めているアイテムを表示 ソートONの時は求メンのみ ソートOFFの時は全員",
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppColorSchemes.offerColorScheme.primary),
                      child: const Text(
                        "譲",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        "譲れるアイテムを表示するタブ ソートON時は譲メンのコンプを除外 ソートOFF時は全てのアイテム",
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                const Text("ソートボタン"),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                      ),
                      child: const Icon(
                        Icons.filter_list,
                        color: Colors.white,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        "ソートはONです.必要なメンバーのみ表示されます.",
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                      ),
                      child: const Icon(
                        Icons.filter_list,
                        color: Colors.black,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        "ソートはOFFです.全てのメンバーが表示されます.",
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                const Text("求タブ"),
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppColorSchemes.wantColorScheme.secondary),
                      child: const Text(
                        "ヨリ",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        "求メンのコンプに必要なアイテムです",
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppColorSchemes.wantColorScheme.surface),
                      child: const Text(
                        "ヨリ",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        "求メンのコンプに必要では無いですが選択可能です",
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppColorSchemes.wantColorScheme.primary),
                      child: const Text(
                        "ヨリ",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        "トレード候補として選択されています",
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                const Text("譲タブ"),
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppColorSchemes.offerColorScheme.secondary),
                      child: const Text(
                        "ヨリ",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        "現在所持しており選択可能です",
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppColorSchemes.offerColorScheme.surface),
                    ),
                    const Expanded(
                      child: Text(
                        "現在所持してないので選択不可です",
                      ),
                    )
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: AppColorSchemes.offerColorScheme.primary),
                      child: const Text(
                        "ヨリ",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        "トレード候補として選択されています",
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                const Text("チェックマークでトレードの最終確認に移行します"),
              ],
            ),
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
    ColorScheme tradeColorScheme = _isRequest
        ? AppColorSchemes.wantColorScheme
        : AppColorSchemes.offerColorScheme;
    Map<Picture, bool> selectedItems = _isRequest ? _wantedMap : _offeredMap;
    double screenWidth = MediaQuery.of(context).size.width;

    List<MemberData> members = List.from(_series.members);
    if (_isRequest) {
      members.sort((a, b) => a.hasAnyShortage == b.hasAnyShortage
          ? 0
          : (a.hasAnyShortage ? -1 : 1));
    }
    return Scaffold(
      appBar: AppBar(
        foregroundColor: _colorScheme.onPrimary,
        backgroundColor: _colorScheme.primary,
        title: Text(
          _series.name,
          style: TextStyle(
              color: _colorScheme.onPrimary, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help),
            onPressed: _onHelpPressed,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: screenWidth,
            height: 40,
            child: Row(
              children: [
                GestureDetector(
                  child: Container(
                    width: screenWidth * 0.4,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _isRequest
                          ? AppColorSchemes.wantColorScheme.primary
                          : AppColorSchemes.wantColorScheme.surface,
                      border: const Border(
                        bottom: BorderSide(
                          color: Colors.black45, // 右罫線の色
                          width: 1.0, // 右罫線の太さ
                        ),
                      ),
                    ),
                    child: Text(
                      "求",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            _isRequest ? FontWeight.bold : FontWeight.normal,
                        color: _isRequest
                            ? AppColorSchemes.wantColorScheme.onPrimary
                            : AppColorSchemes.wantColorScheme.onSurface,
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _isRequest = true;
                    });
                  },
                ),
                GestureDetector(
                  child: Container(
                    width: screenWidth * 0.2,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _isFiltered ? Colors.grey[800] : Colors.grey[300],
                      border: const Border(
                        bottom: BorderSide(
                          color: Colors.black45, // 右罫線の色
                          width: 1.0, // 右罫線の太さ
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.filter_list,
                      color: _isFiltered ? Colors.white : Colors.black,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _isFiltered = !_isFiltered;
                    });
                  },
                ),
                GestureDetector(
                  child: Container(
                    width: screenWidth * 0.4,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: !_isRequest
                          ? AppColorSchemes.offerColorScheme.primary
                          : AppColorSchemes.offerColorScheme.surface,
                      border: const Border(
                        bottom: BorderSide(
                          color: Colors.black45, // 右罫線の色
                          width: 1.0, // 右罫線の太さ
                        ),
                      ),
                    ),
                    child: Text(
                      "譲",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            _isRequest ? FontWeight.normal : FontWeight.bold,
                        color: !_isRequest
                            ? AppColorSchemes.wantColorScheme.onPrimary
                            : AppColorSchemes.wantColorScheme.onSurface,
                      ),
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _isRequest = false;
                    });
                  },
                )
              ],
            ),
          ),
          Expanded(
            // リスト部分をExpandedでラップ
            child: ListView.builder(
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                if ((_isFiltered && _isRequest && !member.hasAnyShortage) ||
                    (!_isRequest &&
                        !member.hasAnyStock(isLeftComplete: _isFiltered))) {
                  return Container(); // フィルタに一致しない場合は空のコンテナを返す
                }
                return Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: 40,
                      alignment: Alignment.center,
                      color: tradeColorScheme.surface,
                      child: Text(
                        member.name,
                        style: TextStyle(
                          color: tradeColorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ..._series.poses.map((pose) {
                      bool isSelected =
                          selectedItems[Picture(member.name, pose)] ?? false;
                      bool flag = _isRequest
                          ? member.hasShortage(pose)
                          : member.hasStock(pose, isLeftComplete: _isFiltered);
                      return GestureDetector(
                        onTap: _isRequest || flag
                            ? () {
                                setState(() {
                                  Picture key = Picture(member.name, pose);
                                  selectedItems[key] =
                                      !(selectedItems[key] ?? true);
                                });
                              }
                            : () {},
                        child: Container(
                          width: MediaQuery.of(context).size.width *
                              (0.6 / _series.poses.length),
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? tradeColorScheme.primary
                                : (flag
                                    ? tradeColorScheme.secondary
                                    : tradeColorScheme.surface),
                            border: const Border(
                              left: BorderSide(
                                color: Colors.black45,
                                width: 1.0,
                              ),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Visibility(
                            visible: (!_isFiltered && _isRequest) ||
                                flag ||
                                isSelected,
                            child: AutoSizeText(
                              pose.text,
                              style: TextStyle(
                                color: isSelected
                                    ? tradeColorScheme.onPrimary
                                    : (flag
                                        ? tradeColorScheme.onSecondary
                                        : tradeColorScheme.onSurface),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        foregroundColor: _colorScheme.onPrimary,
        backgroundColor: _colorScheme.primary,
        onPressed: _onDecisionPressed,
        heroTag: 'decisionButton',
        child: const Icon(Icons.check),
      ),
    );
  }
}

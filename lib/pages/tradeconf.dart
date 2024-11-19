import 'dart:math';

import 'package:aidore/components/purchasepopup.dart';
import 'package:aidore/others/constants.dart';
import 'package:aidore/others/member.dart';
import 'package:aidore/others/series.dart';
import 'package:aidore/others/tools.dart';
import 'package:flutter/material.dart';

class TradeConfPage extends StatefulWidget {
  final Series series;
  final List<Picture> wantedItems;
  final List<Picture> offeredItems;
  const TradeConfPage(
      {super.key,
      required this.series,
      required this.wantedItems,
      required this.offeredItems});
  @override
  _TrageCongPageState createState() => _TrageCongPageState();
}

class _TrageCongPageState extends State<TradeConfPage> {
  late List<Picture> _wantedItems = widget.wantedItems;
  late List<Picture> _offeredItems = widget.offeredItems;

  Future<void> _onDecisionPressed(BuildContext context) async {
    handleWantedItems();
    handleOfferedItems();
    await SeriesRepository().insertSeries(widget.series);
    await _checkCapacity(context, EXCEED_MESSAGE);
    // ignore: use_build_context_synchronously
    Navigator.pop(context, true);
  }

  void handleWantedItems() {
    _wantedItems.forEach((item) {
      MemberData member = widget.series.members
          .firstWhere((member) => member.name == item.name);
      member.stock[item.pose] = (member.stock[item.pose] ?? 0) + 1;
    });
  }

  void handleOfferedItems() {
    _offeredItems.forEach((item) {
      MemberData member = widget.series.members
          .firstWhere((member) => member.name == item.name);
      if ((member.stock[item.pose] ?? 0) > 0) {
        member.stock[item.pose] = (member.stock[item.pose] ?? 1) - 1;
      }
    });
    return;
  }

  Future<bool> _checkCapacity(BuildContext context, String message) async {
    if (widget.series.isPurchaseNeeded()) {
      final bool result = await showDialog<bool>(
              context: context,
              builder: (context) => PurchasePopup(
                    series: widget.series,
                    message: message,
                  )) ??
          false;
      return result;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme =
        AppColorSchemes.getColorScheme(widget.series.color);
    return Scaffold(
      appBar: AppBar(
        foregroundColor: colorScheme.onPrimary,
        backgroundColor: colorScheme.primary,
        title: Text(
          widget.series.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _wantedItems.length,
              itemBuilder: (context, index) {
                Picture picture = _wantedItems[index];
                return ListTile(
                  title: Text("${picture.name} ${picture.pose.text}"),
                  tileColor: AppColorSchemes.wantColorScheme.surface,
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _wantedItems.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 40,
            child: Transform.rotate(
              angle: pi / 2,
              child: const Icon(
                size: 40,
                Icons.sync_alt,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _offeredItems.length,
              itemBuilder: (context, index) {
                Picture picture = _offeredItems[index];
                return ListTile(
                  title: Text("${picture.name} ${picture.pose.text}"),
                  tileColor: AppColorSchemes.offerColorScheme.surface,
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _offeredItems.removeAt(index);
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onDecisionPressed(context), // 決定を示すアイコン
        tooltip: '決定', // ツールチップに表示されるテキスト
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.check),
      ),
    );
  }
}

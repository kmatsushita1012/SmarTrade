import 'package:aidore/components/purchasepopup.dart';
import 'package:aidore/others/constants.dart';
import 'package:aidore/others/member.dart';
import 'package:aidore/others/series.dart';
import 'package:aidore/others/tools.dart';
import 'package:flutter/material.dart';

class RegisterConfPage extends StatefulWidget {
  final Series series;
  final List<Picture> pictures;
  const RegisterConfPage(
      {super.key, required this.series, required this.pictures});
  @override
  // ignore: library_private_types_in_public_api
  _RegisterConfPageState createState() => _RegisterConfPageState();
}

class _RegisterConfPageState extends State<RegisterConfPage> {
  late List<Picture> _pictures = widget.pictures;
  Future<void> _onDecisionPressed() async {
    save();
    // ignore: use_build_context_synchronously
    Navigator.pop(context, true);
  }

  Future<void> save() async {
    for (var picture in _pictures) {
      MemberData member =
          widget.series.members.firstWhere((elem) => elem.name == picture.name);
      member.stock[picture.pose] = (member.stock[picture.pose] ?? 0) + 1;
    }
    Series series = widget.series;
    await SeriesRepository().insertSeries(series);
    if (widget.series.isPurchaseNeeded()) {
      await showDialog<bool>(
          context: context,
          builder: (context) => PurchasePopup(
                series: widget.series,
                message: EXCEED_MESSAGE,
              ));
    }
    return;
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
      body: ListView.builder(
        itemCount: _pictures.length,
        itemBuilder: (context, index) {
          Picture picture = _pictures[index];
          return ListTile(
            title: Text("${picture.name} ${picture.pose.text}"),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () {
                setState(() {
                  _pictures.removeAt(index);
                });
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onDecisionPressed, // 決定を示すアイコン
        tooltip: '決定', // ツールチップに表示されるテキスト
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.check),
      ),
    );
  }
}

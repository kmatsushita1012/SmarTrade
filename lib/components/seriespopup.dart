import 'dart:io';

import 'package:aidore/others/constants.dart';
import 'package:aidore/others/series.dart';
import 'package:aidore/others/tools.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class SeriesPopup extends StatefulWidget {
  final Series series;
  final bool isNeededDelete;
  const SeriesPopup(
      {super.key, required this.series, this.isNeededDelete = true});
  @override
  // ignore: library_private_types_in_public_api
  _SeriesPopupState createState() => _SeriesPopupState();
}

class _SeriesPopupState extends State<SeriesPopup> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late ProductDetails _product;
  int _purchaseCounter = 0;

  @override
  void initState() {
    super.initState();
    _initializeInAppPurchase(); // 課金アイテムの初期化
    _listenToPurchaseUpdates(); // 課金処理の監視
  }

  void _onCancelPressed() {
    Navigator.pop(context, PopupResult.canceled);
  }

  void _onDeletePressed() async {
    PopupResult result = await _showConfirmationDialog(context);
    if (result == PopupResult.deleted) {
      await SeriesRepository()
          .removeSeries(widget.series.name, widget.series.group);
      // ignore: use_build_context_synchronously
      Navigator.pop(context, result);
    }
  }

  // 課金アイテムの初期化
  Future<void> _initializeInAppPurchase() async {
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(kIds); // 商品IDを指定
    if (response.notFoundIDs.isEmpty) {
      setState(() {
        _product = response.productDetails.first; // 単一の商品を取得
      });
    }
  }

  // 課金処理を行う
  Future<void> _buyProduct() async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: _product);
    await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
    _purchaseCounter += 1;
  }

  // 課金完了後に呼ばれるコールバック
  void _listenToPurchaseUpdates() {
    _inAppPurchase.purchaseStream.listen((purchases) async {
      for (var purchase in purchases) {
        if (purchase.status == PurchaseStatus.purchased &&
            _purchaseCounter > 0) {
          // 課金が成功した場合に、プロジェクトの容量を更新
          _handleSuccessfulPurchase();
          _purchaseCounter -= 1;
          if (purchase.pendingCompletePurchase) {
            await _inAppPurchase.completePurchase(purchase);
          }
        }
      }
    });
  }

  // 課金成功時の処理
  void _handleSuccessfulPurchase() {
    setState(() {
      // 課金が必要なプロジェクトを見つけて容量を増加
      widget.series.addCapacity();
      SeriesRepository().insertSeries(widget.series);
    });
  }

  Future<void> _handlePurchased() async {
    try {
      await _buyProduct();
    } catch (e) {
      print("catch${e}");
      _cancelTransction();
      return;
    }
    Navigator.pop(context, PopupResult.purchased);
  }

  void _cancelTransction() async {
    if (Platform.isIOS) {
      var paymentWrapper = SKPaymentQueueWrapper();
      var transactions = await paymentWrapper.transactions();
      for (var i = 0; i < transactions.length; i++) {
        await paymentWrapper.finishTransaction(transactions[i]);
      }
    }
  }

  Future<PopupResult> _showConfirmationDialog(BuildContext context) async {
    final PopupResult? result = await showDialog<PopupResult>(
      context: context,
      barrierDismissible: false, // ダイアログの外をタップして閉じることを防ぐ
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('確認'),
          content: Text('${widget.series.name} を削除しますか?'),
          actions: <Widget>[
            ElevatedButton(
              child: const Text(
                'キャンセル',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () {
                Navigator.of(context)
                    .pop(PopupResult.canceled); // false を返して閉じる
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, PopupResult.deleted); // true を返して閉じる
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
    return result ?? PopupResult.canceled;
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
              widget.series.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 左側の文字
                const Text(
                  '現在の容量',
                  style: TextStyle(fontSize: 16.0),
                ),
                // 右側のボタン
                Text(
                  '${widget.series.capacity}',
                  style: const TextStyle(fontSize: 16.0),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 左側の文字
                const Text(
                  '現在の枚数',
                  style: TextStyle(fontSize: 16.0),
                ),
                // 右側のボタン
                Text(
                  '${widget.series.count}',
                  style: const TextStyle(fontSize: 16.0),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 左側の文字
                const Text(
                  '$PRICE円/50枚で追加',
                  style: TextStyle(fontSize: 16.0),
                ),
                // 右側のボタン
                ElevatedButton(
                  onPressed: _handlePurchased,
                  style: ButtonStyle(
                    backgroundColor:
                        WidgetStateProperty.all(Colors.blue), // 背景色を青に設定
                  ),
                  child: const Text(
                    '購入',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              alignment: Alignment.centerRight, // Rowを中央に寄せる
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 左側の文字
                  const Text(
                    'この商品を削除',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  // 右側のボタン
                  ElevatedButton(
                    onPressed: _onDeletePressed,
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(Colors.red), // 背景色を青に設定
                    ),
                    child: const Text(
                      '削除',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Container(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                  onPressed: _onCancelPressed, child: const Icon(Icons.close)),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:developer';
import 'package:base_kits/base_kits.dart';
import 'package:base_kits/src/local/local_storage.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
// ignore: depend_on_referenced_packages
import 'package:collection/collection.dart';

class StoreKit {
  static final StoreKit _instance = StoreKit._internal();
  StoreKit._internal();
  factory StoreKit() => _instance;

  List<ProductDetails> listProductDetails = [];
  Timer? _restoringTimeOutTimer;
  bool _isSuccessfullyRestored = false;

  final premiumPublishSub = PublishSubject<bool>();
  final purchase = PublishSubject<bool>();

  init() async {
    // Check Store
    final bool isAvailable = await InAppPurchase.instance.isAvailable();
    // Listen to purchase
    if (isAvailable) {
      InAppPurchase.instance.purchaseStream
          .listen((List<PurchaseDetails> listPurchaseDetails) async {
        try {
          log('Got value from purchase stream', name: 'StoreKit');
          _restoringTimeOutTimer?.cancel();
          // Complete purchase
          for (var purchase in listPurchaseDetails) {
            if (purchase.pendingCompletePurchase &&
                (purchase.status == PurchaseStatus.restored ||
                    purchase.status == PurchaseStatus.purchased)) {
              log('Completed pending purchase!', name: 'StoreKit');
              await InAppPurchase.instance.completePurchase(purchase);
            }
          }
          // Purchase cancel
          final cancelPurchaseDetail = listPurchaseDetails
              .firstWhereOrNull((e) => e.status == PurchaseStatus.canceled);
          if (cancelPurchaseDetail != null) {
            AnalyticKit().logEvent(name: AnalyticEvent.purchaseCancel);
            await InAppPurchase.instance.completePurchase(cancelPurchaseDetail);
          }
          // Check successfull purchases
          final successfullPurchaseDetail =
              listPurchaseDetails.firstWhereOrNull(
            (e) =>
                (e.status == PurchaseStatus.purchased ||
                    e.status == PurchaseStatus.restored) &&
                !_isPurchaseOutdated(
                  e.transactionDate,
                  e.productID,
                ),
          );
          if (successfullPurchaseDetail != null) {
            _isSuccessfullyRestored = true;
            log('Successfully restored/purchase purchase!!!: ${successfullPurchaseDetail.purchaseID}',
                name: 'StoreKit');
            // Analytic
            SubscriptionTracking().update(
              value: listProductDetails
                  .firstWhereOrNull(
                      (e) => e.id == successfullPurchaseDetail.productID)
                  ?.rawPrice,
              productId: successfullPurchaseDetail.productID,
            );

            AnalyticKit().logEvent(
              name: successfullPurchaseDetail.status == PurchaseStatus.purchased
                  ? AnalyticEvent.purchaseSuccess
                  : AnalyticEvent.purchaseRestore,
              params: SubscriptionTracking().toMap(),
            );
            // Notify
            premiumPublishSub.add(true);
            // Save to local purchase
            LocalStorage().setLastLocalPurchase(LocalPurchaseEntity(
              productId: successfullPurchaseDetail.productID,
              purchasedDateInMillisecond:
                  int.parse(successfullPurchaseDetail.transactionDate!),
            ));
          } else {
            log('Not found any purchases', name: 'StoreKit');
          }
        } catch (e, s) {
          FirebaseCrashlytics.instance.recordError(e, s);
        }
      });
    }
  }

  Future<bool> makeAPurchase(ProductDetails productDetails) async {
    return InAppPurchase.instance.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: productDetails),
    );
  }

  Future<void> queryProducts(Set<String> productIds) async {
    final ProductDetailsResponse response =
        await InAppPurchase.instance.queryProductDetails(productIds);
    listProductDetails = response.productDetails;
    for (var e in response.productDetails) {
      log('Got products: ${e.title} + ${e.price}', name: 'StoreKit');
    }
  }

  bool get hasLocalPurchase => LocalStorage().lastLocalPurchase != null;

  Future<void> restorePurchase(
      {bool enableTimeOut = false, VoidCallback? onTimeOut}) async {
    if (kDebugMode) {
      log("SET PREMIMUM = FALSE (DEBUG)");
      return;
    }
    final lastPurchase = LocalStorage().lastLocalPurchase;
    if (lastPurchase != null && kReleaseMode) {
      final isOutdated = _isPurchaseOutdated(
          lastPurchase.purchasedDateInMillisecond.toString(),
          lastPurchase.productId);
      if (!isOutdated) {
        log('Restored premium successfully from local storage',
            name: 'StoreKit');
        // Notify
        premiumPublishSub.add(true);
        return;
      }
    }
    try {
      log('Sent restoring request to store', name: 'StoreKit');
      await InAppPurchase.instance
          .restorePurchases()
          .catchError((e, s) => FirebaseCrashlytics.instance.recordError(e, s));
      if (enableTimeOut) {
        final completer = Completer();
        _restoringTimeOutTimer =
            Timer.periodic(const Duration(seconds: 1), (timer) {
          if (timer.tick == 10 && !_isSuccessfullyRestored) {
            _restoringTimeOutTimer?.cancel();
            onTimeOut != null ? onTimeOut() : null;
            completer.complete();
          }
          if (_isSuccessfullyRestored) {
            _restoringTimeOutTimer?.cancel();
            completer.complete();
          }
        });
        await completer.future;
      }
    } catch (e, s) {
      FirebaseCrashlytics.instance.recordError(e, s);
    }
  }

  bool _isPurchaseOutdated(String? transactionDate, String productId) {
    try {
      int productDurationInDays = 7;
      if (productId.contains('week')) {
        productDurationInDays = 7;
      } else if (productId.contains('month')) {
        productDurationInDays = 31;
      } else if (productId.contains('year')) {
        productDurationInDays = 365;
      } else if (productId.contains('lifetime')) {
        return false;
      }
      final diff = DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(int.parse(transactionDate!)));
      return diff.inDays > productDurationInDays;
    } catch (e) {
      return true;
    }
  }
}

import 'dart:async';
import 'dart:developer';
import 'dart:io';
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
  bool _isSuccessfullyRestored = false;

  final premiumPublishSub = PublishSubject<bool>();
  final purchase = PublishSubject<bool>();
  final cancelPublishSub = PublishSubject<bool>();

  Future<void> init() async {
    // Check Store
    final bool isAvailable = await InAppPurchase.instance.isAvailable();
    // Listen to purchase
    if (isAvailable) {
      InAppPurchase.instance.purchaseStream
          .listen((List<PurchaseDetails> listPurchaseDetails) async {
        try {
          log('Got value from purchase stream', name: 'StoreKit');
          // Complete purchase
          for (var i = 0; i < listPurchaseDetails.length; i++) {
            final purchase = listPurchaseDetails[i];
            if (purchase.pendingCompletePurchase &&
                purchase.status != PurchaseStatus.pending) {
              log('Completed pending purchase!', name: 'StoreKit');
              await InAppPurchase.instance.completePurchase(purchase);
            }
          }
          // Purchase cancel
          final cancelPurchaseDetail = listPurchaseDetails
              .firstWhereOrNull((e) => e.status == PurchaseStatus.canceled);
          if (cancelPurchaseDetail != null) {
            if (Platform.isIOS) {
              await InAppPurchase.instance
                  .completePurchase(cancelPurchaseDetail);
            }
            cancelPublishSub.add(true);
            AnalyticKit().logEvent(name: AnalyticEvent.purchaseCancel);
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
            SubscriptionTracking().update(
              value: listProductDetails
                  .firstWhereOrNull(
                      (e) => e.id == successfullPurchaseDetail.productID)
                  ?.rawPrice,
              productId: successfullPurchaseDetail.productID,
            );
            log('Successfully restored/purchase purchase!!!: ${successfullPurchaseDetail.purchaseID}',
                name: 'StoreKit');
            // Analytic
            if (kReleaseMode) {
              if (successfullPurchaseDetail.status ==
                  PurchaseStatus.purchased) {
                AnalyticKit().logPurchase(
                  currency: SubscriptionTracking().currency,
                  price: SubscriptionTracking().value,
                );
                AnalyticKit().logEvent(
                  name: AnalyticEvent.purchaseSuccess,
                  params: SubscriptionTracking().toMap(),
                );
              } else if (successfullPurchaseDetail.status ==
                  PurchaseStatus.restored) {
                AnalyticKit().logEvent(
                  name: AnalyticEvent.purchaseRestore,
                  params: SubscriptionTracking().toMap(),
                );
              }
            }
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
    listProductDetails = [];
    for (var id in productIds) {
      final product =
          response.productDetails.firstWhereOrNull((e) => e.id == id);
      if (product != null) {
        listProductDetails.add(product);
      }
    }
    for (var e in response.productDetails) {
      log('Got products: ${e.title} + ${e.price}', name: 'StoreKit');
    }
  }

  bool get hasLocalPurchase => LocalStorage().lastLocalPurchase != null;

  Future<void> restorePurchase({
    bool enableTimeOut = false,
    VoidCallback? onTimeOut,
    VoidCallback? onSuccessfullyRestored,
  }) async {
    _isSuccessfullyRestored = false;
    final lastPurchase = LocalStorage().lastLocalPurchase;
    if (lastPurchase != null) {
      final isOutdated = _isPurchaseOutdated(
          lastPurchase.purchasedDateInMillisecond.toString(),
          lastPurchase.productId);
      if (!isOutdated) {
        log('Restored premium successfully from local storage',
            name: 'StoreKit');
        // Notify
        premiumPublishSub.add(true);
        onSuccessfullyRestored != null ? onSuccessfullyRestored() : null;
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
        Timer.periodic(const Duration(seconds: 1), (timer) {
          if (timer.tick == 10 && !_isSuccessfullyRestored) {
            AnalyticKit().logEvent(name: "restore_failed");
            onTimeOut != null ? onTimeOut() : null;
            completer.complete();
            timer.cancel();
          }
          if (_isSuccessfullyRestored) {
            AnalyticKit().logEvent(name: "restore_success");
            onSuccessfullyRestored != null ? onSuccessfullyRestored() : null;
            timer.cancel();
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

// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:base_kits/base_kits.dart';
import 'package:base_kits/src/local/local_storage.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:tuple/tuple.dart';

class StoreKit {
  static final StoreKit _instance = StoreKit._internal();
  StoreKit._internal();
  factory StoreKit() => _instance;

  List<ProductDetails> listProductDetails = [];
  bool _isSuccessfullyRestored = false;

  final premiumPublishSub = PublishSubject<bool>();
  final cancelPublishSub = PublishSubject<bool>();
  final purchaseUniqueIdAndProductIdNotifier =
      ValueNotifier<Tuple2<String?, String>?>(null);

  Future<void> init({bool shouldInit = true}) async {
    if (!shouldInit) {
      log('StoreKit was blocked from init by "shouldInit"', name: "StoreKit");
      return;
    }
    // Check Store
    final bool isAvailable = await InAppPurchase.instance.isAvailable();
    // Listen to purchase
    if (isAvailable) {
      InAppPurchase.instance.purchaseStream
          .listen((List<PurchaseDetails> listPurchaseDetails) async {
        try {
          // Complete purchase
          for (var i = 0; i < listPurchaseDetails.length; i++) {
            final purchase = listPurchaseDetails[i];
            log('Got value from purchase stream: ${purchase.purchaseID}',
                name: 'StoreKit');
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
            final productDetail = listProductDetails.firstWhereOrNull(
                (e) => e.id == successfullPurchaseDetail.productID);
            SubscriptionTracking().update(
              currency: productDetail?.currencyCode,
              value: productDetail?.rawPrice,
              productId: successfullPurchaseDetail.productID,
            );
            log('Successfully restored/purchase purchase!!!: ${successfullPurchaseDetail.purchaseID}',
                name: 'StoreKit');
            log('localVerificationData: ${successfullPurchaseDetail.verificationData.localVerificationData}',
                name: 'StoreKit');
            log('serverVerificationData: ${successfullPurchaseDetail.verificationData.serverVerificationData}',
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
            // Define unique id for puchase transaction
            var purchaseUniqueId = successfullPurchaseDetail.purchaseID;
            if (successfullPurchaseDetail is AppStorePurchaseDetails) {
              purchaseUniqueId = successfullPurchaseDetail.skPaymentTransaction
                  .originalTransaction?.transactionIdentifier;
            } else if (successfullPurchaseDetail is GooglePlayPurchaseDetails) {
              purchaseUniqueId =
                  successfullPurchaseDetail.billingClientPurchase.orderId;
            }
            // Send successfullPurchaseDetail
            log("Got purchase id: $purchaseUniqueId", name: 'StoreKit');
            purchaseUniqueIdAndProductIdNotifier.value =
                Tuple2(purchaseUniqueId, successfullPurchaseDetail.productID);
            // Save to local purchase
            LocalStorage().setLastLocalPurchase(LocalPurchaseEntity(
              purchaseId: purchaseUniqueId ?? "",
              productId: successfullPurchaseDetail.productID,
              purchasedDateInMillisecond:
                  int.parse(successfullPurchaseDetail.transactionDate!),
            ));
            // Notify
            premiumPublishSub.add(true);
          } else {
            log('Not found any purchases', name: 'StoreKit');
            LocalStorage().removeLastLocalPurchase();
          }
        } catch (e, s) {
          FirebaseCrashlytics.instance.recordError(e, s);
        }
      });
    }
  }

  LocalPurchaseEntity? get lastLocalPurchase =>
      LocalStorage().lastLocalPurchase;

  Future<bool> makeAPurchase(ProductDetails productDetails) async {
    return InAppPurchase.instance.buyNonConsumable(
      purchaseParam: PurchaseParam(
        productDetails: productDetails,
        applicationUserName: StringUtil.generateRandomString(11),
      ),
    );
  }

  Future<String?> getPurchaseId() async {
    return (await queryLastPurchaseID() ??
        purchaseUniqueIdAndProductIdNotifier.value?.item1 ??
        lastLocalPurchase?.purchaseId);
  }

  Future<String?> queryLastPurchaseID() async {
    try {
      await FlutterInappPurchase.instance.initialize();
      final purchases =
          await FlutterInappPurchase.instance.getAvailablePurchases();
      if (purchases?.isNotEmpty == true) {
        purchases
            ?.sort((a, b) => a.transactionDate!.compareTo(b.transactionDate!));
        if (Platform.isAndroid) {
          final id = purchases!.last.transactionId;
          log('Android - Last Purchase ID Found: $id', name: 'StoreKit');
          return id;
        } else {
          final id = purchases!.last.originalTransactionIdentifierIOS;
          log('IOS - Last Purchase ID Found: $id', name: 'StoreKit');
          return id;
        }
      } else {
        return null;
      }
    } catch (e) {
      log('Not found any purchases', name: 'StoreKit');
      return null;
    }
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
    bool forceRestore = false,
    bool enableTimeOut = false,
    VoidCallback? onTimeOut,
    VoidCallback? onSuccessfullyRestored,
  }) async {
    _isSuccessfullyRestored = false;
    final lastPurchase = LocalStorage().lastLocalPurchase;
    if (lastPurchase != null && !forceRestore) {
      final isOutdated = _isPurchaseOutdated(
          lastPurchase.purchasedDateInMillisecond.toString(),
          lastPurchase.productId);
      if (!isOutdated) {
        log('Restored premium successfully from local storage',
            name: 'StoreKit');
        // Notify
        premiumPublishSub.add(true);
        onSuccessfullyRestored != null ? onSuccessfullyRestored() : null;
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

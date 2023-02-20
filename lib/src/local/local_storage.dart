import 'dart:developer';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../admob/entity/ads_counter.dart';
import '../store/entity/local_purchase_entity.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  LocalStorage._internal();
  factory LocalStorage() => _instance;

  Box? _box;

  init() async {
    // Hive
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
    Hive.registerAdapter(LocalPurchaseEntityAdapter());
    _box = await Hive.openBox("StoreKit");
  }

  setLastLocalPurchase(LocalPurchaseEntity? localPurchaseEntity) async {
    log('setLastLocalPurchase', name: 'LocalStorage');
    return _box?.put("_kLastLocalPurchase", localPurchaseEntity);
  }

  LocalPurchaseEntity? get lastLocalPurchase => _box?.get("_kLastLocalPurchase");

  AdsCounter? get adsCounter => _box?.get("_kAdsCounter");

  Future<void> setAdsCounter(AdsCounter adsCounter) async {
    return _box?.put("_kAdsCounter", adsCounter);
  }
}

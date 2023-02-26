import 'dart:convert';
import 'dart:developer';
import 'package:base_kits/base_kits.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static final LocalStorage _instance = LocalStorage._internal();
  LocalStorage._internal();
  factory LocalStorage() => _instance;

  late SharedPreferences prefs;

  init() async {
    prefs = await SharedPreferences.getInstance();
  }

  setLastLocalPurchase(LocalPurchaseEntity? localPurchaseEntity) async {
    log('setLastLocalPurchase', name: 'LocalStorage');
    if (localPurchaseEntity != null) {
      await prefs.setString(
          "_kLastLocalPurchase", jsonEncode(localPurchaseEntity.toJson()));
    }
  }

  LocalPurchaseEntity? get lastLocalPurchase {
    final data = prefs.getString("_kLastLocalPurchase");
    if (data != null) {
      return LocalPurchaseEntity.fromJson(jsonDecode(data));
    }
    return null;
  }

  AdsCounter? get adsCounter {
    final data = prefs.getString("_kAdsCounter");
    if (data != null) {
      return AdsCounter.fromJson(jsonDecode(data));
    }
    return null;
  }

  Future<void> setAdsCounter(AdsCounter adsCounter) async {
    log('setAdsCounter', name: 'LocalStorage');
    await prefs.setString("_kAdsCounter", jsonEncode(adsCounter.toJson()));
  }
}

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

  RatingEntity? get ratingEntity {
    final data = prefs.getString("_kRatingEntity");
    if (data != null) {
      return RatingEntity.fromJson(jsonDecode(data));
    }
    return null;
  }

  setLastRatingEntity(RatingEntity? ratingEntity) async {
    log('setLastRatingEntity', name: 'LocalStorage');
    if (ratingEntity != null) {
      await prefs.setString(
          "_kRatingEntity", jsonEncode(ratingEntity.toJson()));
    }
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
      final result = jsonDecode(data);
      return LocalPurchaseEntity.fromJson(result);
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

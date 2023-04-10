import 'dart:developer';

import 'package:base_kits/src/local/local_storage.dart';
import 'package:in_app_review/in_app_review.dart';

import 'package:json_annotation/json_annotation.dart';

part 'rating_manager.g.dart';

@JsonSerializable()
class RatingEntity {
  bool isRequested;
  int lastRequestedDateInMilliseconds;
  RatingEntity({
    this.isRequested = false,
    required this.lastRequestedDateInMilliseconds,
  });

  factory RatingEntity.fromJson(Map<String, dynamic> json) =>
      _$RatingEntityFromJson(json);

  Map<String, dynamic> toJson() => _$RatingEntityToJson(this);

  DateTime get lastRequestedDate =>
      DateTime.fromMillisecondsSinceEpoch(lastRequestedDateInMilliseconds);
}

class RatingManager {
  static final RatingManager _instance = RatingManager._internal();
  RatingManager._internal();
  factory RatingManager() => _instance;

  final InAppReview _inAppReview = InAppReview.instance;

  static const _afterNDay = 3;

  Future<void> requestRating() async {
    try {
      if (!await _inAppReview.isAvailable()) {
        return;
      }
      final lastRating = LocalStorage().ratingEntity;
      if (lastRating == null) {
        await _inAppReview.requestReview();
        LocalStorage().setLastRatingEntity(
          RatingEntity(
            isRequested: true,
            lastRequestedDateInMilliseconds:
                DateTime.now().millisecondsSinceEpoch,
          ),
        );
      } else {
        final diff =
            lastRating.lastRequestedDate.difference(DateTime.now()).inDays;
        if (diff % _afterNDay == 0 && !lastRating.isRequested) {
          await _inAppReview.requestReview();
          LocalStorage().setLastRatingEntity(
            lastRating
              ..isRequested = true
              ..lastRequestedDateInMilliseconds =
                  DateTime.now().millisecondsSinceEpoch,
          );
        } else {
          LocalStorage().setLastRatingEntity(lastRating..isRequested = false);
        }
      }
    } catch (e) {
      log(e.toString());
    }
  }
}

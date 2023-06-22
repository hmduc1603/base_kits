import 'package:in_app_review/in_app_review.dart';

import '../../base_kits.dart';

class ReviewManager {
  static final ReviewManager _instance = ReviewManager._internal();
  ReviewManager._internal();
  factory ReviewManager() => _instance;

  final InAppReview _inAppReview = InAppReview.instance;

  Future<void> requestReview(String appstoreId) async {
    AnalyticKit().logEvent(
      name: "request_review",
    );
    _inAppReview.openStoreListing(appStoreId: appstoreId);
  }
}

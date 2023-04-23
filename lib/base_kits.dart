library base_kits;

import 'package:base_kits/src/local/local_storage.dart';

export 'src/analysis/analytic_kit.dart';
export 'src/store/store_kit.dart';
export 'package:in_app_purchase/in_app_purchase.dart';
export 'src/admob/entity/ad_config.dart';
export 'src/admob/admob_kit.dart';
export 'src/counting/base_limit_counting.dart';
export 'src/admob/entity/ad_limitation.dart';
export 'src/admob/entity/ads_counter.dart';
export 'src/store/entity/local_purchase_entity.dart';
export 'src/rating/rating_manager.dart';
export 'src/store/entity/subscription_tracking.dart';
export '/src/support/support_manager.dart';
export '/src/admob/widgets/banner_ad_widget.dart';
export '/src/util/form_util.dart';
export '/src/util/number_util.dart';
export '/src/util/string_util.dart';

class BaseKits {
  static final BaseKits _instance = BaseKits._internal();
  BaseKits._internal();
  factory BaseKits() => _instance;

  init() async {
    await LocalStorage().init();
  }
}

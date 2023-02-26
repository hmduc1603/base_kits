abstract class BaseLimitCounting<L, C> {
  late L _limitation;
  L get limitation => _limitation;

  setUpLimitation(L limitation) {
    _limitation = limitation;
  }

  checkShouldProceed(
      {required Function(bool shouldProceed, C? counter) onShouldProceed});

  increaseCounter({C? counter});
}

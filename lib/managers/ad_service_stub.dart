//Web/desktop no-op implementation of AdService. AdMob is mobile-only, so on
//other platforms init does nothing and showRewardedAd reports no reward earned.
class AdService {
  Future<void> init() async {}

  Future<bool> showRewardedAd() async => false;
}

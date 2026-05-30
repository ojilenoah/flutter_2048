import 'dart:async';
import 'dart:io' show Platform;

import 'package:google_mobile_ads/google_mobile_ads.dart';

//Real AdService backed by AdMob. Uses Google's sample ad unit IDs so the app
//can be tested without a real AdMob account; swap in your real unit IDs from
//admob.google.com before releasing.
class AdService {
  RewardedAd? _ad;
  bool _loading = false;
  bool _initialized = false;

  //Google's sample/test rewarded ad unit IDs.
  static const String _testRewardedAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIOS =
      'ca-app-pub-3940256099942544/1712485313';

  String get _adUnitId =>
      Platform.isIOS ? _testRewardedIOS : _testRewardedAndroid;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await MobileAds.instance.initialize();
    _load();
  }

  void _load() {
    if (_loading || _ad != null) return;
    _loading = true;
    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loading = false;
        },
        onAdFailedToLoad: (_) {
          _ad = null;
          _loading = false;
        },
      ),
    );
  }

  Future<bool> showRewardedAd() async {
    if (_ad == null) {
      //No ad ready yet — kick off a load so it's ready next time.
      _load();
      return false;
    }
    final completer = Completer<bool>();
    final ad = _ad!;
    _ad = null;
    bool earned = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _load();
        if (!completer.isCompleted) completer.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _load();
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    ad.show(onUserEarnedReward: (_, __) {
      earned = true;
    });
    return completer.future;
  }
}

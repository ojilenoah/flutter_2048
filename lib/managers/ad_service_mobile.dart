import 'dart:async';
import 'dart:io' show Platform;

import 'package:google_mobile_ads/google_mobile_ads.dart';

//Real AdService backed by AdMob. Uses the project's real ad unit IDs from
//admob.google.com. iOS is still on a test unit ID until a separate iOS app
//is created in the AdMob console.
class AdService {
  RewardedAd? _ad;
  Completer<RewardedAd?>? _loadCompleter;
  bool _initialized = false;

  static const String _rewardedAndroid =
      'ca-app-pub-7688079183268135/6737681197';
  //iOS still uses Google's sample/test ad unit ID — replace when you create
  //a separate iOS app + rewarded ad unit in the AdMob console.
  static const String _testRewardedIOS =
      'ca-app-pub-3940256099942544/1712485313';

  String get _adUnitId =>
      Platform.isIOS ? _testRewardedIOS : _rewardedAndroid;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    await MobileAds.instance.initialize();
    _load();
  }

  void _load() {
    if (_loadCompleter != null || _ad != null) return;
    final completer = Completer<RewardedAd?>();
    _loadCompleter = completer;
    RewardedAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _loadCompleter = null;
          if (!completer.isCompleted) completer.complete(ad);
        },
        onAdFailedToLoad: (_) {
          _ad = null;
          _loadCompleter = null;
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );
  }

  Future<bool> showRewardedAd() async {
    //If no ad is ready yet, wait for the in-flight load (or kick one off)
    //instead of failing immediately — that way users don't have to tap twice.
    if (_ad == null) {
      if (_loadCompleter == null) _load();
      final ad = await _loadCompleter!.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
      if (ad == null) return false;
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

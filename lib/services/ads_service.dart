import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  BannerAd? _bannerAd;
  RewardedAd? _rewardedAd;

  String get bannerUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111' // Test banner
      : 'ca-app-pub-3940256099942544/2934735716'; // Test banner iOS

  String get rewardedUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917' // Test rewarded
      : 'ca-app-pub-3940256099942544/1712485313'; // Test rewarded iOS

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }

  Future<BannerAd?> loadBanner(VoidCallback onUpdate) async {
    final ad = BannerAd(
      adUnitId: bannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onUpdate(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onUpdate();
        },
      ),
    );
    await ad.load();
    _bannerAd = ad;
    return _bannerAd;
  }

  BannerAd? get bannerAd => _bannerAd;

  Future<void> loadRewarded() async {
    await RewardedAd.load(
      adUnitId: rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (error) => _rewardedAd = null,
      ),
    );
  }

  Future<bool> showRewarded({required VoidCallback onEarned}) async {
    final ad = _rewardedAd;
    if (ad == null) return false;
    bool rewarded = false;
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) async {
        ad.dispose();
        _rewardedAd = null;
        await loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, error) async {
        ad.dispose();
        _rewardedAd = null;
        await loadRewarded();
      },
    );
    ad.show(
      onUserEarnedReward: (_, __) {
        rewarded = true;
        onEarned();
      },
    );
    return rewarded;
  }

  void dispose() {
    _bannerAd?.dispose();
    _rewardedAd?.dispose();
  }
}

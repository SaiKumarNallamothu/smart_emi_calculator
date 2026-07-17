import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._privateConstructor();
  static final AdService instance = AdService._privateConstructor();

  // Provided Ad Unit IDs
  static const String _bannerAdId = 'ca-app-pub-9215767386390942/6585553203';
  static const String _interstitialAdId = 'ca-app-pub-9215767386390942/4054190414';
  static const String _rewardedIntAdId = 'ca-app-pub-9215767386390942/5834175942';
  static const String _rewardedAdId = 'ca-app-pub-9215767386390942/1894930931';
  static const String _nativeAdId = 'ca-app-pub-9215767386390942/6721284577';
  static const String _appOpenAdId = 'ca-app-pub-9215767386390942/4137950894';

  // Getters for external usage (using test IDs in debug mode is highly recommended to avoid policy violations)
  String get bannerAdUnitId => kDebugMode ? 'ca-app-pub-3940256099942544/6300978111' : _bannerAdId;
  String get interstitialAdUnitId => kDebugMode ? 'ca-app-pub-3940256099942544/1033173712' : _interstitialAdId;
  String get rewardedIntAdUnitId => kDebugMode ? 'ca-app-pub-3940256099942544/5354046379' : _rewardedIntAdId;
  String get rewardedAdUnitId => kDebugMode ? 'ca-app-pub-3940256099942544/5224354917' : _rewardedAdId;
  String get nativeAdUnitId => kDebugMode ? 'ca-app-pub-3940256099942544/2247696110' : _nativeAdId;
  String get appOpenAdUnitId => kDebugMode ? 'ca-app-pub-3940256099942544/9257395921' : _appOpenAdId;

  // Ad References
  AppOpenAd? _appOpenAd;
  bool _isShowingAppOpenAd = false;
  DateTime? _appOpenAdLoadTime;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoading = false;
  DateTime? _lastInterstitialShowTime;

  RewardedAd? _rewardedAd;
  bool _isRewardedAdLoading = false;

  /// Initializes the Google Mobile Ads SDK.
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    // Preload App Open and Interstitial ads
    loadAppOpenAd();
    loadInterstitialAd();
    loadRewardedAd();
  }

  // ==========================================
  // APP OPEN AD
  // ==========================================

  void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _appOpenAdLoadTime = DateTime.now();
        },
        onAdFailedToLoad: (error) {
          debugPrint('AppOpenAd failed to load: $error');
        },
      ),
    );
  }

  bool get _isAppOpenAdAvailable {
    if (_appOpenAd == null || _appOpenAdLoadTime == null) return false;
    // App open ads are valid for up to 4 hours
    return DateTime.now().difference(_appOpenAdLoadTime!).inHours < 4;
  }

  void showAppOpenAdIfAvailable() {
    if (_isShowingAppOpenAd) {
      return;
    }

    if (!_isAppOpenAdAvailable) {
      loadAppOpenAd();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAppOpenAd = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAppOpenAd = false;
        ad.dispose();
        _appOpenAd = null;
        loadAppOpenAd();
      },
    );

    _appOpenAd!.show();
  }

  // ==========================================
  // INTERSTITIAL AD
  // ==========================================

  void loadInterstitialAd() {
    if (_isInterstitialAdLoading || _interstitialAd != null) return;
    _isInterstitialAdLoading = true;

    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('InterstitialAd failed to load: $error');
          _isInterstitialAdLoading = false;
          _interstitialAd = null;
        },
      ),
    );
  }

  /// Shows interstitial ad if available and throttle limit is passed.
  void showInterstitialAd({VoidCallback? onAdClosed}) {
    // Implement standard throttling (e.g., minimum 20 seconds between ads)
    final now = DateTime.now();
    if (_lastInterstitialShowTime != null &&
        now.difference(_lastInterstitialShowTime!).inSeconds < 20) {
      onAdClosed?.call();
      return;
    }

    if (_interstitialAd == null) {
      loadInterstitialAd();
      onAdClosed?.call();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _lastInterstitialShowTime = DateTime.now();
        loadInterstitialAd();
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onAdClosed?.call();
      },
    );

    _interstitialAd!.show();
  }

  // ==========================================
  // REWARDED AD
  // ==========================================

  void loadRewardedAd() {
    if (_isRewardedAdLoading || _rewardedAd != null) return;
    _isRewardedAdLoading = true;

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
          _isRewardedAdLoading = false;
          _rewardedAd = null;
        },
      ),
    );
  }

  void showRewardedAd({required OnUserEarnedRewardCallback onUserEarnedReward, VoidCallback? onAdClosed}) {
    if (_rewardedAd == null) {
      loadRewardedAd();
      onAdClosed?.call();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
        onAdClosed?.call();
      },
    );

    _rewardedAd!.show(onUserEarnedReward: onUserEarnedReward);
  }


  // ==========================================
  // BANNER AD HELPER
  // ==========================================

  BannerAd createBannerAd({
    required AdSize size,
    required VoidCallback onAdLoaded,
    required Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onAdLoaded(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onAdFailedToLoad(ad, error);
        },
      ),
    );
  }
}

/// A standard widget to show a Banner Ad in the app.
class AdBannerWidget extends StatefulWidget {
  final AdSize adSize;

  const AdBannerWidget({
    super.key,
    this.adSize = AdSize.banner,
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = AdService.instance.createBannerAd(
      size: widget.adSize,
      onAdLoaded: () {
        if (mounted) {
          setState(() {
            _isLoaded = true;
          });
        }
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint('BannerAd failed to load: $error');
      },
    );
    _bannerAd?.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null) {
      return SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return const SizedBox.shrink();
  }
}

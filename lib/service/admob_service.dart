import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:reactionRate/config/config.dart';

class AdmobService {
  // 배너 광고
  static String? get bannerAdUnitId {
    if (Platform.isAndroid) {
      return Config.bannerAosId;
    } else if (Platform.isIOS) {
      return Config.bannerIosId;
    }
    return null;
  }

  static final BannerAdListener bannerAdListener = BannerAdListener(
    onAdLoaded: (ad) => debugPrint('ad loaded'),
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
      debugPrint('ad fail $error');
    },
    onAdOpened: (ad) => debugPrint('ad open'),
    onAdClosed: (ad) => debugPrint('ad close'),
  );
}

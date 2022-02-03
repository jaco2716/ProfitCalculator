import 'package:flutter/services.dart';
import 'package:profit_calculator/InAppPurchase/components.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../Model/EnvironmentConfig.dart' as config;

class PurchaseHandler {

  Future<void> initPlatformState() async {
    appData.isPro = false;

    await Purchases.setDebugLogsEnabled(false);
    await Purchases.setup(config.revenuecatApiKey);
    // await Purchases.setup("tsZsqXbTbbzAZavjqlWhKLUwPtCkkJtP");

    PurchaserInfo purchaserInfo;
    try {
      purchaserInfo = await Purchases.getPurchaserInfo();
      if (purchaserInfo.entitlements.all['all_features'] != null) {
        appData.isPro = purchaserInfo.entitlements.all['all_features'].isActive;
      }
      else {
        appData.isPro = false;
      }
    } on PlatformException catch (e) {
      print(e);
    }

    print('#### is user pro? ${appData.isPro}');
  }
}
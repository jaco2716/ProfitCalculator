import 'package:flutter/services.dart';
import 'package:profit_calculator/InAppPurchase/components.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../Model/EnvironmentConfig.dart' as config;

class PurchaseHandler {
  Future<void> initPurchaseState() async {
    appData.isPro = false;

    await Purchases.setDebugLogsEnabled(false);
    await Purchases.setup(config.revenuecatApiKey);

    PurchaserInfo purchaserInfo;
    Purchases.addPurchaserInfoUpdateListener((info) {
      setProStatus(info);
      print('### Purchaseinfo updated!...:${info.activeSubscriptions}');
      print('### Is user pro? ${appData.isPro}');
    });

    try {
      purchaserInfo = await Purchases.getPurchaserInfo();
      setProStatus(purchaserInfo);
    } on PlatformException catch (e) {
      print(e);
    }

    print('### Is user pro? ${appData.isPro}');
  }

  setProStatus(PurchaserInfo purchaserInfo) {
    if (purchaserInfo.entitlements.all['all_features'] != null) {
      appData.isPro = purchaserInfo.entitlements.all['all_features'].isActive;
    } else {
      appData.isPro = false;
    }
  }
}

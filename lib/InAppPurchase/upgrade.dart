
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:profit_calculator/MyWidgets/MyAlertDialog.dart';
import 'package:profit_calculator/MyWidgets/MyAppBarWithCalc.dart';
import 'package:profit_calculator/MyWidgets/MyLoadingCircle.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'IAPwidgets.dart';
import 'components.dart';

PurchaserInfo _purchaserInfo;

class UpgradeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  Offerings _offerings;
  String _fetchErrorMessage;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    PurchaserInfo purchaserInfo;
    try {
      purchaserInfo = await Purchases.getPurchaserInfo();
    } on PlatformException catch (e) {
      print('purchaser info error: ${e.message}');
      if (e.details['underlyingErrorMessage'] != null) _fetchErrorMessage = e.details['underlyingErrorMessage'];
    }

    Offerings offerings;
    try {
      offerings = await Purchases.getOfferings();
    } on PlatformException catch (e) {
      print('Offering get error: ${e.details['underlyingErrorMessage']}');
      if (e.details['underlyingErrorMessage'] != null) _fetchErrorMessage = e.details['underlyingErrorMessage'];
    }
    if (!mounted) return;

    setState(() {
      _purchaserInfo = purchaserInfo;
      _offerings = offerings;
    });
  }

  @override
  Widget build(BuildContext context) {
    // if (_purchaserInfo == null) {
    //   return Scaffold(appBar: MyAppBarWithCalc('Premium'), body: Center(child: MyLoadingCircle(100)));
    // } else {
    //   if (_purchaserInfo.entitlements.all.isNotEmpty && _purchaserInfo.entitlements.all['all_features'].isActive != null) {
    //     appData.isPro = _purchaserInfo.entitlements.all['all_features'].isActive;
    //   } else {
    //     appData.isPro = false;
    //   }
    // appData.isPro = false;
    if (appData.isPro) {
      return ProScreen();
    } else {
      return UpsellScreen(
        offerings: _offerings,
        fetchErrorMessage: _fetchErrorMessage,
      );
    }
    // }
  }
}

class UpsellScreen extends StatefulWidget {
  final Offerings offerings;
  final String fetchErrorMessage;

  UpsellScreen({Key key, @required this.offerings, @required this.fetchErrorMessage}) : super(key: key);

  @override
  _UpsellScreenState createState() => _UpsellScreenState();
}

class _UpsellScreenState extends State<UpsellScreen> {
  // _launchURLWebsite(String zz) async {
  //   if (await canLaunch(zz)) {
  //     await launch(zz);
  //   } else {
  //     throw 'Could not launch $zz';
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    if (widget.offerings != null) {
      final offering = widget.offerings.current;
      if (offering != null) {
        final monthly = offering.monthly;
        final yearly = offering.annual;
        // final lifetime = offering.lifetime;
        if (monthly != null && yearly != null) {
          return _upsellPage(true, monthly: monthly, yearly: yearly);
        }
      }
    }
    return _upsellPage(false);
  }

  Widget _upsellPage(bool canPurchase, {Package monthly, Package yearly}) {
    return Scaffold(
        appBar: MyAppBarWithCalc('Premium'),
        body: Container(
          // height: 500,
          // color: Colors.blue,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Image.asset(
                'assets/images/PremiumBanner.jpg',
              ),
              Flexible(
                child: ListView(children: [
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    'Upgrade to Premium',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.orange[500]),
                    textAlign: TextAlign.center,
                  ),
                  canPurchase
                      ? InkWell(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              'Restore Purchase',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          onTap: () => _restorePurchase(),
                        )
                      : SizedBox(height: 20),
                  Divider(height: 8),
                  FeaturesListTile(
                      icon: Icons.star,
                      title: 'Unlimited',
                      subtitle: 'Create and analyse unlimited extras, meals, menus, and caterings.',
                      infoTile: false),
                  Divider(height: 8),
                  FeaturesListTile(
                      icon: Icons.support_agent,
                      title: 'Support',
                      subtitle: 'Get support from the team at Wejeo if you have problems or even if you have feature suggestions.',
                      infoTile: false),
                ]),
              ),
              Divider(height: 8),
              canPurchase
                  ? Column(
                      children: [
                        PurchaseButton(package: monthly, purchaseEntitlement: 'all_features', leadingString: 'Buy for', trailingString: '/ Month'),
                        SizedBox(height: 8),
                        PurchaseButton(package: yearly, purchaseEntitlement: 'all_features', leadingString: 'Buy for', trailingString: '/ Year'),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Something went wrong.\n',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Please check that your device is connected to the internet, allowed to make purchases and try again. Contact us at Support@wejeo.dk if the problem persists.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
              PrivacyAndTerms('Recurring subscription, cancel anytime. Read the '),
            ],
          ),
        ));
  }

  Future<Widget> _restorePurchase() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Container(child: MyLoadingCircle(70)), behavior: SnackBarBehavior.floating, width: 100),
    );

    try {
      PurchaserInfo restoredInfo = await Purchases.restoreTransactions();
      print('restore info:   s--- ${restoredInfo.entitlements.toString()}');
      appData.isPro = restoredInfo.entitlements.all["all_features"].isActive;
      if (!appData.isPro) {
        appData.isPro = restoredInfo.entitlements.all["all_features_lifetime"].isActive;
      }
      print('is user pro? ${appData.isPro}');

      if (appData.isPro) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) {
            return MyAlertDialog(
              title: 'Congratulations',
              content: 'Your purchase has been restored!',
              cancelText: 'Ok',
              infoDialog: true,
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return MyAlertDialog(
              title: 'Error',
              content: 'There was an error finding your purchase. Please try again later.',
              cancelText: 'Ok',
              infoDialog: true,
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return MyAlertDialog(
            title: 'Error',
            content: 'There was an error finding your purchase. Please try again later.',
            cancelText: 'Ok',
            infoDialog: true,
          );
        },
      );
    }
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    return UpgradeScreen();
  }
}

class PurchaseButton extends StatefulWidget {
  final Package package;
  final String purchaseEntitlement;
  final String leadingString;
  final String trailingString;

  PurchaseButton({
    Key key,
    @required this.package,
    @required this.purchaseEntitlement,
    @required this.leadingString,
    @required this.trailingString,
  }) : super(key: key);

  @override
  _PurchaseButtonState createState() => _PurchaseButtonState();
}

class _PurchaseButtonState extends State<PurchaseButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: Colors.orange,
            padding: EdgeInsets.all(0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () => _purchaseSubscription(),
          child: Container(
            padding: EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: <Color>[
                    Colors.orange[400],
                    Colors.yellow[600],
                    // Colors.yellow[400],
                    Colors.orange[300],
                  ],
                ),
                borderRadius: BorderRadius.circular(10)
                // shape:
                ),
            child: Text(
              '${widget.leadingString} ${widget.package.product.priceString} ${widget.trailingString}',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Future<Widget> _purchaseSubscription() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Container(child: MyLoadingCircle(70)), behavior: SnackBarBehavior.floating, width: 100),
    );
    try {
      _purchaserInfo = await Purchases.purchasePackage(widget.package);
      print('PurchaserInfo: ');
      print(_purchaserInfo);
      appData.isPro = _purchaserInfo.entitlements.all[widget.purchaseEntitlement].isActive;
      print('Is active: ');
      print(_purchaserInfo.entitlements.all[widget.purchaseEntitlement].isActive);
      print('is user pro? ${appData.isPro}');

      if (appData.isPro) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) {
            return MyAlertDialog(
              title: 'Congratulations',
              content: 'Well done, you now have full access to the app.',
              cancelText: 'Ok',
              infoDialog: true,
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return MyAlertDialog(
              title: 'Error',
              content: 'There was an error. Please try again later.',
              cancelText: 'Ok',
              infoDialog: true,
            );
          },
        );
      }
    } on PlatformException catch (e) {
      var errorCode = PurchasesErrorHelper.getErrorCode(e);
      print('Error: $errorCode');
      String errorString = '';
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        // errorString = '\n\nError message: User cancelled.';
        return UpgradeScreen();
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        errorString = '\n\nError message: User not allowed to purchase.';
      }

      showDialog(
        context: context,
        builder: (context) {
          return MyAlertDialog(
            title: 'Error',
            content: 'There was an error completing purchase. Please try again later.\n$errorString',
            cancelText: 'Ok',
            infoDialog: true,
          );
        },
      );
    }
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    return UpgradeScreen();
  }
}

class ProScreen extends StatefulWidget {
  @override
  State<ProScreen> createState() => _ProScreenState();
}

class _ProScreenState extends State<ProScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBarWithCalc('Premium'),
        body: Column(
          children: <Widget>[
            Image.asset(
              'assets/images/PremiumBanner.jpg',
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: ListView(children: [
                  SizedBox(height: 15),
                  Text(
                    'Premium Member',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.orange[500]),
                    textAlign: TextAlign.center,
                  ),
                  InkWell(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'Reset Purchase (Testing only)',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    onTap: () => _resetPurchase(),
                  ),
                  // SizedBox(height: 15),
                  Divider(height: 8),
                  FeaturesListTile(
                      icon: Icons.star, title: 'You are a Premium member', subtitle: 'You can use the app in all its functionality.', infoTile: true),
                  FeaturesListTile(
                      icon: Icons.info,
                      title: 'Cancel subscription',
                      subtitle: 'To cancel a subscription go to your application store subscriptions.',
                      infoTile: true),
                  FeaturesListTile(
                      icon: Icons.support_agent,
                      title: 'Support',
                      subtitle: 'Please e-mail us at Support@wejeo.dk if you have any problem.',
                      infoTile: true),
                  SizedBox(height: 200)
                ]),
              ),
            ),
            Divider(height: 8),
            PrivacyAndTerms('Read the '),
          ],
        ));
  }

  Future<Widget> _resetPurchase() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Container(child: MyLoadingCircle(70)), behavior: SnackBarBehavior.floating, width: 100),
    );

    try {
      PurchaserInfo restoredInfo = await Purchases.reset();
      appData.isPro = false;
      print('is user pro? ${appData.isPro}');

      if (!appData.isPro) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) {
            return MyAlertDialog(
              title: 'Done',
              content: 'Reset complete',
              cancelText: 'Ok',
              infoDialog: true,
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return MyAlertDialog(
              title: 'Error',
              content: 'There was an error resetting. Please try again later.',
              cancelText: 'Ok',
              infoDialog: true,
            );
          },
        );
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return MyAlertDialog(
            title: 'Error',
            content: 'There was an error. Please try again later.\nError: $e',
            cancelText: 'Ok',
            infoDialog: true,
          );
        },
      );
    }
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    return UpgradeScreen();
  }
}
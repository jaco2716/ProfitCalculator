import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:profit_calculator/MyWidgets/MyAlertDialog.dart';
import 'package:profit_calculator/MyWidgets/MyAppBarWithCalc.dart';
import 'package:profit_calculator/MyWidgets/MyLoadingCircle.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'components.dart';
import 'package:url_launcher/url_launcher.dart';

PurchaserInfo _purchaserInfo;

class UpgradeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  Offerings _offerings;

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
      print(e);
    }

    Offerings offerings;
    try {
      offerings = await Purchases.getOfferings();
    } on PlatformException catch (e) {
      print(e);
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
    //   return Scaffold(appBar: MyAppBarWithCalc('Upgrade'), body: Center(child: MyLoadingCircle(100)));
    // } else {
    //   if (_purchaserInfo.entitlements.all.isNotEmpty && _purchaserInfo.entitlements.all['all_features'].isActive != null) {
    //     appData.isPro = _purchaserInfo.entitlements.all['all_features'].isActive;
    //   } else {
    //     appData.isPro = false;
    //   }
    if (appData.isPro) {
      return ProScreen();
    } else {
      return UpsellScreen(
        offerings: _offerings,
      );
    }
    // }
  }
}

class UpsellScreen extends StatefulWidget {
  final Offerings offerings;

  UpsellScreen({Key key, @required this.offerings}) : super(key: key);

  @override
  _UpsellScreenState createState() => _UpsellScreenState();
}

class _UpsellScreenState extends State<UpsellScreen> {
  _launchURLWebsite(String zz) async {
    if (await canLaunch(zz)) {
      await launch(zz);
    } else {
      throw 'Could not launch $zz';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.offerings != null) {
      final offering = widget.offerings.current;
      if (offering != null) {
        final monthly = offering.monthly;
        if (monthly != null) {
          return Scaffold(
              appBar: MyAppBarWithCalc('Upgrade'),
              body: Center(
                child: SingleChildScrollView(
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: PurchaseButton(package: monthly),
                    ),
                    ElevatedButton(
                      child: Text('Restore Purchase'),
                      onPressed: () => _restorePurchase(),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _launchURLWebsite('https://google.com');
                      },
                      child: Text('Privacy Policy (click to read)'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _launchURLWebsite('https://yahoo.com');
                      },
                      child: Text('Term of Use (click to read)'),
                    ),
                  ],
                )),
              ));
        }
      }
    }
    return Scaffold(
        appBar: MyAppBarWithCalc('Upgrade'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 100.0,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "There was an error. Please check that your device is allowed to make purchases and try again. Please contact us at Support@wejeo.dk if the problem persists.",
                  textAlign: TextAlign.center,
                ),
              ),
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
      appData.isPro = restoredInfo.entitlements.all["all_features"].isActive;
      print('is user pro? ${appData.isPro}');

      if (appData.isPro) {
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
              content: 'There was an error finding your purchase. Please try again later',
              cancelText: 'Ok',
              infoDialog: true,
            );
          },
        );
      }
    } on PlatformException catch (e) {
      print('Error: ${PurchasesErrorHelper.getErrorCode(e).toString()}');
      showDialog(
        context: context,
        builder: (context) {
          return MyAlertDialog(
            title: 'Error',
            content: 'There was an error. Please try again later',
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

  PurchaseButton({Key key, @required this.package}) : super(key: key);

  @override
  _PurchaseButtonState createState() => _PurchaseButtonState();
}

class _PurchaseButtonState extends State<PurchaseButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(padding: EdgeInsets.all(30)),
                onPressed: () => _purchaseSubscription(),
                child: Text(
                  'Buy ${widget.package.product.title}\n${widget.package.product.priceString}',
                  style: TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 18.0),
              child: Text(
                '${widget.package.product.description}',
                textAlign: TextAlign.center,
              ),
            )
          ],
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
      appData.isPro = _purchaserInfo.entitlements.all["all_features"].isActive;
      print('is user pro? ${appData.isPro}');

      if (appData.isPro) {
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (context) {
            return MyAlertDialog(
              title: 'Congratulations',
              content: 'Well done, you now have full access to the app',
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
              content: 'There was an error. Please try again later',
              cancelText: 'Ok',
              infoDialog: true,
            );
          },
        );
      }
    } on PlatformException catch (e) {
      print('Error: ${PurchasesErrorHelper.getErrorCode(e).toString()}');
      showDialog(
        context: context,
        builder: (context) {
          return MyAlertDialog(
            title: 'Error',
            content: 'There was an error completing purchase. Please try again later',
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

class ProScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MyAppBarWithCalc('Upgrade'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Icon(
                  Icons.star,
                  color: Colors.yellow[800],
                  size: 100.0,
                ),
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  child: Text(
                    "You are a Pro user.\n\nYou can use the app in all its functionality.\nPlease e-mail us at Support@wejeo.dk if you have any problem.",
                    textAlign: TextAlign.center,
                  )),
              SizedBox(height: 200)
            ],
          ),
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:profit_calculator/InAppPurchase/upgrade.dart';
import 'package:profit_calculator/MyWidgets/ElementListWidgets/ElementListTile.dart';

class UpgradeToSeeItems extends StatelessWidget {
  final void Function(void Function()) thisState;
  const UpgradeToSeeItems({this.thisState});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(
          opacity: 0.5,
          child: ElementListTile(element: {
            'title': '________________',
            'subtitle': '________\n_____\n____\n___',
            'trailing1': 75.0,
            'trailing2': 100,
          }, myOnPressed: null),
        ),
        Align(
            alignment: Alignment.center,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                    builder: (context) => UpgradeScreen(),
                  ))
                      .then((context) {
                    thisState(() {});
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 5),
                  child: Text(
                    'Upgrade to Premium\nto see all of your items',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ))),
      ],
    );
  }
}

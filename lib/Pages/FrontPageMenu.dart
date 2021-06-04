import 'package:flutter/material.dart';
import 'package:profit_calculator/InAppPurchase/parental_gate.dart';
import 'package:profit_calculator/InAppPurchase/upgrade.dart';

import 'package:profit_calculator/MyWidgets/FrontPageWidgets/MyGridMenuButton.dart';
import 'package:profit_calculator/MyWidgets/MyIconButton.dart';
import 'package:profit_calculator/Pages/CateringPages/CateringListPage.dart';
import 'package:profit_calculator/Pages/MenuPages/MenuListPage.dart';
import 'package:profit_calculator/Pages/VideoAppGuidePage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../Pages/VATChangePage.dart';
import 'BackupAndRestore/BackupAndRestorePage.dart';
import 'ExtraPages/ExtraListPage.dart';
import 'IngredientPages/IngredientList.dart';
import 'MealPages/MealListPage.dart';

class FrontPageMenu extends StatefulWidget {
  @override
  _FrontPageMenuState createState() => _FrontPageMenuState();
}

class _FrontPageMenuState extends State<FrontPageMenu> {
  @override
  Widget build(BuildContext context) {
    // double gridSpacingPadding = 10;
    print(MediaQuery.of(context).size.height);
    double gridSpacingPadding = MediaQuery.of(context).size.aspectRatio < 0.5 ? 15 : 2;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                height: gridSpacingPadding * 5,
                color: Colors.blue,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    color: Colors.blue,
                    child: GridView.count(
                      padding: EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 15),
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      crossAxisCount: 2,
                      children: [
                        MyGridMenuButton(title: 'Extras', index: 2, icon: Icons.liquor, onTap: () => _goToPage(ExtraListPage())),
                        MyGridMenuButton(title: 'Meals', index: 3, icon: Icons.lunch_dining, onTap: () => _goToPage(MealListPage())),
                        MyGridMenuButton(title: 'Menus', index: 4, icon: Icons.fastfood, onTap: () => _goToPage(MenuListPage())),
                        MyGridMenuButton(title: 'Catering', index: 5, icon: Icons.food_bank_rounded, onTap: () => _goToPage(CateringListPage())),
                      ],
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                    ),
                  ),
                  Container(
                    height: 160,
                    width: 160,
                    child: MyGridMenuButton(
                      title: 'Ingredients',
                      index: 1,
                      icon: Icons.tapas,
                      // round: true,
                      // buttonColor: Colors.lightBlue[700],
                      // contentColor: Colors.white,
                      onTap: () => _goToPage(IngredientList()),
                    ),
                  ),
                ],
              ),
              Container(
                height: gridSpacingPadding,
                color: Colors.blue,
                margin: EdgeInsets.only(bottom: 8 + gridSpacingPadding),
              ),
              MyIconButton(
                  tileIcon: Icon(Icons.star), tileTitle: 'Upgrade', buttonColor: Colors.blue[600], myOnPressed: () => _goToPage(UpgradeScreen())),
              MyIconButton(
                  tileIcon: Icon(Icons.attach_money),
                  tileTitle: 'Set VAT, Currency &\nHourly rate',
                  buttonColor: Colors.blue[600],
                  myOnPressed: () => _goToPage(VATChangePage())),
              MyIconButton(
                  tileIcon: Icon(Icons.settings),
                  tileTitle: 'Backup & Restore',
                  buttonColor: Colors.blue[600],
                  myOnPressed: () => _goToPage(BackupAndRestore())),
              MyIconButton(
                  tileIcon: Icon(Icons.help),
                  tileTitle: 'App Guide \n(Placeholder video)',
                  buttonColor: Colors.blueGrey[800],
                  myOnPressed: () => _goToPage(VideoAppGuidePage())),
              MyIconButton(
                  tileIcon: Icon(Icons.info),
                  tileTitle: 'Contact Support',
                  buttonColor: Colors.blueGrey[800],
                  myOnPressed: () => _launchURL('https://wejeo.dk/#Contact')),
              SizedBox(height: 5),
            ],
          ),
        ),
      ),
    );
  }

  void _goToPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  void _launchURL(String _url) async {
    await canLaunch(_url) ? await launch(_url) : print('Could not launch $_url');
  }
}

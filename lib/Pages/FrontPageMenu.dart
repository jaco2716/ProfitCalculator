import 'package:flutter/material.dart';
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
    double gridSpacingPadding = MediaQuery.of(context).size.aspectRatio < 0.5 ? 15 : 2;
    double menuIconPadding = MediaQuery.of(context).size.aspectRatio < 0.5 ? 15 : 22;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: <Widget>[
              Container(
                height: (gridSpacingPadding - 1) * 5,
                color: Colors.blue,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    color: Colors.blue,
                    child: GridView.count(
                      padding: EdgeInsets.only(top: 15, bottom: 15, left: menuIconPadding, right: menuIconPadding),
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
                      onTap: () => _goToPage(IngredientList()),
                    ),
                  ),
                ],
              ),
              SizedBox(height: (gridSpacingPadding + 8)),
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
                  tileTitle: 'App Guide',
                  buttonColor: Colors.blueGrey[800],
                  myOnPressed: () => _goToPage(VideoAppGuidePage())),
              Container(
                width: 310,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 230,
                      child: MyIconButton(
                          compact: true,
                          leftalign: true,
                          tileIcon: Icon(Icons.info),
                          tileTitle: 'Contact Support',
                          buttonColor: Colors.blueGrey[800],
                          myOnPressed: () => _launchURL('https://wejeo.dk/#Contact')),
                    ),
                    Container(
                      width: 70,
                      height: 70,
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        elevation: 2,
                        color: Colors.orange[500],
                        child: IconButton(
                          onPressed: () => _goToPage(UpgradeScreen()),
                          icon: Icon(Icons.star, color: Colors.white, size: 35),
                        ),
                      ),
                    )
                  ],
                ),
              ),
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

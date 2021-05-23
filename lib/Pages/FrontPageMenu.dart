import 'package:flutter/material.dart';

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
                      padding: EdgeInsets.only(top: 20, bottom: 20, left: 30, right: 30),
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20,
                      crossAxisCount: 2,
                      children: [
                        MyGridMenuButton(
                            // contentColor: Colors.orange,
                            title: 'Ingredients',
                            icon: Icons.tapas,
                            onTap: () => _goToPage(IngredientList())),
                        MyGridMenuButton(
                            title: 'Extras',
                            icon: Icons.liquor,
                            // contentColor: Colors.teal,
                            onTap: () => _goToPage(ExtraListPage())),
                        MyGridMenuButton(
                            title: 'Meals',
                            icon: Icons.lunch_dining,
                            // contentColor: Colors.purple,
                            onTap: () => _goToPage(MealListPage())),
                        MyGridMenuButton(
                            title: 'Menus',
                            icon: Icons.fastfood,
                            // contentColor: Colors.deepOrange,
                            onTap: () => _goToPage(MenuListPage())),
                      ],
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                    ),
                  ),
                  Container(
                    height: 130,
                    width: 130,
                    child: MyGridMenuButton(
                      title: 'Catering',
                      icon: Icons.food_bank_rounded,
                      round: true,
                      buttonColor: Colors.lightBlue[700],
                      contentColor: Colors.white,
                      onTap: () => _goToPage(CateringListPage()),
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

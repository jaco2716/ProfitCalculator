import 'package:flutter/material.dart';
import 'package:profit_calculator/IngredientPages/IngredientList.dart';
import 'package:profit_calculator/MealPages/MealList.dart';
import 'package:profit_calculator/BackupAndRestore/BackupAndRestorePage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'ExtraListPage.dart';
import 'VATChangePage.dart';

class FrontPageMenu extends StatelessWidget {
  const FrontPageMenu({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: ListView(
        children: <Widget>[
//Show user at top of app drawer
          // UserAccountsDrawerHeader(
          //   currentAccountPicture: CircleAvatar(child: Icon(Icons.person),),
          //   accountEmail: Text('Guest e-mail'),
          //   accountName: Text('Guest'),
          // ),
          // Container(
          //   padding: const EdgeInsets.only(top:50.0),
          //   child: Center(child: Icon(Icons.accessibility_new, size: 80, color: Colors.blue,),),
          // ),
          Container(
            padding: EdgeInsets.all(20),
          ),
          // drawerListTile(Icon(Icons.add), "Create Ingredient",
          //     CreateIngredient(), context),
          // drawerListTile(Icon(Icons.add), "Create Meal", CreateMeal(), context),

          drawerListTile(
            Icon(Icons.list),
            "Ingredients",
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => IngredientList()));
            },
          ),
          drawerListTile(
            Icon(Icons.list),
            "Drinks & Extras",
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ExtraListPage()));
            },
          ),
          drawerListTile(
            Icon(Icons.list),
            "Meals",
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MealList(true)));
            },
          ),
          drawerListTile(
            Icon(Icons.list),
            "Menus",
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => MealList(false)));
            },
          ),
          Divider(),
          drawerListTile(Icon(Icons.attach_money), "Set VAT & Currency",
              onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => VATChangePage()));
          }, color: Colors.blue[800]),
          // Divider(),
          drawerListTile(Icon(Icons.settings), "Backup & Restore", onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => BackupAndRestore()));
          }, color: Colors.blue[800]),
          Divider(),
          drawerListTile(Icon(Icons.info), "Contact Support",
              onTap: () => _launchURL(), color: Colors.blueGrey[700]),

          // drawerListTile(Icon(Icons.show_chart), "Charts", ChartPage(), context),

          SizedBox(height: 400),
        ],
      ),
    );
  }

  void _launchURL() async {
    String _url = 'https://wejeo.dk/#Contact';
    await canLaunch(_url) ? await launch(_url) : print('Could not launch $_url');
  }

//List tile for every page to go to.
  Widget drawerListTile(Icon _tileIcon, String _tileTitle,
      {void Function() onTap, Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Theme(
        data: ThemeData.dark(),
        child: Card(
          color: color == null ? Colors.blue : color,
          child: ListTile(
              leading: _tileIcon,
              title: Text(_tileTitle),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () => onTap()),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:profit_calculator/CreateIngredient.dart';
import 'package:profit_calculator/CreateMeal.dart';
import 'package:profit_calculator/IngredientList.dart';
import 'package:profit_calculator/MealList.dart';
import 'package:profit_calculator/SettingsPage.dart';

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
          Container(
            padding: const EdgeInsets.only(top:50.0),
            child: Center(child: Icon(Icons.accessibility_new, size: 80, color: Colors.blue,),),
          ),
          Container(
            padding: EdgeInsets.all(30),
            child: Center(child: Text('Welcome', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w200,)))),
          drawerListTile(Icon(Icons.list), "All Ingredients", IngredientList(), context),
          drawerListTile(Icon(Icons.list), "All Meals", MealList(), context),
          Divider(),
          drawerListTile(Icon(Icons.add), "Create Ingredient", CreateIngredient(), context),
          // Divider(),
          drawerListTile(Icon(Icons.add), "Create Meal", CreateMeal(), context),
          Divider(),
          drawerListTile(Icon(Icons.settings), "Settings", SettingsPage(), context),
          // drawerListTile(Icon(Icons.show_chart), "Charts", ChartPage(), context),
          // Divider(),
        ],
      ),
    );
  }

//List tile for every page to go to.
  Widget drawerListTile(Icon _tileIcon, String _tileTitle, Widget _navigationPage, BuildContext context){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Theme(
        data: ThemeData.dark(),
              child: Card(
          color: Colors.blue,
                child: ListTile(
              leading: _tileIcon,
              title: Text(_tileTitle),
              trailing: Icon(Icons.keyboard_arrow_right),
              onTap: () {
                // Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => _navigationPage));
              }),
        ),
      ),
    );
  }
}
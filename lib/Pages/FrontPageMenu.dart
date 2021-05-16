import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';
import 'package:profit_calculator/Pages/VideoAppGuidePage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../MyWidgets/MyLoadingCircle.dart';
import '../Pages/VATChangePage.dart';
import 'BackupAndRestore/BackupAndRestorePage.dart';
import 'ExtraPages/ExtraListPage.dart';
import 'IngredientPages/IngredientList.dart';
import 'MealPages/MealList.dart';

class FrontPageMenu extends StatefulWidget {
  @override
  _FrontPageMenuState createState() => _FrontPageMenuState();
}

class _FrontPageMenuState extends State<FrontPageMenu> {
  final SharedValueHandler _sharedValueHandler = SharedValueHandler();

  GlobalKey futureKey = GlobalKey();

  reset() async {
    await _sharedValueHandler.saveIntSharedP(0, 'newUser');
  }

  @override
  Widget build(BuildContext context) {
    // reset();

    // print('apsect ratio:');
    // print(MediaQuery.of(context).size.aspectRatio);
    double gridPadding =
        MediaQuery.of(context).size.aspectRatio < 0.5 ? 80 : 50;
    return SingleChildScrollView(
      child: FutureBuilder(
          key: futureKey,
          future: _sharedValueHandler.getIntSharedP('newUser', 0),
          builder: (context, newUserSnapshot) {
            if (newUserSnapshot.connectionState == ConnectionState.waiting) {
              return MyLoadingCircle(500);
            }
            if (newUserSnapshot.data == 0) {
              return Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height,
                color: Colors.blue,
                // margin: EdgeInsets.symmetric(vertical: 300),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 100, bottom: 20),
                      child: Text(
                        'Welcome',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 50,
                            fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        'Please watch our guide on how to use the app.',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                            fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // drawerListTile(
                    //     Icon(Icons.help), "App Guide \n(Placeholder video)",
                    //     onTap: () {
                    //   Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //           builder: (context) => VideoAppGuidePage()));
                    // }, color: Colors.blueGrey[700]),
                    Container(
                      margin: EdgeInsets.all(50),
                      width: 180,
                      height: 180,
                      // padding: const EdgeInsets.all(8.0),
                      child: gridListTile('App Guide', Icons.help,
                          onTap: () async {
                        await _sharedValueHandler.saveIntSharedP(1, 'newUser');
                        Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VideoAppGuidePage()))
                            .then((value) {
                          setState(() {});
                        });
                      }),
                    ),
                    // Text('hehehe'),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue[400], // background
                          onPrimary: Colors.white, // foreground
                        ),
                        onPressed: () async {
                          await _sharedValueHandler.saveIntSharedP(
                              1, 'newUser');
                          setState(() {});
                        },
                        child: Text(
                          'Watch Later',
                          style: TextStyle(fontSize: 20),
                        ))
                  ],
                ),
              );
            }
            return Container(
              // padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: <Widget>[
                  Container(
                    // padding: EdgeInsets.symmetric(horizontal: gridPadding),
                    color: Colors.blue,
                    child: GridView.count(
                      padding: EdgeInsets.only(
                          top: gridPadding, bottom: 30, left: 40, right: 40),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      crossAxisCount: 2,
                      children: [
                        gridListTile('Ingredients', Icons.tapas, onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => IngredientList()));
                        }),
                        gridListTile('Extras', Icons.liquor, onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ExtraListPage()));
                        }),
                        gridListTile('Meals', Icons.lunch_dining, onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MealList(true)));
                        }),
                        gridListTile('Menus', Icons.fastfood, onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MealList(false)));
                        }),
                      ],
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                    ),
                  ),
                  // drawerListTile(
                  //   Icon(Icons.local_dining),
                  //   "Ingredients",
                  //   onTap: () {
                  //     Navigator.push(context,
                  //         MaterialPageRoute(builder: (context) => IngredientList()));
                  //   },
                  // ),
                  // drawerListTile(
                  //   //emoji_food_beverage
                  //   Icon(Icons.liquor),
                  //   "Extras",
                  //   onTap: () {
                  //     Navigator.push(context,
                  //         MaterialPageRoute(builder: (context) => ExtraListPage()));
                  //   },
                  // ),
                  // drawerListTile(
                  //   Icon(Icons.lunch_dining),
                  //   "Meals",
                  //   onTap: () {
                  //     Navigator.push(context,
                  //         MaterialPageRoute(builder: (context) => MealList(true)));
                  //   },
                  // ),
                  // drawerListTile(
                  //   Icon(Icons.fastfood),
                  //   "Menus",
                  //   onTap: () {
                  //     Navigator.push(context,
                  //         MaterialPageRoute(builder: (context) => MealList(false)));
                  //   },
                  // ),
                  // Divider(),
                  Padding(padding: EdgeInsets.all(10)),
                  drawerListTile(Icon(Icons.attach_money),
                      "Set VAT, Currency & Hourly rate", onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VATChangePage()));
                  }, color: Colors.blue[800]),
                  // Divider(),
                  drawerListTile(Icon(Icons.settings), "Backup & Restore",
                      onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BackupAndRestore()));
                  }, color: Colors.blue[800]),
                  // Divider(),
                  drawerListTile(
                      Icon(Icons.help), "App Guide \n(Placeholder video)",
                      onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => VideoAppGuidePage()));
                  }, color: Colors.blueGrey[700]),
                  drawerListTile(Icon(Icons.info), "Contact Support",
                      onTap: () => _launchURL('https://wejeo.dk/#Contact'),
                      color: Colors.blueGrey[700]),
                  SizedBox(height: 20),
                ],
              ),
            );
          }),
    );
  }

  void _launchURL(String _url) async {
    await canLaunch(_url)
        ? await launch(_url)
        : print('Could not launch $_url');
  }

  Widget gridListTile(String title, IconData icon, {void Function() onTap}) {
    return InkWell(
      onTap: () => onTap(),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: Colors.grey[900],
        // shadowColor: Colors.black,
        elevation: 10,
        // color: Colors.blue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.blue,
              size: 50,
            ),
            Text(title,
                style: TextStyle(
                    color: Colors.blue,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget drawerListTile(Icon _tileIcon, String _tileTitle,
      {void Function() onTap, Color color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
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

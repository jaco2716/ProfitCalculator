import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';
import 'package:profit_calculator/MyWidgets/MyIconButton.dart';
import 'package:profit_calculator/Pages/MenuPages/MenuListPage.dart';
import 'package:profit_calculator/Pages/VideoAppGuidePage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../MyWidgets/MyLoadingCircle.dart';
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
              return firstTimeLoadingWidget();
            }
            return Container(
              // padding: EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: <Widget>[
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        // padding: EdgeInsets.symmetric(horizontal: gridPadding),
                        color: Colors.blue,
                        child: GridView.count(
                          padding: EdgeInsets.only(
                              top: gridPadding,
                              bottom: 30,
                              left: 30,
                              right: 30),
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          crossAxisCount: 2,
                          children: [
                            gridListTile(
                              // contentColor: Colors.pink,
                                title: 'Ingredients',
                                icon: Icons.tapas,
                                onTap: () {
                                  _goToPage(IngredientList());
                                  // Navigator.push(
                                  //     context,
                                  //     MaterialPageRoute(
                                  //         builder: (context) =>
                                  //             IngredientList()));
                                }),
                            gridListTile(
                                title: 'Extras',
                                icon: Icons.liquor,
                                // contentColor: Colors.teal,
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              ExtraListPage()));
                                }),
                            gridListTile(
                                title: 'Meals',
                                icon: Icons.lunch_dining,
                                // contentColor: Colors.purple,
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MealListPage()));
                                }),
                            gridListTile(
                                title: 'Menus',
                                icon: Icons.fastfood,
                                // contentColor: Colors.deepOrange,
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MenuListPage()));
                                }),
                          ],
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(top: 50),
                        height: 180,
                        width: 130,
                        child: gridListTile(
                          title: 'Catering',
                          icon: Icons.food_bank_rounded,
                          round: true,
                          buttonColor: Colors.lightBlue[700],
                          contentColor: Colors.white,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MenuListPage()));
                          },
                        ),
                      ),
                    ],
                  ),
                  Padding(padding: EdgeInsets.all(10)),
                  MyIconButton(
                      tileIcon: Icon(Icons.attach_money),
                      tileTitle: 'Set VAT, Currency &\nHourly rate',
                      buttonColor: Colors.blue[600],
                      myOnPressed: () => _goToPage(VATChangePage())),
                  // drawerListTile(Icon(Icons.attach_money),
                  //     "Set VAT, Currency & Hourly rate", onTap: () {
                  //   Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) => VATChangePage()));
                  // }, color: Colors.blue[800]),
                  // Divider(),
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

                  // drawerListTile(Icon(Icons.settings), "Backup & Restore",
                  //     onTap: () {
                  //   Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) => BackupAndRestore()));
                  // }, color: Colors.blue[800]),
                  // Divider(),
                  // drawerListTile(
                  //     Icon(Icons.help), "App Guide \n(Placeholder video)",
                  //     onTap: () {
                  //   Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) => VideoAppGuidePage()));
                  // }, color: Colors.blueGrey[700]),
                  MyIconButton(
                      tileIcon: Icon(Icons.info),
                      tileTitle: 'Contact Support',
                      buttonColor: Colors.blueGrey[800],
                      myOnPressed: () =>
                          _launchURL('https://wejeo.dk/#Contact')),
                  // drawerListTile(Icon(Icons.info), "Contact Support",
                  //     onTap: () => _launchURL('https://wejeo.dk/#Contact'),
                  //     color: Colors.blueGrey[700]),
                  SizedBox(height: 20),
                ],
              ),
            );
          }),
    );
  }

  Widget firstTimeLoadingWidget() {
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
            child: gridListTile(
                title: 'App Guide',
                icon: Icons.help,
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
                await _sharedValueHandler.saveIntSharedP(1, 'newUser');
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

  Widget gridListTile(
      {@required String title,
      @required IconData icon,
      @required void Function() onTap,
      Color buttonColor = Colors.white,
      Color contentColor = Colors.blue,
      bool round = false}) {
    return InkWell(
      onTap: () => onTap(),
      child: Card(
        color: buttonColor,
        shape: RoundedRectangleBorder(
          borderRadius:
              round ? BorderRadius.circular(90) : BorderRadius.circular(20),
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
              color: contentColor,
              size: 50,
            ),
            Padding(
              padding: round
                  ? const EdgeInsets.only(bottom: 12)
                  : EdgeInsets.only(bottom: 5),
              child: Text(title,
                  style: TextStyle(
                      color: contentColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ),
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

  void _goToPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }

  void _launchURL(String _url) async {
    await canLaunch(_url)
        ? await launch(_url)
        : print('Could not launch $_url');
  }
}

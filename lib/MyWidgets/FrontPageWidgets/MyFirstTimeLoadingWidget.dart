import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/SharedValueHandler.dart';
import 'package:profit_calculator/MyWidgets/FrontPageWidgets/MyGridMenuButton.dart';
import 'package:profit_calculator/MyWidgets/InitialFutureWidget.dart';
import 'package:profit_calculator/Pages/FrontPageMenu.dart';
import 'package:profit_calculator/Pages/VideoAppGuidePage.dart';

class MyFirstTimeLoadingWidget extends StatelessWidget {
  // final void Function(Function()) setState;

  // MyFirstTimeLoadingWidget(this.setState);
  final SharedValueHandler _sharedValueHandler = SharedValueHandler();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                style: TextStyle(color: Colors.white, fontSize: 50, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Please watch our guide on how to use the app.',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              margin: EdgeInsets.all(50),
              width: 180,
              height: 180,
              child: MyGridMenuButton(
                  title: 'App Guide',
                  icon: Icons.help,
                  onTap: () async {
                    await _sharedValueHandler.saveIntSharedP(1, 'newUser');
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FrontPageMenu(),
                        ));
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoAppGuidePage(),
                        ));
                  }),
            ),
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue[400], // background
                  onPrimary: Colors.white, // foreground
                ),
                onPressed: () async {
                  await _sharedValueHandler.saveIntSharedP(1, 'newUser');

                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FrontPageMenu(),
                      ));
                },
                child: Text(
                  'Watch Later',
                  style: TextStyle(fontSize: 20),
                ))
          ],
        ),
      ),
    );
  }
}

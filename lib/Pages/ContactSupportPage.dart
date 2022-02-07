import 'dart:io';
import 'package:flutter/material.dart';
import 'package:profit_calculator/InAppPurchase/components.dart';
import 'package:profit_calculator/MyWidgets/MyAppBarWithCalc.dart';
import 'package:profit_calculator/MyWidgets/MyIconButton.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactSupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: MyAppBarWithCalc('Contact Support'),
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 80),
              Icon(
                Icons.email,
                color: Colors.white,
                size: 50,
              ),
              SizedBox(height: 10),
              Text(
                'Support@Wejeo.dk',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400, color: Colors.grey[100]),
              ),
              SizedBox(height: 10),
              MyIconButton(tileIcon: Icon(Icons.email), tileTitle: "Open your e-mail app", myOnPressed: () => _sendEmail()),
              SizedBox(height: 10),
              Text('Or', style: TextStyle(color: Colors.white),),
              SizedBox(height: 10),
              MyIconButton(tileIcon: Icon(Icons.public), tileTitle: "Our website contact form", myOnPressed: () => _launchURL('https://wejeo.dk/#Contact')),
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _launchURL(String _url) async {
    await canLaunch(_url) ? await launch(_url, forceSafariVC: false) : print('Could not launch $_url');
  }

  void _sendEmail() async {
    String isPremium = appData.isPro ? "Pro" : "NP";
    String appInfo = "\n\n\nDevice: ${Platform.operatingSystem}: ${Platform.operatingSystemVersion}. $isPremium.";
    print(appInfo);
    final Uri params = Uri(
      scheme: 'mailto',
      path: 'Support@Wejeo.dk',
      query: 'subject=ProfCalculator Support&body=$appInfo',
    );

    var url = params.toString();
    await canLaunch(url) ? await launch(url) : print('Could not launch $url');
  }
}

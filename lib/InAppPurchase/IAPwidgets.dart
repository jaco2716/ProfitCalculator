import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FeaturesListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool infoTile;
  FeaturesListTile({@required this.icon, @required this.title, @required this.subtitle, @required this.infoTile});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.orange,
        child: Icon(
          icon,
          color: Colors.white,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: !infoTile ? Icon(Icons.check) : null,
    );
  }
}

class PrivacyAndTerms extends StatelessWidget {
  final String leadingText;
  PrivacyAndTerms(this.leadingText);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 25, left: 30, right: 30),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Colors.black38),
          children: [
            TextSpan(text: leadingText),
            TextSpan(
              text: 'Privacy Policy',
              style: TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  _launchURLWebsite('https://wejeo.dk/profcalculator-privacy-policy.html');
                },
            ),
            TextSpan(text: ' and '),
            TextSpan(
              text: 'Terms and Conditions.',
              style: TextStyle(color: Colors.blue),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  _launchURLWebsite('https://wejeo.dk/profcalculator-terms-and-conditions.html');
                },
            ),
          ],
        ),
      ),
    );
  }

  _launchURLWebsite(String zz) async {
    if (await canLaunch(zz)) {
      await launch(zz);
    } else {
      throw 'Could not launch $zz';
    }
  }
}

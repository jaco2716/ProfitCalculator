import 'package:flutter/material.dart';

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
      trailing: !infoTile? Icon(Icons.check):null,
    );
  }
}


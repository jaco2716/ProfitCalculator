import 'package:flutter/material.dart';

class SingleElementPriceCard extends StatelessWidget {
  final String _title;
  final String _subtitle;
  final String _trailing;
  final MaterialColor _color;

  SingleElementPriceCard(
    this._title,
    this._subtitle,
    this._trailing,
    this._color,
  );

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _color[50],
      elevation: 5,
      margin: EdgeInsets.symmetric(horizontal: 40, vertical: 5),
      child: Container(
          width: double.infinity,
          child: ListTile(
            visualDensity: _subtitle == null
                ? VisualDensity.standard
                : VisualDensity.compact,
            title: Text(
              _title,
              style: TextStyle(color: _color[700]),
            ),
            subtitle: _subtitle == null
                ? null
                : Text(
                    _subtitle,
                    style: TextStyle(color: Colors.blue[700], fontSize: 12),
                  ),
            trailing: Text(
              _trailing,
              style: TextStyle(color: _color[700]),
            ),
          )),
    );
  }
}

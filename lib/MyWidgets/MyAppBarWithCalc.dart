import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:profit_calculator/MyWidgets/CalculatorPage.dart';

class MyAppBarWithCalc extends StatelessWidget implements PreferredSizeWidget {
  final String _title;
  final Function actionTapped;
  MyAppBarWithCalc(this._title, {this.actionTapped});

  @override
  Size get preferredSize => const Size.fromHeight(54);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(_title),
      actions: [
        IconButton(
            icon: Icon(CupertinoIcons.plus_slash_minus),
            onPressed: () {
              if(actionTapped != null) actionTapped();
              // Scaffold.of(context).showBottomSheet((context) => CalculatorPage());
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: CalculatorWidget(),
                duration: Duration(hours: 24),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Color(0x00000000),
                elevation: 0,
                margin: EdgeInsets.zero,
              ));
            })
      ],
    );
  }
}

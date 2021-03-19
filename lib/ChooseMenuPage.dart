import 'package:flutter/material.dart';
import 'package:profit_calculator/MyAppBarWithCalc.dart';

class ChooseMenuPage extends StatelessWidget {
  const ChooseMenuPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBarWithCalc('Change Menu'),
      body: Container(
        width: double.infinity,
        // color: Colors.amber,
        padding: EdgeInsets.all(20),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Here you can change what menu you are currently using, and allows you to edit menus individually.',
                textAlign: TextAlign.center,
              ),
            ),
            saveSlotButton('Save Slot 1', '01/10/2021'),
            saveSlotButton('Save Slot 2', '01/27/2021'),
            saveSlotButton('Save Slot 3', '02/03/2021'),
            saveSlotButton('Save Slot 4', '02/17/2021'),
            saveSlotButton('Save Slot 5', '02/27/2021'),
          ],
        ),
      ),
    );
  }

  Widget saveSlotButton(String title, String dateLastSaved) {
    return Container(
      padding: EdgeInsets.all(10),
      width: 250,
      height: 80,
      // padding: EdgeInsets.all(20),
      // margin: EdgeInsets.all(20),
      child: ElevatedButton.icon(
        style: ButtonStyle(),
        icon: Icon(Icons.save),
        label: Text('$title \nLast save: $dateLastSaved'),
        onPressed: () {},
      ),
    );
  }
}

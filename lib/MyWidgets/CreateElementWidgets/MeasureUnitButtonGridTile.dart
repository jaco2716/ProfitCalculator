import 'package:flutter/material.dart';

class MeasureUnitButtonGrid extends StatelessWidget {
  final String tempChosenUnit;
  final List<String> dropDownValues;
  final void Function(String) changeToValue;

  MeasureUnitButtonGrid({
    @required this.tempChosenUnit,
    @required this.dropDownValues,
    @required this.changeToValue,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.blue,
      width: 200,
      height: 60,
      padding: EdgeInsets.only(top: 10),
      child: GridView.count(
        physics: NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        children: dropDownValues.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: MeasureUnitButtonGridTile(
              changeToValue: changeToValue,
              unit: value,
              tempChosenUnit: tempChosenUnit,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class MeasureUnitButtonGridTile extends StatelessWidget {
  final String unit;
  final String tempChosenUnit;
  final void Function(String) changeToValue;

  const MeasureUnitButtonGridTile({
    @required this.unit,
    @required this.tempChosenUnit,
    @required this.changeToValue,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      curve: Curves.decelerate,
      duration: Duration(milliseconds: 200),
      padding: EdgeInsets.all(unit == tempChosenUnit ? 0 : 5),
      child: InkWell(
        onTap: () => changeToValue(unit),
        child: Card(
          margin: EdgeInsets.all(0),
          color: unit == tempChosenUnit ? Colors.blue : Colors.blue[100],
          child: Center(
              child: Text(
            unit,
            style: TextStyle(
                color: unit == tempChosenUnit ? Colors.white : Colors.white),
          )),
        ),
      ),
    );
  }
}

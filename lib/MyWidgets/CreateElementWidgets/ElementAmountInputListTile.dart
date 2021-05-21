import 'package:flutter/material.dart';

class ElementAmountInputListTile extends StatefulWidget {
  final dynamic element;
  final void Function(int) myOnAmountChange;
  final void Function() myOnPressed;

  ElementAmountInputListTile({
    @required this.element,
    @required this.myOnAmountChange,
    @required this.myOnPressed,
  });

  @override
  _ElementAmountInputListTileState createState() =>
      _ElementAmountInputListTileState();
}

class _ElementAmountInputListTileState
    extends State<ElementAmountInputListTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
          title: Text(widget.element.name),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            IconButton(
                icon: Icon(Icons.remove),
                onPressed: () => widget.myOnAmountChange(-1)),
            Text('${widget.element.amount}'),
            IconButton(
                icon: Icon(Icons.add),
                onPressed: () => widget.myOnAmountChange(1)),
            Container(
              width: 15,
              height: 30,
              child: IconButton(
                iconSize: 15,
                icon: Icon(Icons.close),
                onPressed: () => widget.myOnPressed()
                  // _onElementSelected(
                  //     false, ltMeal.id, setModalState, _selectedMeals, meals);
                
              ),
            )
          ])),
    );
  }
}

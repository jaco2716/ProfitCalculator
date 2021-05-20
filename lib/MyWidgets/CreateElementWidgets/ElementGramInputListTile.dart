import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profit_calculator/Model/Ingredient.dart';

class ElementGramInputListTile extends StatefulWidget {
  final Ingredient ingredient;
  // final void Function(void Function()) setModalState;
  final void Function() myOnPressed;
  final void Function(String) myOnChanged;

  ElementGramInputListTile({
    @required this.ingredient,
    @required this.myOnPressed,
    @required this.myOnChanged,

    // @required this.setModalState,
  });

  @override
  _ElementGramInputListTileState createState() =>
      _ElementGramInputListTileState();
}

class _ElementGramInputListTileState extends State<ElementGramInputListTile> {
  @override
  Widget build(BuildContext context) {
    List<String> amountNoDot =
        widget.ingredient.amountInGrams?.toString()?.split('.');
    TextEditingController tec = TextEditingController(
        text: widget.ingredient.amountInGrams?.toString() ?? '');
    if (amountNoDot != null) {
      tec = TextEditingController(text: amountNoDot[0] ?? '');
    }
    return Card(
      child: ListTile(
          title: Text(widget.ingredient.name),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
                padding: EdgeInsets.all(5),
                width: 80,
                child: TextField(
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
                    ],
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                    controller: tec,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(), counterText: ''),
                    onChanged: (value) => widget.myOnChanged(value))),
            Text(widget.ingredient.measureUnit == 'Kg' ? ' g ' : 'ml'),
            Container(
              width: 20,
              child: IconButton(
                  iconSize: 15,
                  icon: Icon(Icons.close),
                  onPressed: () => widget.myOnPressed()),
            )
          ])),
    );
  }
}

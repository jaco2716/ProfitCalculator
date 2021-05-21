import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/CreateElementLogic.dart';
import 'package:profit_calculator/MyWidgets/CreateElementWidgets/ElementAmountInputListTile.dart';
import 'package:profit_calculator/MyWidgets/CreateElementWidgets/ElementGramInputListTile.dart';
import 'package:profit_calculator/MyWidgets/MyIconButton.dart';

class AddElementModule extends StatelessWidget {
  final List<dynamic> selectedElement;
  final List<dynamic> allElements;
  final String title;
  final bool wGramInput;
  final void Function(Function()) setState;
  AddElementModule({
    @required this.selectedElement,
    @required this.allElements,
    @required this.title,
    @required this.setState,
    this.wGramInput = false,
  });
  final CreateElementLogic _createElementLogic = CreateElementLogic();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        itemListTitle('$title:', 'No ${title.toLowerCase()} added.',
            selectedElement.length),
        Container(
          child: ListView.builder(
            padding: EdgeInsets.all(0),
            itemCount: selectedElement.length,
            itemBuilder: (BuildContext context, int index) {
              if (wGramInput) {
                return ElementGramInputListTile(
                    ingredient: selectedElement[index],
                    myOnPressed: () => _createElementLogic.onElementSelected(
                        false,
                        selectedElement[index].id,
                        setState,
                        selectedElement,
                        allElements),
                    myOnChanged: (value) =>
                        _createElementLogic.setIngredientAmount(
                            value, selectedElement[index].id, selectedElement));
              } else {
                return ElementAmountInputListTile(
                    element: selectedElement[index],
                    myOnPressed: () => _createElementLogic.onElementSelected(
                        false,
                        selectedElement[index].id,
                        setState,
                        selectedElement,
                        allElements),
                    myOnAmountChange: (value) =>
                        _createElementLogic.changeElementAmount(
                            selectedElement[index],
                            selectedElement,
                            value,
                            setState));
              }
            },
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
          ),
        ),
        MyIconButton(
            tileIcon: Icon(Icons.add),
            buttonColor: Colors.orange,
            compact: true,
            height: 60,
            tileTitle: 'Add $title',
            myOnPressed: () => _createElementLogic.showEditElements(
                context: context,
                setState: setState,
                elements: allElements,
                selectedElements: selectedElement,
                title: '$title')),
        Divider(thickness: 1),
      ],
    );
  }

  Widget itemListTitle(String _title, String _altTitle, int listLenght) {
    return Text(
      listLenght == 0 ? _altTitle : _title,
      style: TextStyle(
          fontSize: 20, color: Colors.grey, fontWeight: FontWeight.w300),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:profit_calculator/Handlers/CreateElementLogic.dart';

class AddElementListTile extends StatelessWidget {
  final dynamic element;
  final Function setModalState;
  final List<dynamic> selectedElements;
  final List<dynamic> allElements;

  AddElementListTile({
    @required this.element,
    @required this.setModalState,
    @required this.selectedElements,
    @required this.allElements,
  });

  final CreateElementLogic _createElementLogic = CreateElementLogic();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: CheckboxListTile(
        title: Text(element.name),
        value: selectedElements.indexWhere((e) => e.id == element.id) != -1,
        onChanged: (bool selected) {
          _createElementLogic.onElementSelected(selected, element.id,
              setModalState, selectedElements, allElements);
        },
      ),
    );
  }
}

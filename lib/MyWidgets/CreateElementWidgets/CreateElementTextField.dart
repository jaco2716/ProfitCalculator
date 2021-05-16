import 'package:flutter/material.dart';

class CreateElementTextField extends StatelessWidget {
  final String myValue;
  final String title;
  final String suffixText;
  final TextEditingController textEditingController;
  final String Function(String) validate;
  final void Function(String) setValue;
  final TextInputType textInputType;
  final bool readOnly;
  final void Function() onTap;

  CreateElementTextField({
    @required this.title,
    @required this.myValue,
    @required this.textEditingController,
    @required this.validate,
    @required this.setValue,
    this.textInputType,
    this.suffixText,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: textEditingController,
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: title,
          suffixText: suffixText,
        ),
        textCapitalization: TextCapitalization.words,
        keyboardType: textInputType,
        validator: (value) => validate(value),
        onSaved: (value) => setValue(value),
        // onFieldSubmitted: (value) => FocusScope.of(context).nextFocus(),
        readOnly: readOnly,
        onTap: onTap,
      ),
    );
  }
}

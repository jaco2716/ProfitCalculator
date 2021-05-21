import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateElementTextField extends StatelessWidget {
  final String myValue;
  final String title;
  final String suffixText;
  final String prefixText;
  final String Function(String) validate;
  final void Function(String) setValue;
  final TextEditingController textEditingController;
  final TextInputType textInputType;
  final String allowedInput;
  final bool readOnly;
  final void Function() onTap;

  CreateElementTextField({
    @required this.title,
    @required this.myValue,
    @required this.validate,
    @required this.setValue,
    this.textEditingController,
    this.textInputType,
    this.suffixText,
    this.prefixText,
    this.allowedInput,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      // padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        controller: textEditingController,
        decoration: InputDecoration(
          prefix: prefixText == null ? null : Text(prefixText),
          border: OutlineInputBorder(),
          labelText: title,
          suffixText: suffixText,
          errorStyle: TextStyle(height: 0.5),
        ),
        inputFormatters: allowedInput != null
            ? <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(allowedInput))
              ]
            : null,
        textCapitalization: TextCapitalization.words,
        keyboardType: textInputType,
        validator: (value) => validate(value),
        onSaved: (value) => setValue(value),
        readOnly: readOnly,
        onTap: onTap,
      ),
    );
  }
}

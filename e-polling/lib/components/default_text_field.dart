import 'package:flutter/material.dart';

import '../constants.dart';

class DefaultTextField extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool? readOnly;

  const DefaultTextField(this.hintText,
      {this.controller, this.validator, Key? key, this.readOnly})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      readOnly: readOnly ?? false,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: grey3),
        ),
        fillColor: Colors.white,
        hintText: hintText,
        hintStyle: TextStyle(color: grey3),
      ),
    );
  }
}

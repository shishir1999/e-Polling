import 'package:e_polling/utils/constants.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String? title;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onPressed;
  const PrimaryButton(
      {Key? key, required this.title, this.padding, required this.onPressed})
      : super(key: key);
  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return kPrimaryColor.withOpacity(0.8);
    }
    return kPrimaryColor;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: MaterialStateProperty.all(
          padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        backgroundColor: MaterialStateProperty.resolveWith(
          (states) => getColor(states),
        ),
      ),
      child: Text(
        title!,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

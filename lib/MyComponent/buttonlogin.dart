import 'package:flutter/material.dart';
import 'package:pdam_mobile/MyComponent/textpoppins.dart';

class ButtonLogin extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final FontWeight fontWeight;
  final double verticalPadding;

  const ButtonLogin({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.green,
    this.textColor = Colors.white,
    this.fontWeight = FontWeight.bold,
    this.verticalPadding = 14,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: EdgeInsets.symmetric(vertical: verticalPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: TextPoppins(
        text: text,
        color: textColor,
        fontWeight: fontWeight,
      ),
    );
  }
}

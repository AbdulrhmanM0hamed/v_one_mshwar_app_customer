import 'package:flutter/material.dart';
import 'package:v_one_mshwar_app_customer/core/themes/constant_colors.dart';

class ReadonlyTextFieldWidget extends StatelessWidget {
  final String title;
  final TextEditingController textController;

  const ReadonlyTextFieldWidget({
    super.key,
    required this.title,
    required this.textController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: TextField(
        controller: textController,
        textInputAction: TextInputAction.done,
        enabled: false,
        style: TextStyle(color: ConstantColors.titleTextColor),
        decoration: InputDecoration(
          hintText: title,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }
}

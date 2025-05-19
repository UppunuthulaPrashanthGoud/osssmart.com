import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/utill/dimensions.dart';
import 'package:flutter_sixvalley_ecommerce/utill/custom_themes.dart';

class CustomToast {
  static void show(BuildContext context, String message, {bool isError = false}) {
    if (!context.mounted) return;

    final snackBar = SnackBar(
      content: Text(
        message,
        style: textRegular.copyWith(color: Colors.white),
        textAlign: TextAlign.center,
      ),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: const Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
} 
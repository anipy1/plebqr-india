import 'package:flutter/material.dart';

class GenericErrorSnackBar extends SnackBar {
  const GenericErrorSnackBar({super.key})
    : super(content: const _GenericErrorSnackBarMessage());
}

class _GenericErrorSnackBarMessage extends StatelessWidget {
  const _GenericErrorSnackBarMessage();

  @override
  Widget build(BuildContext context) {
    return const Text('An error occurred. Please try again.');
  }
}

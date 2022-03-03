import 'package:flutter/material.dart';

class DetailSaveButton extends StatelessWidget {
  const DetailSaveButton({Key? key, required this.onPressedSave})
      : super(key: key);
  final Function()? onPressedSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
      child: ElevatedButton(
        onPressed: onPressedSave,
        child: const Text('Enregister'),
      ),
    );
  }
}

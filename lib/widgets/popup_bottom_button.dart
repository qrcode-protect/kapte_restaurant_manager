import 'package:flutter/material.dart';

class PopupBottomButton extends StatelessWidget {
  const PopupBottomButton({
    Key? key,
    required this.onPressed,
    required this.onSaveData,
  }) : super(key: key);
  final Function()? onPressed;
  final bool onSaveData;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: onSaveData
          ? const SizedBox(
              height: 40,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 40,
                  width: 140,
                  child: ElevatedButton(
                    onPressed: onPressed,
                    child: const Text('Enregistrer'),
                  ),
                ),
              ],
            ),
    );
  }
}

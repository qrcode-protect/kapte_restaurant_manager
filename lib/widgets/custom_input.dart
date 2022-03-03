import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  const CustomInput({
    Key? key,
    this.controller,
    required this.hintText,
    this.minLines,
    this.maxLines = 1,
  }) : super(key: key);

  final TextEditingController? controller;
  final String hintText;
  final int? minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              hintText,
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez saisir une valeur';
              }
              return null;
            },
            controller: controller,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
            ),
            minLines: minLines,
            maxLines: maxLines,
          ),
        ],
      ),
    );
  }
}

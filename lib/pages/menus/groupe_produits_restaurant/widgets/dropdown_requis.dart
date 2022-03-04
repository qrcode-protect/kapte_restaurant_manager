import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapte_cms/pages/menus/groupe_produits_restaurant/groupe_produits_restaurant_detail.dart';

class DropdownRequis extends StatelessWidget {
  const DropdownRequis({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final groupeProduitsDetailState = ref.watch(groupeProduitsDetailProvider);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Choix des éléments',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
            color: Theme.of(context).inputDecorationTheme.fillColor,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: DropdownButton<bool>(
                value: null,
                hint: groupeProduitsDetailState.dropdownValue != null
                    ? groupeProduitsDetailState.dropdownValue!
                        ? const Text('Unique')
                        : const Text('Multiple')
                    : const Text('Choix'),
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem<bool>(
                    value: true,
                    child: Text('Unique'),
                  ),
                  DropdownMenuItem<bool>(
                    value: false,
                    child: Text('Multiple'),
                  )
                ],
                onChanged: (bool? newValue) {
                  ref
                      .read(groupeProduitsDetailProvider)
                      .setDropdownValue(newValue!);
                  ref.read(groupeProduitsDetailProvider).setModification(true);
                },
                isExpanded: true,
              ),
            ),
          ),
        ],
      );
    });
  }
}

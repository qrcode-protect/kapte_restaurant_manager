import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapte_cms/models/categorie/categorie.dart';
import 'package:kapte_cms/pages/menus/menus_restaurant/menu_restaurant_detail.dart';
import 'package:kapte_cms/pages/menus/menus_restaurant/menus_restaurant.dart';
import 'package:kapte_cms/state_management/state_management.dart';

class CategorieDropdown extends StatelessWidget {
  const CategorieDropdown({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final menuDetailState = ref.watch(menuDetailProvider);
        final menuState = ref.watch(menuProvider);
        final appState = ref.watch(appStateProvider);
        return menuState.restaurantMenu != null && appState.utilisateur != null
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Catégorie',
                        style: Theme.of(context).textTheme.headline6,
                      ),
                    ),
                    Container(
                      color: Theme.of(context).inputDecorationTheme.fillColor,
                      height: 56.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('list_restaurant')
                              .doc(appState.utilisateur!.idRestaurant)
                              .collection('categories_menu')
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return const Text('Error');
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                height: 70,
                                width: double.infinity,
                                color: Theme.of(context)
                                    .inputDecorationTheme
                                    .fillColor,
                              );
                            }
                            return DropdownButton<Categorie>(
                              value: null,
                              hint:
                                  menuDetailState.categorieDropdownValue != null
                                      ? Text(menuDetailState
                                          .categorieDropdownValue!.nom!)
                                      : const Text('Choisir la catégorie'),
                              underline: const SizedBox.shrink(),
                              items: snapshot.data!.docs.map((e) {
                                final categorie = Categorie.fromJson(
                                    e.data() as Map<String, dynamic>);
                                return DropdownMenuItem<Categorie>(
                                  value: categorie,
                                  child: Text(categorie.nom!),
                                );
                              }).toList(),
                              onChanged: (Categorie? newValue) {
                                ref
                                    .read(menuDetailProvider)
                                    .setcategorieDropdownValue(newValue);
                                ref
                                    .read(menuDetailProvider)
                                    .setModification(true);
                              },
                              isExpanded: true,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink();
      },
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libertyrestaurant/models/restaurant_menu_categorie/restaurant_menu_categorie.dart';
import 'package:libertyrestaurant/pages/menus/categories_restaurant/categories_restaurant.dart';
import 'package:libertyrestaurant/state_management/state_management.dart';
import 'package:libertyrestaurant/widgets/custom_input.dart';
import 'package:libertyrestaurant/widgets/detail_save_button.dart';

class CategorieRestaurantDetail extends ConsumerStatefulWidget {
  const CategorieRestaurantDetail({Key? key}) : super(key: key);

  @override
  _CategorieRestaurantDetailState createState() =>
      _CategorieRestaurantDetailState();
}

class _CategorieRestaurantDetailState
    extends ConsumerState<CategorieRestaurantDetail> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final categorieState = ref.watch(categorieProvider);
    final appState = ref.watch(appStateProvider);

    return categorieState.restaurantMenuCategorie != null &&
            appState.utilisateur != null
        ? Container(
            decoration: BoxDecoration(
                border: Border(
              left: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            )),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                  title: Text(
                    'Détails',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  centerTitle: false,
                  actions: [
                    DetailSaveButton(
                      onPressedSave: categorieState.modification
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                if (categorieState
                                    .restaurantMenuCategorie!.id.isNotEmpty) {
                                  FirebaseFirestore.instance
                                      .collection('list_restaurant')
                                      .doc(appState.utilisateur!.idRestaurant)
                                      .collection('categories_menu')
                                      .doc(categorieState
                                          .restaurantMenuCategorie!.id)
                                      .update({
                                    'nom': categorieState
                                        .nomCategorieController!.value.text,
                                    'rank': int.parse(categorieState
                                        .rangCategorieController!.value.text),
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'La catégorie ${categorieState.restaurantMenuCategorie!.nom} été modifier'),
                                      backgroundColor: Theme.of(context)
                                          .secondaryHeaderColor,
                                      duration:
                                          const Duration(milliseconds: 500),
                                    ),
                                  );
                                } else {
                                  FirebaseFirestore.instance
                                      .collection('list_restaurant')
                                      .doc(appState.utilisateur!.idRestaurant)
                                      .collection('categories_menu')
                                      .add(
                                        RestaurantMenuCategorie(
                                                id: '',
                                                nom: categorieState
                                                    .nomCategorieController!
                                                    .value
                                                    .text,
                                                rank: int.parse(categorieState
                                                    .rangCategorieController!
                                                    .value
                                                    .text))
                                            .toJson(),
                                      )
                                      .then(
                                    (value) {
                                      FirebaseFirestore.instance
                                          .collection('list_restaurant')
                                          .doc(appState
                                              .utilisateur!.idRestaurant)
                                          .collection('categories_menu')
                                          .doc(value.id)
                                          .update({'id': value.id});
                                    },
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'La catégorie ${categorieState.restaurantMenuCategorie!.nom} été ajouter'),
                                      backgroundColor: Theme.of(context)
                                          .secondaryHeaderColor,
                                      duration:
                                          const Duration(milliseconds: 500),
                                    ),
                                  );
                                  ref.read(categorieProvider).selectedCategorie(
                                      RestaurantMenuCategorie(id: '', nom: ''));
                                }
                                ref
                                    .read(categorieProvider)
                                    .setModification(false);
                              }
                            }
                          : null,
                    ),
                    categorieState.restaurantMenuCategorie!.id.isNotEmpty
                        ? Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: PopupMenuButton(
                              offset: const Offset(0, 56),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  child: const Text("Fermer"),
                                  onTap: () async {
                                    ref
                                        .read(categorieProvider)
                                        .setDrawerValue(false);
                                    ref
                                        .read(categorieProvider)
                                        .selectedCategorie(null);
                                  },
                                ),
                                PopupMenuItem(
                                  child: const Text("Supprimer la catégorie"),
                                  onTap: () async {
                                    await FirebaseFirestore.instance
                                        .collection('list_restaurant')
                                        .doc(appState.utilisateur!.idRestaurant)
                                        .collection('categories_menu')
                                        .doc(categorieState
                                            .restaurantMenuCategorie!.id)
                                        .delete();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'La catégorie ${categorieState.restaurantMenuCategorie!.nom} été supprimer'),
                                        backgroundColor: Theme.of(context)
                                            .secondaryHeaderColor,
                                        duration:
                                            const Duration(milliseconds: 500),
                                      ),
                                    );
                                    ref
                                        .read(categorieProvider)
                                        .selectedCategorie(null);
                                  },
                                ),
                              ],
                              icon: Icon(
                                Icons.more_vert_outlined,
                                color: Theme.of(context).primaryColor,
                              ),
                              tooltip: '',
                            ),
                          )
                        : IconButton(
                            onPressed: () {
                              ref.read(categorieProvider).setDrawerValue(false);
                              ref
                                  .read(categorieProvider)
                                  .selectedCategorie(null);
                            },
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context).primaryColor,
                            ),
                            splashRadius: 15,
                          ),
                  ],
                ),
                body: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      CustomInput(
                        controller: categorieState.rangCategorieController,
                        hintText: 'Rang',
                      ),
                      CustomInput(
                        controller: categorieState.nomCategorieController,
                        hintText: 'Nom de la catégorie',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : const Center(
            child: Text('Selectionnez un élément à modifier'),
          );
  }
}

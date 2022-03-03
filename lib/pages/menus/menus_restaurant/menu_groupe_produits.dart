import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libertyrestaurant/models/restaurant_groupe_produits/restaurant_groupe_produits.dart';
import 'package:libertyrestaurant/models/restautrant_produit/restaurant_produit.dart';
import 'package:libertyrestaurant/pages/menus/menus_restaurant/menu_restaurant_detail.dart';
import 'package:libertyrestaurant/pages/menus/menus_restaurant/menus_restaurant.dart';
import 'package:libertyrestaurant/state_management/state_management.dart';

final menuGroupeDrawerProvider =
    StateNotifierProvider<MenuGroupeDrawerState, bool>((ref) {
  return MenuGroupeDrawerState();
});

class MenuGroupeDrawerState extends StateNotifier<bool> {
  MenuGroupeDrawerState() : super(false);
  void setValue(bool value) {
    state = value;
  }
}

class MenuGroupeProduits extends StatelessWidget {
  const MenuGroupeProduits({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final menuGroupeDrawer = ref.watch(menuGroupeDrawerProvider);
      final menuDetailState = ref.watch(menuDetailProvider);

      final appState = ref.watch(appStateProvider);
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).secondaryHeaderColor,
          centerTitle: false,
          title: Text(
            'Groupes de produits',
            style: Theme.of(context).textTheme.headline5,
          ),
          actions: [
            IconButton(
              onPressed: () {
                ref
                    .read(menuGroupeDrawerProvider.notifier)
                    .setValue(!menuGroupeDrawer);
              },
              icon: Icon(
                Icons.cancel,
                color: Theme.of(context).primaryColor,
              ),
              splashRadius: 15,
              padding: EdgeInsets.zero,
            )
          ],
        ),
        body: appState.utilisateur != null
            ? StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('list_restaurant')
                    .doc(appState.utilisateur!.idRestaurant)
                    .collection('groupe_produits')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error'),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return ListView(
                    children: ListTile.divideTiles(
                      context: context,
                      tiles: snapshot.data!.docs.map(
                        (e) {
                          RestaurantGroupeProduits groupe =
                              RestaurantGroupeProduits.fromJson(
                                  e.data() as Map<String, dynamic>);
                          return Draggable<RestaurantGroupeProduits>(
                            data: groupe,
                            feedback: Container(
                              color: Colors.white,
                              height: 60,
                              width: 300,
                              child: ListTile(
                                title: Text(groupe.nom!),
                                subtitle: Text(groupe.description!),
                                trailing: IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.add_circle,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  splashRadius: 15,
                                ),
                              ),
                            ),
                            child: ListTile(
                              title: Text(groupe.nom!),
                              subtitle: Text(groupe.description!),
                              trailing: Consumer(builder: (context, ref, _) {
                                final restaurantMenu =
                                    ref.watch(menuProvider).restaurantMenu;
                                return Consumer(builder: (context, ref, _) {
                                  final menuState = ref.watch(menuProvider);
                                  return IconButton(
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection('list_restaurant')
                                          .doc(appState
                                              .utilisateur!.idRestaurant)
                                          .collection('menus')
                                          .doc(restaurantMenu!.id)
                                          .collection('groupe_produits')
                                          .add(
                                            RestaurantGroupeProduits(
                                              rank: menuDetailState
                                                      .groupeProduitsLenght +
                                                  1,
                                              id: groupe.id,
                                              nom: groupe.nom,
                                              description: groupe.description,
                                              requis: groupe.requis,
                                            ).toJson(),
                                          )
                                          .then((categorieValue) {
                                        FirebaseFirestore.instance
                                            .collection('list_restaurant')
                                            .doc(appState
                                                .utilisateur!.idRestaurant)
                                            .collection('menus')
                                            .doc(restaurantMenu.id)
                                            .collection('groupe_produits')
                                            .doc(categorieValue.id)
                                            .update({'id': categorieValue.id});
                                        FirebaseFirestore.instance
                                            .collection('list_restaurant')
                                            .doc(appState
                                                .utilisateur!.idRestaurant)
                                            .collection('groupe_produits')
                                            .doc(groupe.id)
                                            .collection('restaurant_produits')
                                            .get()
                                            .then((produitValue) {
                                          if (produitValue.docs.isNotEmpty) {
                                            for (int i = 0;
                                                i < produitValue.docs.length;
                                                i++) {
                                              final produit =
                                                  RestaurantProduit.fromJson(
                                                      produitValue.docs[i]
                                                          .data());
                                              FirebaseFirestore.instance
                                                  .collection('list_restaurant')
                                                  .doc(appState.utilisateur!
                                                      .idRestaurant)
                                                  .collection('menus')
                                                  .doc(menuState
                                                      .restaurantMenu!.id)
                                                  .collection('produits')
                                                  .add(RestaurantProduit(
                                                    id: '',
                                                    nom: produit.nom,
                                                    prix: produit.prix,
                                                    groupeId: categorieValue.id,
                                                  ).toJson())
                                                  .then((value) {
                                                FirebaseFirestore.instance
                                                    .collection(
                                                        'list_restaurant')
                                                    .doc(appState.utilisateur!
                                                        .idRestaurant)
                                                    .collection('menus')
                                                    .doc(menuState
                                                        .restaurantMenu!.id)
                                                    .collection('produits')
                                                    .doc(value.id)
                                                    .update({'id': value.id});
                                              });
                                            }
                                          }
                                        });
                                      });

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Le Groupe ${groupe.nom} été ajouter',
                                          ),
                                          backgroundColor: Theme.of(context)
                                              .secondaryHeaderColor,
                                          duration:
                                              const Duration(milliseconds: 500),
                                        ),
                                      );
                                    },
                                    icon: Icon(
                                      Icons.add_circle,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    splashRadius: 15,
                                  );
                                });
                              }),
                            ),
                          );
                        },
                      ),
                    ).toList(),
                  );
                },
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
      );
    });
  }
}

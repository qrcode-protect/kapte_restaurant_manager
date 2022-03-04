import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapte_cms/models/restautrant_produit/restaurant_produit.dart';
import 'package:kapte_cms/pages/menus/groupe_produits_restaurant/groupes_poduits_restaurant.dart';
import 'package:kapte_cms/state_management/state_management.dart';

final ajouterProduitProvider =
    StateNotifierProvider<AjouterProduitState, bool>((ref) {
  return AjouterProduitState();
});

class AjouterProduitState extends StateNotifier<bool> {
  AjouterProduitState() : super(false);
  void setValue(bool value) {
    state = value;
  }
}

class ListRestaurantProduit extends StatefulWidget {
  const ListRestaurantProduit({
    Key? key,
  }) : super(key: key);

  @override
  _ListRestaurantProduitState createState() => _ListRestaurantProduitState();
}

class _ListRestaurantProduitState extends State<ListRestaurantProduit> {
  TextEditingController nomProduitController = TextEditingController();
  TextEditingController prixProduitController = TextEditingController();
  ScrollController produitlistController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final groupeProduitsState = ref.watch(groupeProduitsProvider);
      final appState = ref.watch(appStateProvider);
      final ajouterProduitState = ref.watch(ajouterProduitProvider);
      return groupeProduitsState.restaurantGroupeProduits != null &&
              appState.utilisateur != null
          ? Expanded(
              flex: 1,
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                  title: Text(
                    'Produits',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  centerTitle: false,
                  actions: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          ref
                              .read(ajouterProduitProvider.notifier)
                              .setValue(!ajouterProduitState);
                        },
                        icon: Icon(
                          !ajouterProduitState
                              ? Icons.add_circle
                              : Icons.remove_circle,
                          color: Theme.of(context).primaryColor,
                          size: 35,
                        ),
                        splashRadius: 25.0,
                        tooltip: 'Ajouter un produit',
                      ),
                    )
                  ],
                ),
                body: ListView(
                  controller: produitlistController,
                  children: [
                    Consumer(builder: (context, ref, _) {
                      return Column(
                        children: [
                          Visibility(
                            visible: ajouterProduitState,
                            child: Container(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              child: ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: TextField(
                                        controller: nomProduitController,
                                        decoration: const InputDecoration(
                                          fillColor: Colors.white,
                                          hoverColor: Colors.white,
                                          border: InputBorder.none,
                                          hintText: 'Nom du produit',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      flex: 2,
                                      child: TextField(
                                        controller: prixProduitController,
                                        decoration: const InputDecoration(
                                          fillColor: Colors.white,
                                          hoverColor: Colors.white,
                                          border: InputBorder.none,
                                          hintText: '0.00 €',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: SizedBox(
                                  height: 60,
                                  child: Consumer(
                                    builder: (context, ref, _) {
                                      final restaurantGroupeProduits = ref
                                          .watch(groupeProduitsProvider)
                                          .restaurantGroupeProduits;
                                      final appState =
                                          ref.watch(appStateProvider);
                                      return ElevatedButton(
                                        onPressed: () {
                                          RestaurantProduit newProduit =
                                              RestaurantProduit(
                                            id: '',
                                            nom:
                                                nomProduitController.value.text,
                                            groupeId:
                                                restaurantGroupeProduits!.id,
                                            prix: double.parse(
                                                prixProduitController
                                                    .value.text),
                                          );
                                          FirebaseFirestore.instance
                                              .collection('list_restaurant')
                                              .doc(appState
                                                  .utilisateur!.idRestaurant)
                                              .collection('groupe_produits')
                                              .doc(restaurantGroupeProduits.id)
                                              .collection('restaurant_produits')
                                              .add(newProduit.toJson())
                                              .then(
                                            (value) {
                                              FirebaseFirestore.instance
                                                  .collection('list_restaurant')
                                                  .doc(appState.utilisateur!
                                                      .idRestaurant)
                                                  .collection('groupe_produits')
                                                  .doc(restaurantGroupeProduits
                                                      .id)
                                                  .collection(
                                                      'restaurant_produits')
                                                  .doc(value.id)
                                                  .update({'id': value.id});
                                            },
                                          );
                                          nomProduitController.clear();
                                          prixProduitController.clear();
                                        },
                                        child: const Text('Ajouter'),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('list_restaurant')
                          .doc(appState.utilisateur!.idRestaurant)
                          .collection('groupe_produits')
                          .doc(groupeProduitsState.restaurantGroupeProduits!.id)
                          .collection('restaurant_produits')
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return const Center(
                            child: Text('error'),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        }
                        return Scrollbar(
                          isAlwaysShown: true,
                          controller: produitlistController,
                          child: Column(
                            children: ListTile.divideTiles(
                              context: context,
                              tiles: snapshot.data!.docs.map(
                                (e) {
                                  RestaurantProduit produit =
                                      RestaurantProduit.fromJson(
                                          e.data() as Map<String, dynamic>);
                                  return ListTile(
                                    title: SizedBox(
                                      width: double.infinity,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(produit.nom!),
                                          Text('${produit.prix!} €'),
                                        ],
                                      ),
                                    ),
                                    trailing: IconButton(
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('list_restaurant')
                                            .doc(appState
                                                .utilisateur!.idRestaurant)
                                            .collection('groupe_produits')
                                            .doc(groupeProduitsState
                                                .restaurantGroupeProduits!.id)
                                            .collection('restaurant_produits')
                                            .doc(produit.id)
                                            .delete();
                                      },
                                      icon: const Icon(Icons.remove_circle),
                                      splashRadius: 15,
                                    ),
                                  );
                                },
                              ),
                            ).toList(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink();
    });
  }
}

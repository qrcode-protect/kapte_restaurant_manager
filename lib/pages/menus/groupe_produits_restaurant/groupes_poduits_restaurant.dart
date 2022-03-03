import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libertyrestaurant/models/restaurant_groupe_produits/restaurant_groupe_produits.dart';
import 'package:libertyrestaurant/pages/menus/groupe_produits_restaurant/groupe_produits_restaurant_detail.dart';
import 'package:libertyrestaurant/state_management/state_management.dart';

var groupeProduitsProvider =
    ChangeNotifierProvider.autoDispose<GroupeProduitsStateProvider>(
        (ref) => GroupeProduitsStateProvider());

class GroupeProduitsStateProvider with ChangeNotifier {
  RestaurantGroupeProduits? restaurantGroupeProduits;

  seletedGroupeProduits(RestaurantGroupeProduits? groupe) {
    restaurantGroupeProduits = groupe;

    notifyListeners();
  }
}

class GroupesProduitsRestaurant extends StatelessWidget {
  const GroupesProduitsRestaurant({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final appState = ref.watch(appStateProvider);
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: ListTile(
            contentPadding: EdgeInsets.zero,
            title: const TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search_outlined),
                border: InputBorder.none,
                hintText: 'Rechercher',
              ),
            ),
            trailing: SizedBox(
              height: 40.0,
              child: ElevatedButton(
                onPressed: () {
                  final newGroupe = RestaurantGroupeProduits(
                    id: '',
                    nom: '',
                    description: '',
                  );
                  ref
                      .read(groupeProduitsProvider)
                      .seletedGroupeProduits(newGroupe);
                  ref
                      .read(groupeProduitsDetailProvider)
                      .initController(newGroupe);
                  ref.read(groupeProduitsDetailProvider).setDrawerValue(true);
                },
                child: const Text('Ajouter un groupe'),
              ),
            ),
          ),
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
                    return const LinearProgressIndicator();
                  }
                  return ListView(
                    children: ListTile.divideTiles(
                      context: context,
                      tiles: snapshot.data!.docs.map(
                        (e) {
                          RestaurantGroupeProduits groupe =
                              RestaurantGroupeProduits.fromJson(
                                  e.data() as Map<String, dynamic>);
                          return Consumer(builder: (context, ref, _) {
                            final groupeProduitsState =
                                ref.watch(groupeProduitsProvider);
                            return ListTile(
                              title: Text(groupe.nom!),
                              subtitle: Text(groupe.description!),
                              trailing: groupe.requis == true
                                  ? const Text('Unique')
                                  : const Text('Multiple'),
                              onTap: groupeProduitsState
                                          .restaurantGroupeProduits !=
                                      null
                                  ? groupeProduitsState
                                              .restaurantGroupeProduits!.id ==
                                          groupe.id
                                      ? () {
                                          ref
                                              .read(
                                                  groupeProduitsDetailProvider)
                                              .setDrawerValue(true);
                                        }
                                      : () {
                                          ref
                                              .read(groupeProduitsProvider)
                                              .seletedGroupeProduits(groupe);
                                          ref
                                              .read(
                                                  groupeProduitsDetailProvider)
                                              .initController(groupe);
                                          ref
                                              .read(
                                                  groupeProduitsDetailProvider)
                                              .setModification(false);
                                          ref
                                              .read(
                                                  groupeProduitsDetailProvider)
                                              .setDrawerValue(true);
                                        }
                                  : () {
                                      ref
                                          .read(groupeProduitsProvider)
                                          .seletedGroupeProduits(groupe);
                                      ref
                                          .read(groupeProduitsDetailProvider)
                                          .initController(groupe);
                                      ref
                                          .read(groupeProduitsDetailProvider)
                                          .setModification(false);
                                      ref
                                          .read(groupeProduitsDetailProvider)
                                          .setDrawerValue(true);
                                    },
                              selectedColor:
                                  Theme.of(context).secondaryHeaderColor,
                              selected: groupeProduitsState
                                          .restaurantGroupeProduits !=
                                      null
                                  ? groupeProduitsState
                                              .restaurantGroupeProduits!.id ==
                                          groupe.id
                                      ? true
                                      : false
                                  : false,
                            );
                          });
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

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapte_cms/models/restaurant_menu_categorie/restaurant_menu_categorie.dart';
import 'package:kapte_cms/state_management/state_management.dart';

final categorieProvider =
    ChangeNotifierProvider.autoDispose<CategorieStateProvider>(
        (ref) => CategorieStateProvider());

class CategorieStateProvider with ChangeNotifier {
  RestaurantMenuCategorie? restaurantMenuCategorie;
  TextEditingController? nomCategorieController;
  TextEditingController? rangCategorieController;
  bool modification = false;
  bool drawerValue = false;

  setDrawerValue(bool value) {
    drawerValue = value;
    notifyListeners();
  }

  selectedCategorie(RestaurantMenuCategorie? categorie) {
    restaurantMenuCategorie = categorie;
    if (categorie != null) {
      nomCategorieController = TextEditingController();
      rangCategorieController = TextEditingController();
      setModification(false);
      nomCategorieController!.text = categorie.nom;
      rangCategorieController!.text = categorie.rank.toString();
      nomCategorieController!.addListener(() {
        if (nomCategorieController!.value.text != categorie.nom &&
            !modification) {
          setModification(true);
        }
      });
      rangCategorieController!.addListener(() {
        if (rangCategorieController!.value.text != categorie.rank.toString() &&
            !modification) {
          setModification(true);
        }
      });
    }
    notifyListeners();
  }

  setModification(bool value) {
    modification = value;
    notifyListeners();
  }
}

class CategoriesRestaurant extends StatelessWidget {
  const CategoriesRestaurant({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
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
                  ref.read(categorieProvider).selectedCategorie(
                        RestaurantMenuCategorie(id: '', nom: ''),
                      );
                  ref.read(categorieProvider).setDrawerValue(true);
                },
                child: const Text('Ajouter une catégorie'),
              ),
            ),
          ),
        ),
        body: Consumer(builder: (context, ref, _) {
          final user = ref.watch(appStateProvider).utilisateur;
          return user != null
              ? StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('list_restaurant')
                      .doc(user.idRestaurant)
                      .collection('categories_menu')
                      .orderBy('rank')
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
                            RestaurantMenuCategorie categorieMenu =
                                RestaurantMenuCategorie.fromJson(
                                    e.data() as Map<String, dynamic>);
                            return Consumer(
                              builder: (context, ref, _) {
                                final restaurantMenuCategorie = ref
                                    .watch(categorieProvider)
                                    .restaurantMenuCategorie;
                                return ListTile(
                                  title: Text(categorieMenu.nom),
                                  trailing: Text(categorieMenu.rank.toString()),
                                  onTap: restaurantMenuCategorie != null
                                      ? restaurantMenuCategorie.id ==
                                              categorieMenu.id
                                          ? () {
                                              ref
                                                  .read(categorieProvider)
                                                  .setDrawerValue(true);
                                            }
                                          : () {
                                              ref
                                                  .read(categorieProvider)
                                                  .selectedCategorie(
                                                      categorieMenu);
                                              ref
                                                  .read(categorieProvider)
                                                  .setDrawerValue(true);
                                            }
                                      : () {
                                          ref
                                              .read(categorieProvider)
                                              .selectedCategorie(categorieMenu);
                                          ref
                                              .read(categorieProvider)
                                              .setDrawerValue(true);
                                        },
                                  selectedColor:
                                      Theme.of(context).secondaryHeaderColor,
                                  selected: restaurantMenuCategorie != null
                                      ? restaurantMenuCategorie.id ==
                                              categorieMenu.id
                                          ? true
                                          : false
                                      : false,
                                );
                              },
                            );
                          },
                        ),
                      ).toList(),
                    );
                  },
                )
              : const Center(
                  child: CircularProgressIndicator(),
                );
        }),
      );
    });
  }
}

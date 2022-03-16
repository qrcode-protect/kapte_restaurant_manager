import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapte_cms/models/categorie/categorie.dart';
import 'package:kapte_cms/models/restaurant/restaurant.dart';
import 'package:kapte_cms/pages/documents/documents_page.dart';

class CategorieState with ChangeNotifier {
  Categorie? selectedCategorie;
  List<Restaurant>? listRestaurant;
  TextEditingController nameController = TextEditingController();
  String? avatar;
  bool updateLoading = false;
  bool createLoading = false;
  bool createCategorie = false;

  setSelectedCategorie(Categorie? newCat) {
    selectedCategorie = newCat;
    if (newCat != null) {
      nameController.value = TextEditingValue(text: newCat.nom!);
      avatar = newCat.avatar;
    } else {
      nameController.value = TextEditingValue.empty;
      avatar = null;
    }
    notifyListeners();
  }

  setListRestaurant(List<Restaurant>? newListRestaurant) {
    listRestaurant = newListRestaurant;
    notifyListeners();
  }

  setUpdateLoading(bool state) {
    updateLoading = state;
    notifyListeners();
  }

  setCreateLoading(bool state) {
    createLoading = state;
    notifyListeners();
  }

  setCreateCategorie(bool state) {
    if (state) {
      setSelectedCategorie(null);
      setListRestaurant(null);
    }
    createCategorie = state;
    notifyListeners();
  }

  setAvatar(String newAvatar) {
    avatar = newAvatar;
    notifyListeners();
  }

  notify() {
    notifyListeners();
  }
}

final categorieStateProvider = ChangeNotifierProvider<CategorieState>((ref) {
  return CategorieState();
});

class CategoriePage extends StatelessWidget {
  const CategoriePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('list_restaurants_categorie')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.hasData) {
                    List<Categorie> listCategorie = snapshot.data!.docs
                        .map(
                          (e) => Categorie.fromJson(
                            e.data(),
                          ),
                        )
                        .toList();
                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 75),
                          child: ListView.builder(
                            itemCount: listCategorie.length,
                            itemBuilder: (context, index) {
                              Categorie categorie = listCategorie[index];
                              late List<Restaurant> listRestaurant;
                              return Consumer(builder: (context, ref, _) {
                                return ListTile(
                                  title: Text(categorie.nom!),
                                  subtitle: FutureBuilder<
                                      QuerySnapshot<Map<String, dynamic>>>(
                                    future: FirebaseFirestore.instance
                                        .collection('list_restaurant')
                                        .where('categorie.id',
                                            isEqualTo: categorie.id)
                                        .get(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.done) {
                                        if (snapshot.hasData) {
                                          listRestaurant = snapshot.data!.docs
                                              .map(((e) => Restaurant.fromJson(
                                                  e.data())))
                                              .toList();

                                          return Text(
                                              '${snapshot.data!.docs.length} restaurant${[
                                            0,
                                            1
                                          ].contains(snapshot.data!.docs.length) ? '' : 's'}');
                                        }
                                        return const Text('Aucun restaurant');
                                      }
                                      return const Text('0 restaurants');
                                    },
                                  ),
                                  trailing: categorie.avatar != null
                                      ? CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(categorie.avatar!),
                                        )
                                      : null,
                                  onTap: () {
                                    ref
                                        .read(categorieStateProvider)
                                        .setSelectedCategorie(categorie);
                                    ref
                                        .read(categorieStateProvider)
                                        .setListRestaurant(listRestaurant);
                                    ref
                                        .read(categorieStateProvider)
                                        .setCreateCategorie(false);
                                  },
                                );
                              });
                            },
                          ),
                        ),
                        Consumer(builder: (context, ref, _) {
                          return Positioned(
                            top: 15,
                            right: 15,
                            child: IconButton(
                              onPressed: () {
                                ref
                                    .read(categorieStateProvider)
                                    .setCreateCategorie(true);
                              },
                              icon: const Icon(Icons.add),
                            ),
                          );
                        })
                      ],
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.amber,
                    ),
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                );
              },
            ),
          ),
          const EditCategorie(),
          const AddCategorie(),
        ],
      ),
    );
  }
}

class EditCategorie extends ConsumerWidget {
  const EditCategorie({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorieState = ref.watch(categorieStateProvider);
    return categorieState.selectedCategorie != null
        ? Expanded(
            flex: 1,
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const ListTile(
                      title: Text('Modifier une catégorie'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      child: Stack(
                        children: [
                          Image.network(
                            categorieState.avatar!,
                            errorBuilder: (context, object, stack) {
                              return const SizedBox(
                                width: double.infinity,
                                height: 150,
                                child: Center(
                                  child: Text(
                                      'Erreur lors du chargement de l\'image'),
                                ),
                              );
                            },
                          ),
                          Positioned(
                            right: 0.0,
                            bottom: 0.0,
                            child: IconButton(
                              onPressed: () => showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) => const Dialog(
                                  elevation: 2,
                                  child: DocumentsPage(
                                    onNavigate: true,
                                  ),
                                ),
                              ).then((value) {
                                if (value != null) {
                                  ref
                                      .read(categorieStateProvider)
                                      .setAvatar(value);
                                }
                              }),
                              icon: Icon(
                                Icons.photo_camera,
                                color: Theme.of(context).primaryColor,
                              ),
                              splashRadius: 20.0,
                            ),
                          )
                        ],
                      ),
                    ),
                    ListTile(
                      title: Text(categorieState.selectedCategorie!.nom!),
                      subtitle: Text(
                          '${categorieState.listRestaurant!.length} restaurant${[
                        0,
                        1
                      ].contains(categorieState.listRestaurant!.length) ? '' : 's'}'),
                    ),
                    TextField(
                      controller: categorieState.nameController,
                      onChanged: (value) {
                        categorieState.notify();
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (categorieState
                                          .nameController.value.text !=
                                      categorieState.selectedCategorie!.nom) ||
                                  (categorieState.selectedCategorie!.avatar !=
                                      categorieState.avatar)
                              ? () async {
                                  categorieState.setUpdateLoading(true);
                                  WriteBatch batch =
                                      FirebaseFirestore.instance.batch();
                                  Map<String, dynamic> updatedCategorieMap = {};
                                  if (categorieState
                                      .nameController.value.text.isNotEmpty) {
                                    updatedCategorieMap.addAll({
                                      'nom': categorieState
                                          .nameController.value.text,
                                    });
                                  }
                                  if (categorieState.avatar!.isNotEmpty) {
                                    updatedCategorieMap.addAll({
                                      'avatar': categorieState.avatar!,
                                    });
                                  }
                                  await FirebaseFirestore.instance
                                      .collection('list_restaurants_categorie')
                                      .doc(categorieState.selectedCategorie!.id)
                                      .update(updatedCategorieMap)
                                      .then(
                                        (value) async => FirebaseFirestore
                                            .instance
                                            .collection(
                                                'list_restaurants_categorie')
                                            .doc(categorieState
                                                .selectedCategorie!.id)
                                            .get()
                                            .then(
                                          (document) async {
                                            for (Restaurant restaurant
                                                in categorieState
                                                    .listRestaurant!) {
                                              batch.update(
                                                  FirebaseFirestore.instance
                                                      .collection(
                                                          'list_restaurant')
                                                      .doc(restaurant.id),
                                                  {
                                                    'categorie': document.data()
                                                  });
                                            }
                                            await batch.commit();
                                            categorieState
                                                .setUpdateLoading(true);
                                          },
                                        ),
                                      );
                                }
                              : null,
                          child: const Text('Mettre à jour'),
                        ),
                      ),
                    ),
                    categorieState.listRestaurant!.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 10),
                            child: SizedBox(
                              height: 50,
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.red),
                                ),
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('list_restaurants_categorie')
                                      .doc(categorieState.selectedCategorie!.id)
                                      .delete();
                                },
                                child: const Text('Supprimer'),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    onPressed: () {
                      ref
                          .read(categorieStateProvider)
                          .setSelectedCategorie(null);
                    },
                    icon: const Icon(Icons.close),
                  ),
                )
              ],
            ),
          )
        : const SizedBox.shrink();
  }
}

class AddCategorie extends ConsumerWidget {
  const AddCategorie({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorieState = ref.watch(categorieStateProvider);

    return categorieState.createCategorie
        ? Expanded(
            flex: 1,
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const ListTile(
                      title: Text('Créer une catégorie'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),
                      child: Stack(
                        children: [
                          categorieState.avatar != null
                              ? Image.network(
                                  categorieState.avatar!,
                                  errorBuilder: (context, object, stack) {
                                    return const SizedBox(
                                      width: double.infinity,
                                      height: 150,
                                      child: Center(
                                        child: Text(
                                            'Erreur lors du chargement de l\'image'),
                                      ),
                                    );
                                  },
                                )
                              : const SizedBox(
                                  width: double.infinity,
                                  height: 150,
                                  child: Center(
                                    child: Text('Ajouter une image'),
                                  ),
                                ),
                          Positioned(
                            right: 0.0,
                            bottom: 0.0,
                            child: IconButton(
                              onPressed: () => showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (BuildContext context) => const Dialog(
                                  elevation: 2,
                                  child: DocumentsPage(
                                    onNavigate: true,
                                  ),
                                ),
                              ).then((value) {
                                if (value != null) {
                                  ref
                                      .read(categorieStateProvider)
                                      .setAvatar(value);
                                }
                              }),
                              icon: Icon(
                                Icons.photo_camera,
                                color: Theme.of(context).primaryColor,
                              ),
                              splashRadius: 20.0,
                            ),
                          )
                        ],
                      ),
                    ),
                    TextField(
                      controller: categorieState.nameController,
                      onChanged: (value) {
                        categorieState.notify();
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      child: SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (categorieState
                                      .nameController.value.text.isNotEmpty &&
                                  categorieState.avatar != null)
                              ? () async {
                                  categorieState.setCreateLoading(true);
                                  await FirebaseFirestore.instance
                                      .collection('list_restaurants_categorie')
                                      .add({
                                    'nom': categorieState
                                        .nameController.value.text,
                                    'avatar': categorieState.avatar,
                                    'id': '',
                                  }).then(
                                    (value) async => await FirebaseFirestore
                                        .instance
                                        .collection(
                                            'list_restaurants_categorie')
                                        .doc(value.id)
                                        .update({'id': value.id}).then((value) {
                                      ref
                                          .read(categorieStateProvider)
                                          .setCreateLoading(false);
                                      ref
                                          .read(categorieStateProvider)
                                          .setCreateCategorie(false);
                                    }),
                                  );
                                }
                              : null,
                          child: categorieState.createLoading
                              ? const CircularProgressIndicator()
                              : const Text('Créer'),
                        ),
                      ),
                    )
                  ],
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: IconButton(
                    onPressed: () {
                      ref
                          .read(categorieStateProvider)
                          .setCreateCategorie(false);
                    },
                    icon: const Icon(Icons.close),
                  ),
                )
              ],
            ),
          )
        : const SizedBox.shrink();
  }
}

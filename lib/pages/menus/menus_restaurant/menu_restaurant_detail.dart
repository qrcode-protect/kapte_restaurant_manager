import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapte_cms/models/categorie/categorie.dart';
import 'package:kapte_cms/models/restaurant_groupe_produits/restaurant_groupe_produits.dart';
import 'package:kapte_cms/models/restaurant_menu/restaurant_menu.dart';
import 'package:kapte_cms/models/restautrant_produit/restaurant_produit.dart';
import 'package:kapte_cms/pages/documents/documents_page.dart';
import 'package:kapte_cms/pages/menus/menus_restaurant/menu_groupe_produits.dart';
import 'package:kapte_cms/pages/menus/menus_restaurant/menus_restaurant.dart';
import 'package:kapte_cms/pages/menus/menus_restaurant/widgets/categorie_dropdown.dart';
import 'package:kapte_cms/state_management/state_management.dart';
import 'package:kapte_cms/widgets/custom_input.dart';
import 'package:kapte_cms/widgets/detail_save_button.dart';

var menuDetailProvider = ChangeNotifierProvider.autoDispose<MenuDetailState>(
    (ref) => MenuDetailState());

class MenuDetailState with ChangeNotifier {
  bool modification = false;
  Categorie? categorieDropdownValue;
  String? menuAvatar;
  TextEditingController? nomMenuController;
  TextEditingController? descriptionMenuController;
  TextEditingController? prixMenuController;
  bool drawerValue = false;
  int groupeProduitsLenght = 0;

  setGroupeProduitsLenght(int value) {
    groupeProduitsLenght = value;
  }

  setDrawerValue(bool value) {
    drawerValue = value;
    notifyListeners();
  }

  initController(RestaurantMenu? menu) {
    if (menu != null) {
      setcategorieDropdownValue(menu.categorie);
      menuAvatar = menu.avatar;
      nomMenuController = TextEditingController();
      descriptionMenuController = TextEditingController();
      prixMenuController = TextEditingController();
      nomMenuController!.text = menu.nom;
      descriptionMenuController!.text = menu.description!;
      prixMenuController!.text = menu.prix.toString();
      nomMenuController!.addListener(() {
        if (!modification) {
          if (nomMenuController!.value.text != menu.nom) {
            setModification(true);
          }
        }
      });
      descriptionMenuController!.addListener(() {
        if (!modification) {
          if (descriptionMenuController!.value.text != menu.description) {
            setModification(true);
          }
        }
      });
      prixMenuController!.addListener(() {
        if (!modification) {
          if (prixMenuController!.value.text != menu.prix.toString()) {
            setModification(true);
          }
        }
      });
    }
  }

  setModification(bool value) {
    modification = value;
    notifyListeners();
  }

  setMenuAvatar(String path) {
    menuAvatar = path;
    modification = true;
    notifyListeners();
  }

  setcategorieDropdownValue(Categorie? value) {
    categorieDropdownValue = value;
    notifyListeners();
  }
}

class MenuRestaurantDetail extends StatelessWidget {
  const MenuRestaurantDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border(
        left: BorderSide(
          color: Theme.of(context).dividerColor,
        ),
        right: BorderSide(
          color: Theme.of(context).dividerColor,
        ),
      )),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MenuDetail(),
            Consumer(
              builder: (context, ref, _) {
                final menuState = ref.watch(menuProvider);
                return menuState.restaurantMenu != null
                    ? menuState.restaurantMenu!.id.isNotEmpty
                        ? const Divider()
                        : const SizedBox.shrink()
                    : const Center(
                        child: Text('Sélectionnez un élément à modifier'),
                      );
              },
            ),
            const ListGroupesProduits(),
          ],
        ),
      ),
    );
  }
}

class MenuDetail extends StatefulWidget {
  const MenuDetail({
    Key? key,
  }) : super(key: key);

  @override
  State<MenuDetail> createState() => _MenuDetailState();
}

class _MenuDetailState extends State<MenuDetail> {
  ScrollController listInfoMenuController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final menuDetailState = ref.watch(menuDetailProvider);
      final menuState = ref.watch(menuProvider);
      final appState = ref.watch(appStateProvider);

      RestaurantMenu createRestaurantMenu() {
        RestaurantMenu updateRestaurantMenu = RestaurantMenu(
          id: menuState.restaurantMenu!.id,
          nom: menuState.restaurantMenu!.nom,
          prix: menuState.restaurantMenu!.prix,
          avatar: menuDetailState.menuAvatar,
        );
        if (menuDetailState.categorieDropdownValue != null) {
          updateRestaurantMenu
              .setCategorie(menuDetailState.categorieDropdownValue!);
        }
        if (menuDetailState.descriptionMenuController != null) {
          updateRestaurantMenu
              .setDescription(menuDetailState.descriptionMenuController!.text);
        }
        if (menuDetailState.menuAvatar != null) {
          updateRestaurantMenu.setAvatar(menuDetailState.menuAvatar!);
        }
        return updateRestaurantMenu;
      }

      return menuState.restaurantMenu != null && appState.user != null
          ? Expanded(
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Theme.of(context).secondaryHeaderColor,
                  title: menuDetailState.modification
                      ? Text(
                          'Détails',
                          style: Theme.of(context).textTheme.headline5,
                        )
                      : Text(
                          'Ajouer un menu',
                          style: Theme.of(context).textTheme.headline5,
                        ),
                  centerTitle: false,
                  actions: [
                    DetailSaveButton(
                        onPressedSave: menuDetailState.modification
                            ? () {
                                if (_formKey.currentState!.validate()) {
                                  if (menuState.restaurantMenu!.id.isNotEmpty) {
                                    FirebaseFirestore.instance
                                        .collection('list_restaurant')
                                        .doc(appState.utilisateur!.idRestaurant)
                                        .collection('menus')
                                        .doc(menuState.restaurantMenu!.id)
                                        .update(
                                            createRestaurantMenu().toJson());
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Le menu ${menuState.restaurantMenu!.nom} été modifier',
                                        ),
                                        backgroundColor: Theme.of(context)
                                            .secondaryHeaderColor,
                                        duration:
                                            const Duration(milliseconds: 500),
                                      ),
                                    );
                                  } else {
                                    RestaurantMenu newMenu = RestaurantMenu(
                                      id: '',
                                      avatar: menuDetailState.menuAvatar,
                                      nom: menuDetailState
                                          .nomMenuController!.value.text,
                                      prix: double.parse(menuDetailState
                                          .prixMenuController!.value.text),
                                      description: menuDetailState
                                          .descriptionMenuController!
                                          .value
                                          .text,
                                      categorie: menuDetailState
                                          .categorieDropdownValue,
                                    );
                                    FirebaseFirestore.instance
                                        .collection('list_restaurant')
                                        .doc(appState.utilisateur!.idRestaurant)
                                        .collection('menus')
                                        .add(
                                          newMenu.toJson(),
                                        )
                                        .then(
                                      (value) {
                                        FirebaseFirestore.instance
                                            .collection('list_restaurant')
                                            .doc(appState
                                                .utilisateur!.idRestaurant)
                                            .collection('menus')
                                            .doc(value.id)
                                            .update({'id': value.id});
                                        value.get().then(
                                          (value) {
                                            ref.read(menuProvider).selectedMenu(
                                                RestaurantMenu.fromJson(value
                                                        .data()
                                                    as Map<String, dynamic>));
                                            ref
                                                .read(menuDetailProvider)
                                                .initController(
                                                    RestaurantMenu.fromJson(
                                                        value.data() as Map<
                                                            String, dynamic>));
                                          },
                                        );
                                      },
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Le menu ${menuState.restaurantMenu!.nom} été ajouter',
                                        ),
                                        backgroundColor: Theme.of(context)
                                            .secondaryHeaderColor,
                                        duration:
                                            const Duration(milliseconds: 500),
                                      ),
                                    );
                                  }
                                }
                                ref
                                    .read(menuDetailProvider)
                                    .setModification(false);
                              }
                            : null),
                    menuState.restaurantMenu!.id.isNotEmpty
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
                                        .read(menuDetailProvider)
                                        .setDrawerValue(false);
                                    ref.read(menuProvider).selectedMenu(null);
                                    ref
                                        .read(menuGroupeDrawerProvider.notifier)
                                        .setValue(false);
                                  },
                                ),
                                PopupMenuItem(
                                  child: const Text("Supprimer le menu"),
                                  onTap: () async {
                                    await FirebaseFirestore.instance
                                        .collection('list_restaurant')
                                        .doc(appState.utilisateur!.idRestaurant)
                                        .collection('menus')
                                        .doc(menuState.restaurantMenu!.id)
                                        .delete();

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Le menu ${menuState.restaurantMenu!.nom} été supprimer',
                                        ),
                                        backgroundColor: Theme.of(context)
                                            .secondaryHeaderColor,
                                        duration:
                                            const Duration(milliseconds: 500),
                                      ),
                                    );
                                    ref.read(menuProvider).selectedMenu(null);
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
                              ref
                                  .read(menuDetailProvider)
                                  .setDrawerValue(false);
                              ref.read(menuProvider).selectedMenu(null);
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
                  child: Scrollbar(
                    isAlwaysShown: true,
                    controller: listInfoMenuController,
                    child: ListView(
                      controller: listInfoMenuController,
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              height: 200,
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: menuDetailState.menuAvatar != null
                                    ? Stack(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  menuDetailState.menuAvatar!,
                                                ),
                                                fit: BoxFit.fill,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: 0.0,
                                            bottom: 0.0,
                                            child: IconButton(
                                              onPressed: () => showDialog(
                                                barrierDismissible: false,
                                                context: context,
                                                builder:
                                                    (BuildContext context) =>
                                                        const Dialog(
                                                  elevation: 2,
                                                  child: DocumentsPage(
                                                    onNavigate: true,
                                                  ),
                                                ),
                                              ).then((value) {
                                                if (value != null) {
                                                  ref
                                                      .read(menuDetailProvider)
                                                      .setMenuAvatar(value);
                                                }
                                              }),
                                              icon: Icon(
                                                Icons.photo_camera,
                                                color: Theme.of(context)
                                                    .primaryColor,
                                              ),
                                              splashRadius: 20.0,
                                            ),
                                          )
                                        ],
                                      )
                                    : Center(
                                        child: IconButton(
                                          onPressed: () => showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (BuildContext context) =>
                                                const Dialog(
                                              elevation: 2,
                                              child: DocumentsPage(
                                                onNavigate: true,
                                              ),
                                            ),
                                          ).then((value) {
                                            if (value != null) {
                                              ref
                                                  .read(menuDetailProvider)
                                                  .setMenuAvatar(value);
                                            }
                                          }),
                                          icon: const Icon(
                                            Icons.image_outlined,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            CustomInput(
                              controller: menuDetailState.nomMenuController,
                              hintText: 'Nom',
                            ),
                            CustomInput(
                              controller:
                                  menuDetailState.descriptionMenuController,
                              hintText: 'Drescription',
                            ),
                            CustomInput(
                              controller: menuDetailState.prixMenuController,
                              hintText: 'Prix',
                            ),
                          ],
                        ),
                        const CategorieDropdown(),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : const SizedBox.shrink();
    });
  }
}

class ListGroupesProduits extends StatefulWidget {
  const ListGroupesProduits({
    Key? key,
  }) : super(key: key);

  @override
  State<ListGroupesProduits> createState() => _ListGroupesProduitsState();
}

class _ListGroupesProduitsState extends State<ListGroupesProduits> {
  ScrollController listInfoMenuController = ScrollController();
  ScrollController groupeProduitsMenuController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final menuState = ref.watch(menuProvider);
      final appState = ref.watch(appStateProvider);
      final menuDetailState = ref.watch(menuDetailProvider);
      return menuState.restaurantMenu != null && appState.user != null
          ? menuState.restaurantMenu!.id.isNotEmpty
              ? Expanded(
                  child: Scaffold(
                    appBar: AppBar(
                      centerTitle: false,
                      backgroundColor: Theme.of(context).secondaryHeaderColor,
                      title: Text(
                        'Groupes de produits',
                        style: Theme.of(context).textTheme.headline5,
                      ),
                      actions: [
                        Consumer(builder: (context, ref, _) {
                          final menuGroupeDrawer =
                              ref.watch(menuGroupeDrawerProvider);
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: !menuGroupeDrawer
                                ? IconButton(
                                    padding: EdgeInsets.zero,
                                    onPressed: () {
                                      ref
                                          .read(
                                              menuGroupeDrawerProvider.notifier)
                                          .setValue(!menuGroupeDrawer);
                                    },
                                    icon: Icon(
                                      Icons.add_circle,
                                      color: Theme.of(context).primaryColor,
                                      size: 35,
                                    ),
                                    splashRadius: 15,
                                  )
                                : null,
                          );
                        }),
                      ],
                    ),
                    body: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('list_restaurant')
                          .doc(appState.utilisateur!.idRestaurant)
                          .collection('menus')
                          .doc(menuState.restaurantMenu!.id)
                          .collection('groupe_produits')
                          .orderBy('rank')
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
                        if (snapshot.data!.docs.isNotEmpty) {
                          ref.read(menuDetailProvider).setGroupeProduitsLenght(
                              snapshot.data!.docs.last['rank']);
                        }
                        return DragTarget<RestaurantGroupeProduits>(
                            builder: (context, candidateItems, rejectedItems) {
                          return Scrollbar(
                            isAlwaysShown: true,
                            controller: groupeProduitsMenuController,
                            child: ListView(
                              controller: groupeProduitsMenuController,
                              children: snapshot.data!.docs.map((e) {
                                final groupe =
                                    RestaurantGroupeProduits.fromJson(
                                        e.data() as Map<String, dynamic>);
                                return ListTile(
                                  title: Text(groupe.nom!),
                                  subtitle: Text(groupe.description!),
                                  trailing: IconButton(
                                    onPressed: () {
                                      FirebaseFirestore.instance
                                          .collection('list_restaurant')
                                          .doc(appState
                                              .utilisateur!.idRestaurant)
                                          .collection('menus')
                                          .doc(menuState.restaurantMenu!.id)
                                          .collection('groupe_produits')
                                          .doc(groupe.id)
                                          .delete();

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Le Groupe ${groupe.nom} été supprimer',
                                          ),
                                          backgroundColor: Theme.of(context)
                                              .secondaryHeaderColor,
                                          duration:
                                              const Duration(milliseconds: 500),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.remove_circle),
                                    splashRadius: 15,
                                  ),
                                );
                              }).toList(),
                            ),
                          );
                        }, onAccept: (groupe) {
                          FirebaseFirestore.instance
                              .collection('list_restaurant')
                              .doc(appState.utilisateur!.idRestaurant)
                              .collection('menus')
                              .doc(menuState.restaurantMenu!.id)
                              .collection('groupe_produits')
                              .add(
                                RestaurantGroupeProduits(
                                  rank:
                                      menuDetailState.groupeProduitsLenght + 1,
                                  id: groupe.id,
                                  nom: groupe.nom,
                                  description: groupe.description,
                                  requis: groupe.requis,
                                ).toJson(),
                              )
                              .then((categorieValue) {
                            FirebaseFirestore.instance
                                .collection('list_restaurant')
                                .doc(appState.utilisateur!.idRestaurant)
                                .collection('menus')
                                .doc(menuState.restaurantMenu!.id)
                                .collection('groupe_produits')
                                .doc(categorieValue.id)
                                .update({'id': categorieValue.id});
                            FirebaseFirestore.instance
                                .collection('list_restaurant')
                                .doc(appState.utilisateur!.idRestaurant)
                                .collection('groupe_produits')
                                .doc(groupe.id)
                                .collection('restaurant_produits')
                                .get()
                                .then((produitValue) {
                              if (produitValue.docs.isNotEmpty) {
                                for (int i = 0;
                                    i < produitValue.docs.length;
                                    i++) {
                                  final produit = RestaurantProduit.fromJson(
                                      produitValue.docs[i].data());
                                  FirebaseFirestore.instance
                                      .collection('list_restaurant')
                                      .doc(appState.utilisateur!.idRestaurant)
                                      .collection('menus')
                                      .doc(menuState.restaurantMenu!.id)
                                      .collection('produits')
                                      .add(RestaurantProduit(
                                        id: '',
                                        nom: produit.nom,
                                        prix: produit.prix,
                                        groupeId: categorieValue.id,
                                      ).toJson())
                                      .then((value) {
                                    FirebaseFirestore.instance
                                        .collection('list_restaurant')
                                        .doc(appState.utilisateur!.idRestaurant)
                                        .collection('menus')
                                        .doc(menuState.restaurantMenu!.id)
                                        .collection('produits')
                                        .doc(value.id)
                                        .update({'id': value.id});
                                  });
                                }
                              }
                            });
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Le Groupe ${groupe.nom} été ajouter',
                              ),
                              backgroundColor:
                                  Theme.of(context).secondaryHeaderColor,
                              duration: const Duration(milliseconds: 500),
                            ),
                          );
                        });
                      },
                    ),
                  ),
                )
              : const SizedBox.shrink()
          : const SizedBox.shrink();
    });
  }
}

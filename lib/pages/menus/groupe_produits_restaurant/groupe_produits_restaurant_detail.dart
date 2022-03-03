import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libertyrestaurant/models/restaurant_groupe_produits/restaurant_groupe_produits.dart';
import 'package:libertyrestaurant/pages/menus/groupe_produits_restaurant/groupes_poduits_restaurant.dart';
import 'package:libertyrestaurant/pages/menus/groupe_produits_restaurant/list_restaurant_produit.dart';
import 'package:libertyrestaurant/pages/menus/groupe_produits_restaurant/widgets/dropdown_requis.dart';
import 'package:libertyrestaurant/state_management/state_management.dart';
import 'package:libertyrestaurant/widgets/custom_input.dart';
import 'package:libertyrestaurant/widgets/detail_save_button.dart';

var groupeProduitsDetailProvider =
    ChangeNotifierProvider.autoDispose<GroupePdosuitsDetailStateProvider>(
        (ref) => GroupePdosuitsDetailStateProvider());

class GroupePdosuitsDetailStateProvider with ChangeNotifier {
  bool modification = false;
  bool? dropdownValue;
  bool drawerValue = false;

  setDrawerValue(bool value) {
    drawerValue = value;
    notifyListeners();
  }

  TextEditingController? nomGroupeController;
  TextEditingController? descriptionGroupeController;

  initController(RestaurantGroupeProduits? groupe) {
    if (groupe != null) {
      nomGroupeController = TextEditingController();
      descriptionGroupeController = TextEditingController();
      dropdownValue = groupe.requis;
      nomGroupeController!.text = groupe.nom!;
      descriptionGroupeController!.text = groupe.description!;
      nomGroupeController!.addListener(() {
        if (nomGroupeController!.value.text != groupe.nom && !modification) {
          setModification(true);
        }
      });
      descriptionGroupeController!.addListener(() {
        if (descriptionGroupeController!.value.text != groupe.nom &&
            !modification) {
          setModification(true);
        }
      });
    }
  }

  setModification(bool value) {
    modification = value;
    notifyListeners();
  }

  setDropdownValue(bool value) {
    dropdownValue = value;
    notifyListeners();
  }
}

class GroupeProduitsRestaurantDetail extends ConsumerStatefulWidget {
  const GroupeProduitsRestaurantDetail({Key? key}) : super(key: key);
  @override
  createState() => _GroupeProduitsRestaurantDetailState();
}

class _GroupeProduitsRestaurantDetailState
    extends ConsumerState<GroupeProduitsRestaurantDetail> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final groupeProduitsState = ref.watch(groupeProduitsProvider);
    final groupeProduitsDetailState = ref.watch(groupeProduitsDetailProvider);
    final appState = ref.watch(appStateProvider);

    return groupeProduitsState.restaurantGroupeProduits != null &&
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
                      onPressedSave: groupeProduitsDetailState.modification
                          ? () {
                              if (_formKey.currentState!.validate()) {
                                if (groupeProduitsState
                                    .restaurantGroupeProduits!.id!.isNotEmpty) {
                                  FirebaseFirestore.instance
                                      .collection('list_restaurant')
                                      .doc(appState.utilisateur!.idRestaurant)
                                      .collection('groupe_produits')
                                      .doc(groupeProduitsState
                                          .restaurantGroupeProduits!.id)
                                      .update({
                                    'nom': groupeProduitsDetailState
                                        .nomGroupeController!.value.text,
                                    'description': groupeProduitsDetailState
                                        .descriptionGroupeController!
                                        .value
                                        .text,
                                    'requis':
                                        groupeProduitsDetailState.dropdownValue,
                                  });
                                  ref
                                      .read(groupeProduitsDetailProvider)
                                      .setModification(false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Le groupe ${groupeProduitsState.restaurantGroupeProduits!.nom} été modifier'),
                                      backgroundColor: Theme.of(context)
                                          .secondaryHeaderColor,
                                      duration:
                                          const Duration(milliseconds: 500),
                                    ),
                                  );
                                } else {
                                  RestaurantGroupeProduits newGroupe =
                                      RestaurantGroupeProduits(
                                    id: '',
                                    nom: groupeProduitsDetailState
                                        .nomGroupeController!.value.text,
                                    description: groupeProduitsDetailState
                                        .descriptionGroupeController!
                                        .value
                                        .text,
                                    requis:
                                        groupeProduitsDetailState.dropdownValue,
                                  );
                                  FirebaseFirestore.instance
                                      .collection('list_restaurant')
                                      .doc(appState.utilisateur!.idRestaurant)
                                      .collection('groupe_produits')
                                      .add(
                                        newGroupe.toJson(),
                                      )
                                      .then(
                                    (value) {
                                      FirebaseFirestore.instance
                                          .collection('list_restaurant')
                                          .doc(appState
                                              .utilisateur!.idRestaurant)
                                          .collection('groupe_produits')
                                          .doc(value.id)
                                          .update({'id': value.id});
                                      value.get().then(
                                        (value) {
                                          ref
                                              .read(groupeProduitsProvider)
                                              .seletedGroupeProduits(
                                                  RestaurantGroupeProduits
                                                      .fromJson(value.data()
                                                          as Map<String,
                                                              dynamic>));
                                          ref
                                              .read(
                                                  groupeProduitsDetailProvider)
                                              .initController(
                                                  RestaurantGroupeProduits
                                                      .fromJson(value.data()
                                                          as Map<String,
                                                              dynamic>));
                                        },
                                      );
                                    },
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'La catégorie ${groupeProduitsState.restaurantGroupeProduits!.nom} été ajouter'),
                                      backgroundColor: Theme.of(context)
                                          .secondaryHeaderColor,
                                      duration:
                                          const Duration(milliseconds: 500),
                                    ),
                                  );
                                }
                              }
                            }
                          : null,
                    ),
                    groupeProduitsState.restaurantGroupeProduits!.id!.isNotEmpty
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
                                        .read(groupeProduitsDetailProvider)
                                        .setDrawerValue(false);
                                    ref
                                        .read(groupeProduitsProvider)
                                        .seletedGroupeProduits(null);
                                  },
                                ),
                                PopupMenuItem(
                                  child: const Text("Supprimer le groupe"),
                                  onTap: () async {
                                    await FirebaseFirestore.instance
                                        .collection('list_restaurant')
                                        .doc(appState.utilisateur!.idRestaurant)
                                        .collection('groupe_produits')
                                        .doc(groupeProduitsState
                                            .restaurantGroupeProduits!.id)
                                        .delete();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Le groupe ${groupeProduitsState.restaurantGroupeProduits!.nom} été supprimer'),
                                        backgroundColor: Theme.of(context)
                                            .secondaryHeaderColor,
                                        duration:
                                            const Duration(milliseconds: 500),
                                      ),
                                    );
                                    ref
                                        .read(groupeProduitsProvider)
                                        .seletedGroupeProduits(null);
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
                                  .read(groupeProduitsDetailProvider)
                                  .setDrawerValue(false);
                              ref
                                  .read(groupeProduitsProvider)
                                  .seletedGroupeProduits(null);
                            },
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context).primaryColor,
                            ),
                            splashRadius: 15,
                          ),
                  ],
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: Scaffold(
                        body: ListView(
                          children: [
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  CustomInput(
                                    controller: groupeProduitsDetailState
                                        .nomGroupeController,
                                    hintText: 'Nom du groupe',
                                  ),
                                  CustomInput(
                                    controller: groupeProduitsDetailState
                                        .descriptionGroupeController,
                                    hintText: 'Description',
                                  ),
                                  const DropdownRequis(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (groupeProduitsState
                        .restaurantGroupeProduits!.id!.isNotEmpty)
                      const ListRestaurantProduit(),
                  ],
                ),
              ),
            ),
          )
        : const Center(
            child: Text('Selectionnez un élément à modifier'),
          );
  }
}

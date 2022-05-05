import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapte_cms/models/categorie/categorie.dart';
import 'package:kapte_cms/models/paiements/paiements.dart';
import 'package:kapte_cms/models/restaurant/restaurant.dart';
import 'package:kapte_cms/pages/documents/documents_page.dart';
import 'package:kapte_cms/state_management/state_management.dart';
import 'package:kapte_cms/widgets/detail_save_button.dart';

var etablissementProvider =
    ChangeNotifierProvider.autoDispose<EtablissementState>(
        (ref) => EtablissementState());

class EtablissementState with ChangeNotifier {
  Restaurant? restaurant;
  bool drawerValue = false;
  String? restaurantAvatar;
  Categorie? selectedCategorie;
  bool? cartes;
  bool? especes;

  setRestaurantAvatar(String path) {
    restaurantAvatar = path;
    notifyListeners();
  }

  setSelectedCategorie(Categorie? categorie) {
    selectedCategorie = categorie;
    notifyListeners();
  }

  Future<bool?> setCarte(bool? value) async {
    if (!value! && !especes!) {
      return false;
    } else {
      cartes = value;
      notifyListeners();
    }
    return true;
  }

  Future<bool?> setEspece(bool? value) async {
    if (!value! && !cartes!) {
      return false;
    } else {
      especes = value;
      notifyListeners();
    }
    return true;
  }

  selectedRestaurant(Restaurant? restaurant) {
    this.restaurant = restaurant;
    if (restaurant != null) {
      restaurantAvatar = restaurant.avatar;
      selectedCategorie = restaurant.categorie;
      if (restaurant.paiements != null) {
        cartes = restaurant.paiements!.carte;
        especes = restaurant.paiements!.espece;
      } else {
        cartes = false;
        especes = false;
      }
      drawerValue = true;
    } else {
      drawerValue = false;
    }
    notifyListeners();
  }

  Future<void> updateRestaurant() async {
    await FirebaseFirestore.instance
        .collection('list_restaurant')
        .doc(restaurant!.id)
        .update({
      'avatar': restaurantAvatar,
      'paiements':
          Paiements(carte: cartes ?? false, espece: especes ?? false).toJson(),
      'categorie':
          selectedCategorie != null ? selectedCategorie!.toJson() : null,
    });
  }
}

class EtablissementPage extends ConsumerStatefulWidget {
  const EtablissementPage({Key? key}) : super(key: key);
  @override
  _EtablissementPageState createState() => _EtablissementPageState();
}

class _EtablissementPageState extends ConsumerState<EtablissementPage> {
  @override
  Widget build(BuildContext context) {
    final utilisateur = ref.watch(appStateProvider).utilisateur;
    return Scaffold(
      body: utilisateur == null
          ? const SizedBox.shrink()
          : utilisateur.idRestaurant == '' || utilisateur.idRestaurant == null
              ? const SizedBox.shrink()
              : Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('list_restaurant')
                            .doc(utilisateur.idRestaurant)
                            .snapshots(),
                        builder: (context,
                            AsyncSnapshot<DocumentSnapshot>
                                restaurantSnapshot) {
                          if (restaurantSnapshot.hasError) {
                            return const Center(
                              child: Text('error'),
                            );
                          }
                          if (restaurantSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const LinearProgressIndicator();
                          }
                          if (restaurantSnapshot.data!.data() != null) {
                            final restaurant = Restaurant.fromJson(
                                restaurantSnapshot.data!.data()
                                    as Map<String, dynamic>);
                            return Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: ListView(
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Restaurants',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline2!
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 40.0),
                                        child: SizedBox(
                                          height: 40,
                                          child: ElevatedButton(
                                            onPressed: null,
                                            child: Text(
                                                'Ajouter un Etablissement'),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Wrap(
                                    children: [
                                      SizedBox(
                                        width: 440,
                                        child: Card(
                                          child: InkWell(
                                            onTap: () {
                                              ref
                                                  .read(etablissementProvider)
                                                  .selectedRestaurant(
                                                      restaurant);
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Stack(
                                                        children: [
                                                          restaurant.avatar!
                                                                  .isNotEmpty
                                                              ? CircleAvatar(
                                                                  radius: 30,
                                                                  backgroundImage:
                                                                      NetworkImage(
                                                                          restaurant
                                                                              .avatar!),
                                                                )
                                                              : const CircleAvatar(
                                                                  radius: 30,
                                                                  child: Icon(Icons
                                                                      .storefront),
                                                                ),
                                                          Positioned(
                                                            bottom: 0.0,
                                                            right: 0.0,
                                                            child: ClipOval(
                                                              child: Container(
                                                                height: 25,
                                                                width: 25,
                                                                child: Center(
                                                                  child: Text(
                                                                    '4.7',
                                                                    style: Theme.of(
                                                                            context)
                                                                        .textTheme
                                                                        .headline6!
                                                                        .copyWith(
                                                                          fontSize:
                                                                              9.0,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                  ),
                                                                ),
                                                                color: Theme.of(
                                                                        context)
                                                                    .secondaryHeaderColor,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                          width: 10.0),
                                                      SizedBox(
                                                        width: 240,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(restaurant
                                                                .nom!),
                                                            Text(
                                                              '${restaurant.adresse!.rue}, ${restaurant.adresse!.codepostal} ${restaurant.adresse!.ville}',
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: 10.0),
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      const Text('En ligne'),
                                                      Switch(
                                                        value:
                                                            restaurant.enLigne!,
                                                        onChanged:
                                                            restaurant.avatar!
                                                                    .isNotEmpty
                                                                ? (value) {
                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'list_restaurant')
                                                                        .doc(utilisateur
                                                                            .idRestaurant)
                                                                        .update({
                                                                      'enLigne':
                                                                          value
                                                                    });
                                                                  }
                                                                : (value) {
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                      SnackBar(
                                                                        content:
                                                                            const Text(
                                                                          'Veillez ajouter une image pour la mise en ligne',
                                                                        ),
                                                                        backgroundColor:
                                                                            Theme.of(context).secondaryHeaderColor,
                                                                        duration:
                                                                            const Duration(milliseconds: 500),
                                                                      ),
                                                                    );
                                                                  },
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                    const EtablissementTab(),
                  ],
                ),
    );
  }
}

class EtablissementTab extends StatelessWidget {
  const EtablissementTab({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      final etablissementState = ref.watch(etablissementProvider);
      return etablissementState.drawerValue
          ? Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Column(
                  children: [
                    AppBar(
                      backgroundColor: Theme.of(context).secondaryHeaderColor,
                      actions: [
                        DetailSaveButton(
                          onPressedSave: etablissementState.restaurant != null
                              ? () async {
                                  await etablissementState.updateRestaurant();
                                }
                              : null,
                        ),
                        IconButton(
                          onPressed: () {
                            ref
                                .read(etablissementProvider)
                                .selectedRestaurant(null);
                          },
                          icon: Icon(
                            Icons.close,
                            color: Theme.of(context).primaryColor,
                          ),
                          splashRadius: 20.0,
                        )
                      ],
                    ),
                    SizedBox(
                      height: 220,
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: etablissementState.restaurantAvatar!.isNotEmpty
                            ? Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(etablissementState
                                            .restaurantAvatar!),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0.0,
                                    right: 0.0,
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
                                              .read(etablissementProvider)
                                              .setRestaurantAvatar(value);
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
                              )
                            : SizedBox(
                                child: Center(
                                  child: IconButton(
                                    icon: const Icon(Icons.image),
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
                                            .read(etablissementProvider)
                                            .setRestaurantAvatar(value);
                                      }
                                    }),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Selectionner la categorie : ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: FirebaseFirestore.instance
                              .collection('list_restaurants_categorie')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.active) {
                              if (snapshot.hasData) {
                                List<DropdownMenuItem<Categorie>>
                                    categorieItems =
                                    snapshot.data!.docs.map((e) {
                                  Categorie categorie =
                                      Categorie.fromJson(e.data());
                                  return DropdownMenuItem<Categorie>(
                                    child: Text(categorie.nom != null
                                        ? categorie.nom!
                                        : categorie.id!),
                                    value: categorie,
                                  );
                                }).toList();

                                return DropdownButton<Categorie>(
                                  icon: const Icon(Icons.arrow_downward),
                                  elevation: 16,
                                  onChanged: (Categorie? newValue) {
                                    etablissementState
                                        .setSelectedCategorie(newValue);
                                  },
                                  selectedItemBuilder: (context) {
                                    return snapshot.data!.docs.map((e) {
                                      Categorie categorie =
                                          Categorie.fromJson(e.data());
                                      return Text(categorie.nom != null
                                          ? categorie.nom!
                                          : categorie.id!);
                                    }).toList();
                                  },
                                  items: categorieItems,
                                );
                              }
                            }
                            return const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                      ],
                    ),
                    const Divider(),
                    const Text(
                      'Types de paiements acceptés : ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Cartes bancaires :'),
                        Checkbox(
                            value: etablissementState.cartes,
                            onChanged: (value) async {
                              bool? canUpdate =
                                  await etablissementState.setCarte(value);
                              if (canUpdate != null) {
                                if (!canUpdate) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text(
                                          'Problème lors du changement'),
                                      content: const Text(
                                          'Vous ne pouvez pas refuser tous les types de paiements'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Ok'),
                                        )
                                      ],
                                    ),
                                  );
                                }
                              }
                            }),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Espèces :'),
                        Checkbox(
                            value: etablissementState.especes,
                            onChanged: (value) async {
                              bool? canUpdate =
                                  await etablissementState.setEspece(value);
                              if (canUpdate != null) {
                                if (!canUpdate) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text(
                                          'Problème lors du changement'),
                                      content: const Text(
                                          'Vous ne pouvez pas refuser tous les types de paiements'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Ok'),
                                        )
                                      ],
                                    ),
                                  );
                                }
                              }
                            }),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : SizedBox.fromSize();
    });
  }
}

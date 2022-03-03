import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libertyrestaurant/models/restaurant_menu/restaurant_menu.dart';
import 'package:libertyrestaurant/pages/menus/menus_restaurant/menu_restaurant_detail.dart';
import 'package:libertyrestaurant/state_management/state_management.dart';

final menuProvider =
    ChangeNotifierProvider.autoDispose<MenuStateProvider>((ref) {
  return MenuStateProvider();
});

class MenuStateProvider with ChangeNotifier {
  RestaurantMenu? restaurantMenu;

  selectedMenu(RestaurantMenu? menu) {
    restaurantMenu = menu;
    notifyListeners();
  }
}

class MenusRestaurant extends StatefulWidget {
  const MenusRestaurant({Key? key}) : super(key: key);

  @override
  State<MenusRestaurant> createState() => _MenusRestaurantState();
}

class _MenusRestaurantState extends State<MenusRestaurant> {
  ScrollController scrollController = ScrollController();

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
              child: Consumer(builder: (context, ref, _) {
                final menuState = ref.watch(menuProvider);
                return ElevatedButton(
                  onPressed: menuState.restaurantMenu != null
                      ? menuState.restaurantMenu!.id.isNotEmpty
                          ? () {
                              final menu = RestaurantMenu(
                                id: '',
                                nom: '',
                                description: '',
                                categorie: null,
                                prix: 0,
                              );
                              ref.read(menuProvider).selectedMenu(menu);
                              ref.read(menuDetailProvider).initController(menu);
                              ref.read(menuDetailProvider).setDrawerValue(true);
                            }
                          : () {
                              ref.read(menuDetailProvider).setDrawerValue(true);
                            }
                      : () {
                          final menu = RestaurantMenu(
                            id: '',
                            nom: '',
                            description: '',
                            categorie: null,
                            prix: 0,
                          );
                          ref.read(menuProvider).selectedMenu(menu);
                          ref.read(menuDetailProvider).initController(menu);
                          ref.read(menuDetailProvider).setDrawerValue(true);
                        },
                  child: const Text('Ajouter un menu'),
                );
              }),
            ),
          ),
        ),
        body: appState.utilisateur != null
            ? StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('list_restaurant')
                    .doc(appState.utilisateur!.idRestaurant)
                    .collection('menus')
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
                    controller: scrollController,
                    children: ListTile.divideTiles(
                      context: context,
                      tiles: snapshot.data!.docs.map(
                        (e) {
                          RestaurantMenu menu = RestaurantMenu.fromJson(
                              e.data() as Map<String, dynamic>);

                          return Consumer(builder: (context, ref, _) {
                            final restaurantMenu =
                                ref.watch(menuProvider).restaurantMenu;
                            return ListTile(
                              leading: menu.avatar != null
                                  ? CircleAvatar(
                                      backgroundColor:
                                          Theme.of(context).primaryColor,
                                      backgroundImage:
                                          NetworkImage(menu.avatar!),
                                    )
                                  : null,
                              title: Text(menu.nom),
                              subtitle: Text(menu.description!),
                              trailing: SizedBox(
                                width: 160,
                                child: SizedBox(
                                  width: 90,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText:
                                          '${menu.prix.toStringAsFixed(2)} €',
                                    ),
                                    readOnly: true,
                                  ),
                                ),
                              ),
                              onTap: restaurantMenu != null
                                  ? restaurantMenu.id == menu.id
                                      ? () {}
                                      : () {
                                          ref
                                              .read(menuProvider)
                                              .selectedMenu(menu);
                                          ref
                                              .read(menuDetailProvider)
                                              .initController(menu);
                                        }
                                  : () {
                                      ref.read(menuProvider).selectedMenu(menu);
                                      ref
                                          .read(menuDetailProvider)
                                          .initController(menu);
                                      ref
                                          .read(menuDetailProvider)
                                          .setDrawerValue(true);
                                      ref
                                          .read(menuDetailProvider)
                                          .setDrawerValue(true);
                                    },
                              selectedColor:
                                  Theme.of(context).secondaryHeaderColor,
                              selected: restaurantMenu != null
                                  ? restaurantMenu.id == menu.id
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapte_cms/pages/menus/categories_restaurant/categorie_restaurant_detail.dart';
import 'package:kapte_cms/pages/menus/groupe_produits_restaurant/groupes_poduits_restaurant.dart';
import 'package:kapte_cms/pages/menus/groupe_produits_restaurant/groupe_produits_restaurant_detail.dart';
import 'package:kapte_cms/pages/menus/menus_restaurant/menu_groupe_produits.dart';
import 'package:kapte_cms/pages/menus/menus_restaurant/menu_restaurant_detail.dart';

import 'categories_restaurant/categories_restaurant.dart';
import 'menus_restaurant/menus_restaurant.dart';

class MenusPage extends StatefulWidget {
  const MenusPage({Key? key}) : super(key: key);

  @override
  State<MenusPage> createState() => _MenusPageState();
}

class _MenusPageState extends State<MenusPage> {
  int pageIndex = 0;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: pageIndex,
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: SizedBox(
            width: 700.0,
            child: TabBar(
              indicatorColor: Theme.of(context).primaryColor,
              tabs: <Widget>[
                Tab(
                  child: Text(
                    'Menus',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
                Tab(
                  child: Text(
                    'Catégories',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
                Tab(
                  child: Text(
                    'Groupes de Produits',
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
              ],
              onTap: (index) {
                setState(() {
                  pageIndex = index;
                });
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {},
              child: Row(
                children: const [
                  Icon(Icons.info_outline),
                  Text('À propos'),
                ],
              ),
            )
          ],
        ),
        body: IndexedStack(
          index: pageIndex,
          children: [
            Builder(builder: (context) {
              return Row(
                children: [
                  const Expanded(
                    flex: 4,
                    child: MenusRestaurant(),
                  ),
                  Consumer(builder: (context, ref, _) {
                    final drawerDetail =
                        ref.watch(menuDetailProvider).drawerValue;
                    return drawerDetail
                        ? const Expanded(
                            flex: 3,
                            child: MenuRestaurantDetail(),
                          )
                        : SizedBox.fromSize();
                  }),
                  Consumer(
                    builder: (context, ref, _) {
                      final menuGroupeDrawer =
                          ref.watch(menuGroupeDrawerProvider);
                      return menuGroupeDrawer
                          ? const Expanded(
                              flex: 2,
                              child: MenuGroupeProduits(),
                            )
                          : const SizedBox.shrink();
                    },
                  ),
                ],
              );
            }),
            Row(
              children: [
                const Expanded(
                  flex: 8,
                  child: CategoriesRestaurant(),
                ),
                Consumer(builder: (context, ref, _) {
                  final drawerDetail = ref.watch(categorieProvider).drawerValue;
                  return drawerDetail
                      ? const Expanded(
                          flex: 4,
                          child: CategorieRestaurantDetail(),
                        )
                      : const SizedBox.shrink();
                }),
                const VerticalDivider(),
              ],
            ),
            Row(
              children: [
                const Expanded(
                  flex: 8,
                  child: GroupesProduitsRestaurant(),
                ),
                Consumer(builder: (context, ref, _) {
                  final drawerDetail =
                      ref.watch(groupeProduitsDetailProvider).drawerValue;
                  return drawerDetail
                      ? const Expanded(
                          flex: 4,
                          child: GroupeProduitsRestaurantDetail(),
                        )
                      : const SizedBox.shrink();
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapte_cms/routing/route_state.dart';
import 'package:kapte_cms/state_management/state_management.dart';
import 'package:kapte_cms/widgets/drawer_item.dart';

class MyDrawer extends StatefulWidget {
  const MyDrawer({
    Key? key,
    required this.drawerWidth,
    required this.drawerOpen,
  }) : super(key: key);
  final double drawerWidth;
  final bool drawerOpen;
  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  @override
  Widget build(BuildContext context) {
    final routeState = RouteStateScope.of(context);
    var drawerWidth = widget.drawerWidth;
    var drawerOpen = widget.drawerOpen;
    int nombreCommandeEnCours = 0;

    return Consumer(builder: (context, ref, _) {
      return Card(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: ListView(
            children: [
              DrawerItem(
                drawerWidth: drawerWidth,
                icon: Icons.home_outlined,
                title: 'Accueil',
                drawerState: drawerOpen,
                value: '/accueil',
                onTap: (value) {
                  routeState.go('/accueil');
                },
              ),
              DrawerItem(
                drawerWidth: drawerWidth,
                icon: Icons.store_outlined,
                title: 'Etablissement',
                drawerState: drawerOpen,
                value: '/etablissement',
                onTap: (value) {
                  routeState.go('/etablissement');
                },
              ),
              DrawerItem(
                drawerWidth: drawerWidth,
                icon: Icons.restaurant_menu_outlined,
                title: 'Menus',
                value: '/menus',
                drawerState: drawerOpen,
                onTap: (value) {
                  routeState.go('/menus');
                },
              ),
              DrawerItem(
                drawerWidth: drawerWidth,
                icon: Icons.receipt_outlined,
                title: 'Commandes',
                value: '/commandes',
                drawerState: drawerOpen,
                onTap: (value) {
                  routeState.go('/commandes');
                },
                badgeContent: Consumer(builder: (context, ref, _) {
                  final appState = ref.watch(appStateProvider);
                  return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('commandes_restauration')
                          .where(
                            'restaurant.id',
                            isEqualTo: appState.utilisateur!.idRestaurant,
                          )
                          .where('status.termine', isEqualTo: false)
                          .orderBy('date', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text('');
                        }
                        if (snapshot.data != null) {
                          if (nombreCommandeEnCours !=
                              snapshot.data!.docs.length) {
                            nombreCommandeEnCours = snapshot.data!.docs.length;
                          }
                        }
                        return Text(
                          nombreCommandeEnCours.toString(),
                          style: const TextStyle(color: Colors.white),
                        );
                      });
                }),
              ),
              DrawerItem(
                drawerWidth: drawerWidth,
                icon: Icons.payment_outlined,
                title: 'Paiements',
                value: '/paiements',
                drawerState: drawerOpen,
                onTap: (value) {
                  routeState.go('/paiements');
                },
              ),
              DrawerItem(
                drawerWidth: drawerWidth,
                icon: Icons.folder_outlined,
                title: 'Documents',
                value: '/documents',
                drawerState: drawerOpen,
                onTap: (value) {
                  routeState.go('/documents');
                },
              ),
              DrawerItem(
                drawerWidth: drawerWidth,
                icon: Icons.people_outline,
                title: 'Utilisateurs',
                value: '/comptes',
                drawerState: drawerOpen,
                onTap: (value) {
                  routeState.go('/comptes');
                },
              ),
              DrawerItem(
                drawerWidth: drawerWidth,
                icon: Icons.settings_outlined,
                title: 'Paramètres',
                value: '/settings',
                drawerState: drawerOpen,
                onTap: (value) {
                  routeState.go('/settings');
                },
              ),
            ],
          ),
        ),
      );
    });
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libertyrestaurant/models/restaurant/restaurant.dart';
import 'package:libertyrestaurant/models/utilisateur/utilisateur.dart';
import 'package:libertyrestaurant/state_management/state_management.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final utilisateur = ref.watch(appStateProvider).utilisateur;
    return utilisateur == null
        ? const SizedBox.shrink()
        : utilisateur.idRestaurant == null
            ? const SizedBox.shrink()
            : Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ListView(
                    children: [
                      AccueilHeader(user: utilisateur),
                      AccueilBody(user: utilisateur),
                    ],
                  ),
                ),
              );
  }
}

class AccueilHeader extends StatelessWidget {
  const AccueilHeader({
    Key? key,
    required this.user,
  }) : super(key: key);

  final Utilisateur? user;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('list_restaurant')
          .doc(user!.idRestaurant)
          .snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> restaurantSnapshot) {
        if (restaurantSnapshot.hasError) {
          return const Center(child: Text('error'));
        }
        if (restaurantSnapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        final restaurant = Restaurant.fromJson(
            restaurantSnapshot.data!.data() as Map<String, dynamic>);
        return Column(
          children: [
            Row(
              children: [
                Text(
                  'Bonjour, ${restaurant.nom!}',
                  style: Theme.of(context).textTheme.headline2!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(width: 10),
                ClipOval(
                  child: Container(
                    height: 25,
                    width: 25,
                    child: Center(
                      child: Text(
                        '4.7',
                        style: Theme.of(context).textTheme.headline6!.copyWith(
                              fontSize: 9.0,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    color: Theme.of(context).secondaryHeaderColor,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined),
                  Text(
                    '${restaurant.adresse!.rue}, ${restaurant.adresse!.codepostal} ${restaurant.adresse!.ville}',
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class AccueilBody extends StatelessWidget {
  const AccueilBody({Key? key, this.user}) : super(key: key);
  final Utilisateur? user;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Text(
                  'Opérations',
                  style: Theme.of(context).textTheme.headline6!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Text(
                'Excellent',
                style: Theme.of(context).textTheme.headline6!.copyWith(
                      color: Colors.green,
                    ),
              ),
            ],
          ),
        ),
        SizedBox(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: ListTile.divideTiles(
                  context: context,
                  tiles: [
                    const ListTileInfo(
                      title: 'Commandes manquées',
                      info: '0',
                      message: 'Commandes manquées',
                    ),
                    const ListTileInfo(
                      title: 'Commandes remboursées',
                      info: '0',
                      message: 'Commandes remboursées',
                    ),
                    const ListTileInfo(
                      title: 'Temps d\'activité',
                      info: '0h 0m',
                      message: 'Temps d\'activité',
                    ),
                    const ListTileInfo(
                      title: 'Commandes annulées',
                      info: '0',
                      message: 'Commandes annulées',
                    ),
                  ],
                ).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ListTileInfo extends StatelessWidget {
  const ListTileInfo({
    Key? key,
    required this.title,
    required this.info,
    required this.message,
  }) : super(key: key);

  final String title;
  final String info;
  final String message;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headline6,
          ),
          const SizedBox(width: 5.0),
          Tooltip(
            child: const Icon(
              Icons.info_outline,
              size: 18,
            ),
            message: message,
          )
        ],
      ),
      subtitle: Text(
        info,
        style: Theme.of(context).textTheme.headline3,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
    );
  }
}

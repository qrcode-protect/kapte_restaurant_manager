import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapte_cms/models/commande_restaurant/commande_restaurant.dart';
import 'package:kapte_cms/pages/commandes/commandes_body.dart';
import 'package:kapte_cms/state_management/state_management.dart';

class CommandeTerminer extends ConsumerWidget {
  CommandeTerminer({Key? key}) : super(key: key);
  final ScrollController controller = ScrollController();

  @override
  Widget build(BuildContext context, ref) {
    final appState = ref.watch(appStateProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('commandes_restauration')
            .where(
              'restaurant.id',
              isEqualTo: appState.utilisateur!.idRestaurant,
            )
            .where('status.termine', isEqualTo: true)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error.toString());

            return const Text('Erreur');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
              controller: controller,
              children: snapshot.data!.docs.map(
                (documentSnapshot) {
                  final commandeData = CommandeRestaurant.fromJson(
                      documentSnapshot.data() as Map<String, dynamic>);

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: CommandeBody(
                        commandeData: commandeData,
                      ),
                    ),
                  );
                },
              ).toList());
        },
      ),
    );
  }
}

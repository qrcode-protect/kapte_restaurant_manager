import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapte_cms/models/utilisateur/utilisateur.dart';
import 'package:kapte_cms/state_management/state_management.dart';

class CommandeState extends ChangeNotifier {}

var commandeStateProvider =
    ChangeNotifierProvider.autoDispose<CommandeState>((ref) => CommandeState());

class CommmandesPage extends ConsumerWidget {
  const CommmandesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appProvider = ref.read(appStateProvider);
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('commandes_restauration')
            .where('id_restaurant',
                isEqualTo: appProvider.utilisateur!.idRestaurant!)
            // .where('restaurantStatus.termine', isEqualTo: false)
            // .where('restaurantStatus.annule', isEqualTo: false)
            // .orderBy('restaurantStatus', descending: true)
            // .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data != null) {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> commande =
                      snapshot.data!.docs[index].data() as Map<String, dynamic>;
                  return Column(children: [
                    Text('Commande ${commande['id']}'),
                    Text('Client ${commande['id_client']}'),
                    FutureBuilder<DocumentSnapshot?>(
                      future: FirebaseFirestore.instance
                          .collection('utilisateurs')
                          .doc(commande['id_client'])
                          .get(),
                      builder: (context,
                          AsyncSnapshot<DocumentSnapshot?> snapshotUser) {
                        print(snapshotUser.connectionState);
                        if (snapshotUser.connectionState ==
                            ConnectionState.done) {
                          if (snapshotUser.data != null) {
                            Utilisateur client = Utilisateur.fromJson(
                                snapshotUser.data!.data()
                                    as Map<String, dynamic>);
                            print(client);
                            return ElevatedButton(
                              onPressed: () {},
                              child: Text(client.nom),
                            );
                          }
                        }
                        return const Text('Pas de client');
                      },
                    )
                  ]);
                },
              );
            }
          }
          return Text('commandes');
        },
      ),
    );
  }
}

Future<Utilisateur?> getClient(String idClient) async {
  DocumentSnapshot clientDoc = await FirebaseFirestore.instance
      .collection('utilisateurs')
      .doc(idClient)
      .get();
  // print(clientDoc.data());
  return Utilisateur.fromJson(clientDoc.data() as Map<String, dynamic>);
  if (clientDoc.exists) {
  } else {
    return null;
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:libertyrestaurant/state_management/state_management.dart';

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
            .where('restaurantStatus.termine', isEqualTo: false)
            .where('restaurantStatus.annule', isEqualTo: false)
            .orderBy('restaurantStatus', descending: true)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            if (snapshot.data != null) {
              snapshot.data!.docs.forEach((element) {
                print(element.data());
              });
              return Text('${snapshot.data!.docs.length}');
            }
          }
          return Text('commandes');
        },
      ),
    );
  }
}

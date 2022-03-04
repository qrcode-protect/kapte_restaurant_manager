import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapte_cms/models/utilisateur/utilisateur.dart';
import 'package:kapte_cms/state_management/state_management.dart';

class ComptesPage extends StatelessWidget {
  const ComptesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('prestataires_restaurant')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('error'));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LinearProgressIndicator();
            }
            final utilisateur = Utilisateur.fromJson(
                snapshot.data!.data() as Map<String, dynamic>);
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Comptes',
                        style: Theme.of(context).textTheme.headline2!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.0),
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                              onPressed: null,
                              child: Text('Ajouter un compte')),
                        ),
                      )
                    ],
                  ),
                  Wrap(
                    children: [
                      SizedBox(
                        width: 400.0,
                        child: Card(
                          child: Center(
                            child: Consumer(builder: (context, ref, _) {
                              final appState = ref.watch(appStateProvider);
                              return ListTile(
                                leading: appState.utilisateur!.avatar.isNotEmpty
                                    ? CircleAvatar(
                                        radius: 20,
                                        backgroundImage: NetworkImage(
                                            appState.utilisateur!.avatar),
                                      )
                                    : const CircleAvatar(
                                        radius: 20,
                                        backgroundImage:
                                            AssetImage('assets/profile.png'),
                                      ),
                                title: Text(utilisateur.nom),
                                subtitle: Text(utilisateur.email),
                                onTap: () {},
                                minVerticalPadding: 20,
                              );
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
    );
  }
}

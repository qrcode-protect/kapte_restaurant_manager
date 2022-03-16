import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapte_cms/models/restaurant/restaurant.dart';
import 'package:kapte_cms/models/utilisateur/utilisateur.dart';
import 'package:kapte_cms/pages/comptes/create_admin_page.dart';
import 'package:kapte_cms/services/data_format.dart';
import 'package:kapte_cms/state_management/state_management.dart';

class ComptesPage extends ConsumerStatefulWidget {
  const ComptesPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ComptesPage> createState() => _ComptesPageState();
}

class _ComptesPageState extends ConsumerState<ComptesPage> {
  int pageIndex = 2;

  @override
  Widget build(BuildContext context) {
    final administrateur = ref.watch(appStateProvider).administrateur;
    return !administrateur
        ? Scaffold(
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
                              style: Theme.of(context)
                                  .textTheme
                                  .headline2!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 40.0),
                              child: SizedBox(
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: null,
                                  child: Text('Ajouter un compte'),
                                ),
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
                                    final appState =
                                        ref.watch(appStateProvider);
                                    return ListTile(
                                      leading: appState
                                              .utilisateur!.avatar.isNotEmpty
                                          ? CircleAvatar(
                                              radius: 20,
                                              backgroundImage: NetworkImage(
                                                  appState.utilisateur!.avatar),
                                            )
                                          : const CircleAvatar(
                                              radius: 20,
                                              backgroundImage: AssetImage(
                                                  'assets/profile.png'),
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
          )
        : DefaultTabController(
            length: 3,
            initialIndex: pageIndex,
            child: Scaffold(
              appBar: TabBar(
                tabs: [
                  Tab(
                    child: Text(
                      'Comptes prestataires validés',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Comptes prestataires en attente',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Comptes Administrateurs',
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                ],
                indicatorColor: Theme.of(context).colorScheme.primary,
                onTap: (index) {
                  setState(() {
                    pageIndex = index;
                  });
                },
              ),
              body: IndexedStack(
                index: pageIndex,
                children: const [
                  ComptesPrestatairesValides(),
                  ComptesPrestatairesEnAttente(),
                  ComptesAdmin(),
                ],
              ),
            ),
          );
  }
}

class ComptesPrestatairesValides extends StatelessWidget {
  const ComptesPrestatairesValides({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('prestataires_restaurant')
          .where('validated', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            List<Utilisateur> listUsers = snapshot.data!.docs
                .map((e) => Utilisateur.fromJson(e.data()))
                .toList();
            return ListView(
              children: [
                ...listUsers
                    .map((user) => ListTile(
                          title: user.idRestaurant != null
                              ? FutureBuilder<
                                      DocumentSnapshot<Map<String, dynamic>>>(
                                  future: FirebaseFirestore.instance
                                      .collection('list_restaurant')
                                      .doc(user.idRestaurant)
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        Restaurant restaurant =
                                            Restaurant.fromJson(
                                                snapshot.data!.data()!);
                                        return Text(
                                            '${user.email} | ${restaurant.nom}');
                                      } else {
                                        return Text(user.email);
                                      }
                                    }
                                    return Text(user.email);
                                  })
                              : Text(user.email),
                          subtitle: user.creationDate != null
                              ? Text(
                                  'Inscription le : ${FormatDate().format(user.creationDate!)} à ${FormatDate().formatMinute(user.creationDate!)}')
                              : null,
                          trailing: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                user.suspended ? Colors.green : Colors.amber,
                              ),
                            ),
                            onPressed: user.suspended
                                ? () async {
                                    await FirebaseFirestore.instance
                                        .collection('prestataires_restaurant')
                                        .doc(user.id)
                                        .update({'suspended': false});
                                  }
                                : () async {
                                    await FirebaseFirestore.instance
                                        .collection('prestataires_restaurant')
                                        .doc(user.id)
                                        .update({'suspended': true});
                                    await FirebaseFirestore.instance
                                        .collection('list_restaurant')
                                        .doc(user.idRestaurant)
                                        .update({'enLigne': false});
                                  },
                            child: Text(user.suspended
                                ? 'Retablir le compte'
                                : 'Suspendre le compte'),
                          ),
                        ))
                    .toList()
              ],
            );
          }
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class ComptesPrestatairesEnAttente extends StatelessWidget {
  const ComptesPrestatairesEnAttente({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('prestataires_restaurant')
          .where('validated', isEqualTo: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            List<Utilisateur> listUsers = snapshot.data!.docs
                .map((e) => Utilisateur.fromJson(e.data()))
                .toList();
            return ListView(
              children: [
                ...listUsers
                    .map((user) => ListTile(
                          title: Text(user.email),
                          subtitle: user.creationDate != null
                              ? Text(
                                  'Inscription le : ${FormatDate().format(user.creationDate!)} à ${FormatDate().formatMinute(user.creationDate!)}')
                              : null,
                          trailing: ElevatedButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('prestataires_restaurant')
                                  .doc(user.id)
                                  .update({'validated': true});
                            },
                            child: const Text('Valider le compte'),
                          ),
                        ))
                    .toList()
              ],
            );
          }
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class ComptesAdminState with ChangeNotifier {
  bool showCreate = false;

  setShowCreate(bool state) {
    showCreate = state;
    notifyListeners();
  }
}

final compteAdminStateProvider =
    ChangeNotifierProvider<ComptesAdminState>((ref) {
  return ComptesAdminState();
});

class ComptesAdmin extends StatelessWidget {
  const ComptesAdmin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('administrateur')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                List<Utilisateur> listUsers = snapshot.data!.docs
                    .map((e) => Utilisateur.fromJson(e.data()))
                    .toList();
                return ListView(
                  children: [
                    ...listUsers
                        .map((user) => ListTile(
                              title: Text(user.email),
                              subtitle: user.creationDate != null
                                  ? Text(
                                      'Creation le : ${FormatDate().format(user.creationDate!)} à ${FormatDate().formatMinute(user.creationDate!)}')
                                  : null,
                              trailing: user.id ==
                                      FirebaseAuth.instance.currentUser!.uid
                                  ? null
                                  : SizedBox(
                                height: 46,
                                    child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.red),
                                        ),
                                        onPressed: () async {
                                          await FirebaseFirestore.instance
                                              .collection(
                                                  'prestataires_restaurant')
                                              .doc(user.id)
                                              .delete();
                                        },
                                        child: const Text('Supprimer le compte'),
                                      ),
                                  ),
                            ))
                        .toList(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 10.0,
                      ),
                      child: Consumer(builder: (context, ref, _) {
                        return SizedBox(
                          height: 46,
                          width: 100,
                          child: ElevatedButton(
                            onPressed: () {
                              ref
                                  .read(compteAdminStateProvider)
                                  .setShowCreate(true);
                            },
                            child: const Text('Ajouter un administrateur'),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              }
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
        Consumer(builder: (context, ref, _) {
          final showCreate = ref.watch(compteAdminStateProvider).showCreate;
          return showCreate ? const CreateAdminPage() : const SizedBox.shrink();
        }),
      ],
    );
  }
}

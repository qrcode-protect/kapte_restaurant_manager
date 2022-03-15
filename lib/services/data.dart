import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kapte_cms/models/utilisateur/utilisateur.dart';

class Data {
  late Utilisateur utilisateur;
  bool administrateur = false;

  Future<Utilisateur> getUtilisateur() async {
    await FirebaseFirestore.instance
        .collection('prestataires_restaurant')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then(
      (value) async {
        if (!value.exists) {
          await FirebaseFirestore.instance
              .collection('administrateur')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .get()
              .then((value) async {
            if (!value.exists) {
              await createUtilisateur();
            } else {
              utilisateur =
                  Utilisateur.fromJson(value.data() as Map<String, dynamic>);
              administrateur = true;
            }
          });
        } else {
          utilisateur =
              Utilisateur.fromJson(value.data() as Map<String, dynamic>);
        }
      },
    );
    return utilisateur;
  }

  Future<Utilisateur> createUtilisateur() async {
    await FirebaseFirestore.instance
        .collection('prestataires_restaurant')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set(
          Utilisateur(
            id: FirebaseAuth.instance.currentUser!.uid,
            avatar: FirebaseAuth.instance.currentUser!.photoURL ?? '',
            email: FirebaseAuth.instance.currentUser!.email ?? '',
            nom: FirebaseAuth.instance.currentUser!.displayName ?? '',
            phone:
                FirebaseAuth.instance.currentUser!.phoneNumber ?? '0600000000',
            token: '',
            validated: false,
            suspended: false,
            creationDate: DateTime.now(),
          ).toJson(),
        )
        .then((value) async {
      await FirebaseFirestore.instance
          .collection('prestataires_restaurant')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) async {
        utilisateur =
            Utilisateur.fromJson(value.data() as Map<String, dynamic>);
      });
    });
    return utilisateur;
  }

  Future<void> createAdmin(User adminUser) async {
    await FirebaseFirestore.instance
        .collection('administrateur')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set(
          Utilisateur(
            id: adminUser.uid,
            avatar: adminUser.photoURL ?? '',
            email: adminUser.email ?? '',
            nom: adminUser.displayName ?? '',
            phone: adminUser.phoneNumber ?? '0600000000',
            token: '',
            validated: true,
            suspended: false,
            creationDate: DateTime.now(),
          ).toJson(),
        );
  }
}

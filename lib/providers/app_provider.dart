import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_login_package/firebase_login_package.dart';
import 'package:flutter/cupertino.dart';
import 'package:kapte_cms/main.dart';
import 'package:kapte_cms/models/utilisateur/utilisateur.dart';
import 'package:kapte_cms/services/data.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class AppStateProvider with ChangeNotifier {
  AppStateProvider() {
    getUser();
  }
  AuthenticationRepository auth = AuthenticationRepository(_auth);
  User? user;
  bool awaitUser = true;
  Utilisateur? utilisateur;
  bool administrateur = false;

  getUser() async {
    user = auth.firebaseAuth.currentUser;
    if (user != null) {
      getUtilisateur();
    } else {
      user = await FirebaseAuth.instance.authStateChanges().first;
      if (user != null) {
        getUtilisateur();
      } else {
        awaitUser = false;
      }
    }
    notifyListeners();
  }

  getUtilisateur() async {
    Data data = Data();
    utilisateur = await data.getUtilisateur();
    administrateur = data.administrateur;
    notifyListeners();
  }

  Future<void> loginWithEmailAndPassword(String email, String password) async {
    await auth.loginWithEmailAndPassword(email, password).then((value) async {
      getUser();
      getUtilisateur();
      print(administrateur);
    });
  }

  Future<void> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      await auth
          .createUserWithEmailAndPassword(email, password)
          .then((value) async {
        getUser();
        getUtilisateur();
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createAdmin(String email, String password) async {
    if (Firebase.apps.where((element) => element.name == 'second').isEmpty) {
      FirebaseApp _secondApp = await Firebase.initializeApp(
          name: 'second', options: firebaseKapteConfig);
    }

    print(Firebase.apps);
    final _secondaryAuth = FirebaseAuth.instanceFor(
      app: Firebase.app('second'),
    );
    print(_secondaryAuth);
    // await _secondaryAuth.setPersistence(Persistence.NONE);
    AuthenticationRepository _secondaryAuthRepo =
        AuthenticationRepository(_secondaryAuth);
    print(_secondaryAuthRepo);
    try {
      await _secondaryAuthRepo
          .createUserWithEmailAndPassword(email, password)
          .then((value) async {
        await Data()
            .createAdmin(_secondaryAuthRepo.firebaseAuth.currentUser!)
            .then((value) => _secondaryAuth.signOut());
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  signOut() async {
    await auth.logOut().then((value) {
      getUser();
      utilisateur = null;
    });
    notifyListeners();
  }
}

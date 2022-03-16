import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_login_package/firebase_login_package.dart';
import 'package:flutter/cupertino.dart';
import 'package:kapte_cms/models/utilisateur/utilisateur.dart';
import 'package:kapte_cms/services/data.dart';
import 'package:flutter_cache/flutter_cache.dart' as cache;

final FirebaseAuth _auth = FirebaseAuth.instance;

class AppStateProvider with ChangeNotifier {
  AppStateProvider() {
    getUser();
  }

  AuthenticationRepository auth = AuthenticationRepository(_auth);
  User? user;
  AuthCredential? userCredential;
  bool awaitUser = true;
  Utilisateur? utilisateur;
  bool administrateur = false;
  String? emailValue;
  String? passwordValue;

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
    emailValue = email;
    passwordValue = password;
    userCredential = await auth
        .loginWithEmailAndPassword(email, password)
        .then((value) async {
      getUser();
      getUtilisateur();
    });
    cache.write('email', emailValue);
    cache.write('password', passwordValue);
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

  Future<void> createdAdmin({
    required String email,
    required String password,
  }) async {
    String emailValue = await cache.load('email');
    String passwordValue = await cache.load('password');
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _auth.signInWithEmailAndPassword(
        email: emailValue,
        password: passwordValue,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(e.code);
    }
  }

  signOut() async {
    await auth.logOut().then((value) {
      getUser();
      cache.clear();
      utilisateur = null;
    });
    notifyListeners();
  }
}

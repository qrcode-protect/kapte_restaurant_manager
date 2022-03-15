import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapte_cms/state_management/state_management.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailContoller = TextEditingController();
  TextEditingController passwordContoller = TextEditingController();
  TextEditingController validationPasswordContoller = TextEditingController();
  bool singInState = false;
  bool notSeePassword = true;
  bool onErrorValue = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: true,
          children: [
            Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width < 500
                    ? MediaQuery.of(context).size.width
                    : 500,
                height: MediaQuery.of(context).size.height * .8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            // SizedBox(
                            //   height: 80,
                            //   width: 340,
                            //   child: Image.asset('assets/logo.png'),
                            // ),
                            ListTile(
                              title: Text(
                                'Créez votre compte',
                                style: Theme.of(context)
                                    .textTheme
                                    .headline3!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                              ),
                              subtitle: const Text(
                                  'Remplissez les informations necessaires pour vous inscrire.'),
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: TextFormField(
                                controller: emailContoller,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Email',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez saisir une valeur';
                                  }

                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: TextFormField(
                                controller: validationPasswordContoller,
                                obscureText: notSeePassword,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Mot de passe',
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        notSeePassword = !notSeePassword;
                                      });
                                    },
                                    icon: Icon(
                                      !notSeePassword
                                          ? Icons.remove_red_eye_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    splashRadius: 20,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez saisir une valeur';
                                  }
                                  if (value !=
                                      validationPasswordContoller.text) {
                                    return 'Les mots de passes doivent être identiques';
                                  }

                                  return null;
                                },
                              ),
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: TextFormField(
                                controller: passwordContoller,
                                obscureText: notSeePassword,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Validation du mot de passe',
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        notSeePassword = !notSeePassword;
                                      });
                                    },
                                    icon: Icon(
                                      !notSeePassword
                                          ? Icons.remove_red_eye_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    splashRadius: 20,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez saisir une valeur';
                                  }
                                  if (value != passwordContoller.value.text) {
                                    return 'Les mots de passes doivent être identiques';
                                  }
                                  return null;
                                },
                                onFieldSubmitted: (value) {
                                  handleSubmit();
                                },
                              ),
                            ),
                            SizedBox(
                              height: 40,
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: !singInState
                                    ? () {
                                        handleSubmit();
                                      }
                                    : () {},
                                child: !singInState
                                    ? const Text('Créer le compte')
                                    : const SizedBox(
                                        width: 25,
                                        height: 25,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                            Visibility(
                              visible: onErrorValue,
                              child: Text(
                                errorMessage != null
                                    ? errorMessage!
                                    : 'Votre email ou mot de passe est incorrect',
                                style: const TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
      bottomSheet: Container(
        width: double.infinity,
        height: 40.0,
        color: Theme.of(context).primaryColor,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                '©kapte 2022',
                style: Theme.of(context)
                    .textTheme
                    .headline6!
                    .copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(
        () {
          singInState = true;
          errorMessage = null;
        },
      );
      await createAccountFirebase();
      if (FirebaseAuth.instance.currentUser != null) {
        Navigator.of(context).pop();
      }
    }
  }

  createAccountFirebase() async {
    await ref
        .read(appStateProvider)
        .createUserWithEmailAndPassword(
          emailContoller.value.text,
          passwordContoller.value.text,
        )
        .catchError((e) {
      setState(
        () {
          switch (e.code) {
            case 'email-already-in-use':
              errorMessage = 'Un compte avec cet email existe déjà.';
              break;
            case 'weak-password':
              errorMessage = 'Mot de passe trop faible.';
              break;
          }
          singInState = false;
          onErrorValue = true;
        },
      );
    });
  }
}

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapte_cms/pages/pages.dart';
import 'package:kapte_cms/state_management/state_management.dart';

class CreateAdminPage extends ConsumerStatefulWidget {
  const CreateAdminPage({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateAdminPage> createState() => _CreateAdminPageState();
}

class _CreateAdminPageState extends ConsumerState<CreateAdminPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailContoller = TextEditingController();
  TextEditingController passwordContoller = TextEditingController();
  TextEditingController validatePasswordContoller = TextEditingController();

  bool singInState = false;
  bool notSeePassword = true;
  bool onErrorValue = false;
  String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width < 500
              ? MediaQuery.of(context).size.width
              : 500,
          height: MediaQuery.of(context).size.height * .8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              'Ajouter un administrateur',
                              style: Theme.of(context)
                                  .textTheme
                                  .headline3!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                            ),
                            subtitle: const Text(
                                'Remplissez les informations necessaires.'),
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
                              controller: passwordContoller,
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
                                if (value != validatePasswordContoller.text) {
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
                              controller: validatePasswordContoller,
                              obscureText: notSeePassword,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Valider le mot de passe',
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
                                if (value != passwordContoller.text) {
                                  return 'Les mots de passes doivent être identiques';
                                }

                                return null;
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
                                  ? const Text('Ajouter')
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
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onPressed: () {
                        ref.read(compteAdminStateProvider).setShowCreate(false);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  )
                ],
              ),
            ],
          ),
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
          onErrorValue = false;
        },
      );
      await createdAdminAccount();
      setState(() {
        singInState = false;
      });
      if (!onErrorValue) {
        ref.read(compteAdminStateProvider).setShowCreate(false);
      }
    }
  }

  createdAdminAccount() async {
    await ref
        .read(appStateProvider)
        .createAdmin(
          email: emailContoller.value.text,
          password: passwordContoller.value.text,
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
            case 'invalid-email':
              errorMessage = 'Mail non valide';
              break;
          }
          singInState = false;
          onErrorValue = true;
        },
      );
    });
  }
}

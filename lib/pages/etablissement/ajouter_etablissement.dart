import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kapte_cms/models/adresse/adresse.dart';
import 'package:kapte_cms/models/categorie/categorie.dart';
import 'package:kapte_cms/models/restaurant/restaurant.dart';
import 'package:kapte_cms/state_management/state_management.dart';
import 'package:kapte_cms/widgets/custom_input.dart';
import 'package:kapte_cms/widgets/popup_bottom_button.dart';

class AjouterEtablissement extends ConsumerStatefulWidget {
  const AjouterEtablissement({Key? key}) : super(key: key);

  @override
  _AjouterEtablissementState createState() => _AjouterEtablissementState();
}

class _AjouterEtablissementState extends ConsumerState<AjouterEtablissement> {
  ScrollController? controller = ScrollController();
  TextEditingController? nomEtablissementController = TextEditingController();
  TextEditingController? descriptionController = TextEditingController();
  TextEditingController? rueController = TextEditingController();
  TextEditingController? codePostalController = TextEditingController();
  TextEditingController? villeController = TextEditingController();
  bool saveData = false;
  Categorie? dropdownValue;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * .5,
      decoration: const BoxDecoration(),
      child: Form(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: false,
            backgroundColor: Colors.white,
            title: Text(
              'Ajouter un Etablissement',
              style: Theme.of(context).textTheme.headline3,
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                CustomInput(
                  controller: nomEtablissementController,
                  hintText: 'Nom de l\'établissement',
                ),
                CustomInput(
                  controller: descriptionController,
                  hintText: 'Desciption',
                  minLines: 3,
                  maxLines: 6,
                ),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('list_restaurants_categorie')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return const Text('Error');
                    }
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        height: 70,
                        width: double.infinity,
                        color: Theme.of(context).inputDecorationTheme.fillColor,
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                      ),
                      child: Container(
                        color: Theme.of(context).inputDecorationTheme.fillColor,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton<Categorie>(
                            value: null,
                            hint: dropdownValue != null
                                ? Text(dropdownValue!.nom!)
                                : const Text('Choisir la catégorie'),
                            underline: const SizedBox.shrink(),
                            items: snapshot.data!.docs.map((e) {
                              final categorie = Categorie.fromJson(
                                  e.data() as Map<String, dynamic>);
                              return DropdownMenuItem<Categorie>(
                                value: categorie,
                                child: Text(categorie.nom!),
                              );
                            }).toList(),
                            onChanged: (Categorie? newValue) {
                              setState(() {
                                dropdownValue = newValue!;
                              });
                            },
                            isExpanded: true,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Row(
                    children: [
                      const Text('Adresse'),
                      Expanded(
                        child: Container(
                          margin:
                              const EdgeInsets.only(left: 15.0, right: 10.0),
                          child: const Divider(),
                        ),
                      ),
                    ],
                  ),
                ),
                CustomInput(
                  controller: rueController,
                  hintText: 'Rue',
                ),
                CustomInput(
                  controller: codePostalController,
                  hintText: 'Code postal',
                ),
                CustomInput(
                  controller: villeController,
                  hintText: 'Ville',
                ),
              ],
            ),
          ),
          bottomSheet: PopupBottomButton(
            onPressed: () {
              addRestaurant(
                Restaurant(
                  id: '',
                  nom: nomEtablissementController!.value.text,
                  avatar: '',
                  categorie: dropdownValue,
                  description: descriptionController!.value.text,
                  adresse: Adresse(
                    '',
                    rueController!.value.text,
                    villeController!.value.text,
                    int.parse(codePostalController!.value.text),
                    'France',
                  ),
                  enLigne: false,
                ),
              );
            },
            onSaveData: saveData,
          ),
        ),
      ),
    );
  }

  addRestaurant(Restaurant restaurant) async {
    setState(() {
      saveData = true;
    });
    await FirebaseFirestore.instance
        .collection('list_restaurant')
        .add(restaurant.toJson())
        .then((value) {
      FirebaseFirestore.instance
          .collection('list_restaurant')
          .doc(value.id)
          .update({'id': value.id}).then((value) {});
      FirebaseFirestore.instance
          .collection('prestataires_restaurant')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({'idRestaurant': value.id}).then((value) {
        ref.read(appStateProvider).getUtilisateur();
      });
    });
  }
}

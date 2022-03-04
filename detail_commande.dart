import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kapteappcustomer/app_state/state_management.dart';
import 'package:kapteappcustomer/model/carte_paiement.dart';
import 'package:kapteappcustomer/model/commande_restaurant.dart';
import 'package:kapteappcustomer/model/commande_status.dart';
import 'package:kapteappcustomer/services/panier.dart';
import 'package:kapteappcustomer/ui/pages/loading.dart';
import 'package:kapteappcustomer/ui/pages/restaurant_details.dart';
import 'package:kapteappcustomer/ui/pages/wallet/wallet.dart';
import 'package:kapteappcustomer/utils.dart';
import 'package:kapteappcustomer/widget/button_validation.dart';

import 'package:payment_e_story/payment_e_story.dart' as estory;

class CommandeDetailPage extends ConsumerStatefulWidget {
  const CommandeDetailPage({Key? key}) : super(key: key);

  @override
  _CommandeDetailPageState createState() => _CommandeDetailPageState();
}

class _CommandeDetailPageState extends ConsumerState<CommandeDetailPage> {
  bool isLoading = false;
  CartePaiement? cartePaiement;
  String? errorPayment;
  @override
  Widget build(BuildContext context) {
    cartePaiement = ref.read(authRepositoryProvider).userInfo!.cartePaiement;
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('utilisateurs')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('restaurant_panier')
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        num prix = 0.0;
        List<Map<String, dynamic>> listMenuPanier = [];
        CommandeRestaurant? commande;

        return Stack(
          children: [
            Scaffold(
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    expandedHeight: 90,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        'Emporter',
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text('Ma commande',
                              style: Theme.of(context).textTheme.headline4),
                        ),
                        Column(
                          children: [
                            ...snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                              commande = CommandeRestaurant.fromMap(
                                  document.data()! as Map<String, dynamic>);
                              prix = prix + commande!.prix!;
                              listMenuPanier.add(commande!.toJson());
                              return Column(
                                children: [
                                  ListTile(
                                    title: Text(commande!.menu!.nom),
                                    leading:
                                        Text(commande!.quantite.toString()),
                                    trailing: Text(
                                        '${commande!.prix!.toStringAsFixed(2)} €'),
                                  ),
                                  Column(
                                    children: [
                                      ...commande!.listSousMenuRequis!.map(
                                        (sousMenuRequis) {
                                          return ListTile(
                                            title: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20.0),
                                              child: Text(sousMenuRequis.nom!),
                                            ),
                                          );
                                        },
                                      ),
                                      ...commande!.listSousMenu!.map(
                                        (sousMenu) {
                                          return ListTile(
                                            title: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 20.0),
                                              child: Text(sousMenu.nom!),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }).toList(),
                            ListTile(
                              leading: Text(
                                'Total',
                                style: Theme.of(context).textTheme.headline4,
                              ),
                              trailing: Text(
                                '${prix.toStringAsFixed(2)} €',
                                style: Theme.of(context).textTheme.headline4,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          height: 56,
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: errorPayment != null
                                    ? Colors.red
                                    : Colors.transparent,
                              ),
                            ),
                            leading: cartePaiement != null
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      cartePaiement!.cardType !=
                                              CardType.other.name
                                          ? cartePaiement!.cardType !=
                                                  CardType.masterCard.name
                                              ? FaIcon(
                                                  FontAwesomeIcons.ccVisa,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                )
                                              : FaIcon(
                                                  FontAwesomeIcons.ccMastercard,
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                )
                                          : FaIcon(
                                              FontAwesomeIcons.creditCard,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                    ],
                                  )
                                : Icon(Icons.add),
                            title: cartePaiement != null
                                ? Text(
                                    '**** ${cartePaiement!.cardNumber.toString().substring(cartePaiement!.cardNumber.toString().length - 4)}',
                                  )
                                : Text('Selectionner un moyen de paiement'),
                            trailing: Icon(
                              Icons.adaptive.arrow_forward,
                              size: 15,
                            ),
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (contex) => Wallet(
                                  navigate: true,
                                ),
                              ).then((value) {
                                if (value != null) {
                                  if (value) {
                                    setState(() {
                                      cartePaiement = ref
                                          .watch(authRepositoryProvider)
                                          .userInfo!
                                          .cartePaiement;
                                      errorPayment = null;
                                    });
                                  }
                                }
                              });
                            },
                          ),
                        ),
                        errorPayment != null
                            ? Text(
                                errorPayment!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              )
                            : SizedBox.shrink(),
                        SizedBox(height: 160.0)
                      ],
                    ),
                  ),
                ],
              ),
              bottomSheet: SizedBox(
                height: 160,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SizedBox(
                        height: 60.0,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RestaurantDetails(
                                  restaurant: commande!.restaurant!,
                                  visibleBtnPanier: false,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'Ajouter des articles',
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: Color(0xFFFAFAFA),
                          ),
                        ),
                      ),
                    ),
                    ButtonValidation().button(
                      child: Text(
                        'OK ${prix.toStringAsFixed(2)} €',
                        style: Theme.of(context).textTheme.headline4!.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      onPressed: cartePaiement != null
                          ? () {
                              sendPayement(
                                  commande: listMenuPanier, prix: prix);
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ),
            if (isLoading) Loading(),
          ],
        );
      },
    );
  }

  sendPayement({num? prix, List? commande}) async {
    setState(() {
      isLoading = true;
    });
    estory.PaymentMethod pay = estory.Stripe();
    estory.PaymentInfo info = estory.PaymentInfo(
      amount: (double.parse(prix.toString().replaceAll(',', '.')) * 100)
          .round()
          .toString(),
      currency: 'eur',
      type: 'card',
    );
    pay.setApiKey(apiKeyStripe);
    pay.setCard(
      estory.Card(
        type: cartePaiement!.type!,
        cardNumber: cartePaiement!.cardNumber.toString(),
        cardExpMonth: cartePaiement!.cardExpMonth.toString(),
        cardExpYear: cartePaiement!.cardExpYear.toString(),
        cardCvc: cartePaiement!.cardCvc.toString(),
      ),
    );
    pay.setInfo(info);
    await pay.createPayment();
    if (pay.details!.status == 'succeeded') {
      saveCommandeToData(commande!);
    } else {
      setState(() {
        isLoading = false;
        errorPayment =
            'Une erreur est survenue lors du payement, verifiez votre carte.';
      });
      print('payment failed');
    }
  }

  saveCommandeToData(List commande) async {
    await PanierData().clearPanier();
    await FirebaseFirestore.instance.collection('commandes_restauration').add({
      'id_restaurant': commande[0]['restaurant']['id'],
      'id_client': FirebaseAuth.instance.currentUser!.uid,
      'commande': commande,
      'status': CommandeStatusRestaurant(
        annule: false,
        encours: false,
        termine: false,
        demande: true,
      ).toJson(),
    });
    Navigator.popUntil(context, ModalRoute.withName('/'));
  }
}

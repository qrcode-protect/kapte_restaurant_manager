import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kapte_cms/models/commande_restaurant/commande_restaurant.dart';
import 'package:kapte_cms/models/commande_restaurant_panier/commande_restaurant_panier.dart';
import 'package:kapte_cms/models/commande_status_restaurant.dart/commande_status_restaurant.dart';
import 'package:kapte_cms/services/data_format.dart';
import 'package:kapte_cms/utils.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CommandeBody extends StatefulWidget {
  const CommandeBody({Key? key, required this.commandeData}) : super(key: key);

  final CommandeRestaurant commandeData;

  @override
  State<CommandeBody> createState() => _CommandeBodyState();
}

class _CommandeBodyState extends State<CommandeBody> {
  bool openContainer = false;

  @override
  Widget build(BuildContext context) {
    List<CommandeRestaurantPanier> panier =
        widget.commandeData.restaurantCommande;
    num prixCommande = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: openContainer
                ? Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor))
                : null,
          ),
          child: ListTile(
            title: Row(
              children: [
                const SizedBox(width: 5.0),
                Text(
                  'Commande - #${widget.commandeData.id!.substring(widget.commandeData.id!.length - 5)}',
                ),
                const SizedBox(
                  width: 10.0,
                ),
                widget.commandeData.paiementType == PaiementType.carte
                    ? const Text('Commande reglée')
                    : const Text(
                        'COMMANDE À REGLER',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ],
            ),
            trailing: SizedBox(
              width: 240.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${FormatDate().format(widget.commandeData.date)} - ${FormatDate().formatMinute(widget.commandeData.date)}',
                  ),
                  Theme(
                    data: Theme.of(context).copyWith(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                    ),
                    child: PopupMenuButton(
                      icon: const Icon(Icons.more_vert_outlined),
                      itemBuilder: (context) {
                        return [
                          const PopupMenuItem(
                            child: ListTile(
                              leading: Icon(Icons.print_outlined),
                              title: Text('Imprimer'),
                            ),
                            value: 0,
                          ),
                          if (!widget.commandeData.status.termine!)
                            const PopupMenuItem(
                              child: ListTile(
                                leading: Icon(Icons.cancel_outlined),
                                title: Text('Annuler la commande'),
                              ),
                              value: 1,
                            ),
                        ];
                      },
                      onSelected: (int index) {
                        if (index == 0) {
                          Printing.layoutPdf(
                            onLayout: (format) =>
                                _generatePdf(PdfPageFormat.roll80, panier),
                          );
                        }
                        if (index == 1) {
                          showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                              title: Text(
                                  'Annuler la Commande - #${widget.commandeData.id!.substring(widget.commandeData.id!.length - 5)}'),
                              content: const Text(
                                  'Voulez-vous vraiment annuler la commande'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Quitter'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('OUI'),
                                ),
                              ],
                            ),
                          ).then((value) {
                            if (value != null) {
                              if (value) {
                                FirebaseFirestore.instance
                                    .collection('commandes_restauration')
                                    .doc(widget.commandeData.id)
                                    .update({
                                  'status':
                                      CommandeStatusRestaurant(annule: true)
                                          .toJson(),
                                });
                              }
                            }
                          });
                        }
                      },
                      offset: const Offset(0, 46),
                    ),
                  ),
                  openContainer
                      ? const Icon(Icons.arrow_drop_up)
                      : const Icon(Icons.arrow_drop_down)
                ],
              ),
            ),
            onTap: () {
              setState(() {
                openContainer = !openContainer;
              });
            },
          ),
        ),
        Visibility(
          visible: openContainer,
          child: Container(
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  child: ListTile(
                    title: Text(widget.commandeData.client.nom),
                    subtitle: Text(widget.commandeData.client.email +
                        (widget.commandeData.client.phone != null
                            ? ' | ${widget.commandeData.client.phone}'
                            : '')),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      ...panier.map((produit) {
                        final listRestaurantProduit =
                            produit.listRestaurantProduit;
                        final listRestaurantProduitRequis =
                            produit.listRestaurantProduitRequis;
                        prixCommande += produit.prix! * produit.quantite!;
                        return ListTile(
                          title: Text(produit.menu!.nom),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (produit.listRestaurantProduit!.isNotEmpty)
                                ...listRestaurantProduit!.map((e) {
                                  return Text(e.nom.toString());
                                }),
                              if (produit
                                  .listRestaurantProduitRequis!.isNotEmpty)
                                ...listRestaurantProduitRequis!.map((e) {
                                  return Text(e.nom.toString());
                                })
                            ],
                          ),
                          leading: Text(produit.quantite.toString()),
                          trailing:
                              Text('${produit.prix!.toStringAsFixed(2)} €'),
                        );
                      }),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.headline4!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                      ),
                      Text(
                        '${prixCommande.toStringAsFixed(2)} €',
                        style: Theme.of(context).textTheme.headline4!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                      ),
                    ],
                  ),
                ),
                if (!widget.commandeData.status.termine!)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: SizedBox(
                      height: 46.0,
                      width: 400.0,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: !widget.commandeData.status.encours!
                              ? Colors.green
                              : null,
                        ),
                        onPressed: !widget.commandeData.status.encours!
                            ? () {
                                FirebaseFirestore.instance
                                    .collection('commandes_restauration')
                                    .doc(widget.commandeData.id)
                                    .update({
                                  'status':
                                      CommandeStatusRestaurant(encours: true)
                                          .toJson(),
                                });
                              }
                            : () {
                                FirebaseFirestore.instance
                                    .collection('commandes_restauration')
                                    .doc(widget.commandeData.id)
                                    .update({
                                  'status': CommandeStatusRestaurant(
                                    termine: true,
                                    encours: true,
                                  ).toJson(),
                                });
                              },
                        child: !widget.commandeData.status.encours!
                            ? const Text('Valider la commande')
                            : const Text('Terminer la commande'),
                      ),
                    ),
                  )
              ],
            ),
          ),
        )
      ],
    );
  }

  Future<Uint8List> _generatePdf(
      PdfPageFormat format, List<CommandeRestaurantPanier> panier) async {
    final pdf = pw.Document();
    num prixCommande = 0;
    final font = await PdfGoogleFonts.poppinsRegular();
    final fontBold = await PdfGoogleFonts.poppinsSemiBold();
    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData(
          defaultTextStyle: pw.TextStyle(fontSize: 10, font: font),
        ),
        pageFormat: format,
        build: (context) => pw.SizedBox(
          width: double.infinity,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                widget.commandeData.restaurant.nom != null
                    ? widget.commandeData.restaurant.nom!
                    : '',
                style: pw.TextStyle(font: fontBold, fontSize: 14),
              ),
              pw.SizedBox(
                height: 10,
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'N° de commande',
                    style: pw.TextStyle(font: fontBold),
                  ),
                  pw.Text(
                    '#${widget.commandeData.id!.substring(widget.commandeData.id!.length - 5)}',
                  ),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Date',
                  ),
                  pw.Text(
                    FormatDate().formatTicket(widget.commandeData.date),
                  ),
                ],
              ),
              pw.SizedBox(
                height: 10,
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(left: 5),
                child: pw.Text(
                  'Detail',
                ),
              ),
              pw.Divider(),
              ...panier.map((produit) {
                final listRestaurantProduit = produit.listRestaurantProduit;
                final listRestaurantProduitRequis =
                    produit.listRestaurantProduitRequis;
                prixCommande += produit.prix!;
                return pw.Column(
                  children: [
                    pw.Row(
                      children: [
                        pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.SizedBox(
                              child: pw.Text(
                                produit.quantite.toString(),
                              ),
                              width: 15,
                            ),
                          ],
                        ),
                        pw.SizedBox(width: 10),
                        pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              produit.menu!.nom,
                              style: pw.TextStyle(font: fontBold),
                            ),
                            if (produit.listRestaurantProduit!.isNotEmpty)
                              ...listRestaurantProduit!.map((e) {
                                return pw.Padding(
                                  padding: const pw.EdgeInsets.only(left: 15),
                                  child: pw.Text(
                                    e.nom.toString(),
                                  ),
                                );
                              }),
                            if (produit.listRestaurantProduitRequis!.isNotEmpty)
                              ...listRestaurantProduitRequis!.map((e) {
                                return pw.Padding(
                                  padding: const pw.EdgeInsets.only(left: 15),
                                  child: pw.Text(
                                    e.nom.toString(),
                                  ),
                                );
                              })
                          ],
                        ),
                        pw.Spacer(),
                        pw.Text(
                          '${produit.prix!.toStringAsFixed(2)} €',
                        ),
                      ],
                    ),
                  ],
                );
              }),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total',
                    style: pw.TextStyle(font: fontBold),
                  ),
                  pw.Text(
                    '${prixCommande.toStringAsFixed(2)} €',
                  ),
                ],
              ),
              pw.SizedBox(
                height: 20,
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Client',
                    style: pw.TextStyle(font: fontBold),
                  ),
                  pw.Text(
                    widget.commandeData.client.nom,
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
    return pdf.save();
  }
}

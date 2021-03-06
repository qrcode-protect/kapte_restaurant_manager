import 'package:json_annotation/json_annotation.dart';
import 'package:kapte_cms/models/client/client.dart';
import 'package:kapte_cms/models/commande_restaurant_panier/commande_restaurant_panier.dart';
import 'package:kapte_cms/models/commande_status_restaurant.dart/commande_status_restaurant.dart';
import 'package:kapte_cms/models/restaurant/restaurant.dart';
import 'package:kapte_cms/utils.dart';

part 'commande_restaurant.g.dart';

@JsonSerializable()
class CommandeRestaurant {
  CommandeRestaurant({
    this.id,
    required this.restaurant,
    required this.client,
    required this.date,
    required this.status,
    required this.restaurantCommande,
    this.prixLivraison,
    required this.paiementType,
  });
  String? id;
  final Restaurant restaurant;
  final Client client;
  final DateTime date;
  final CommandeStatusRestaurant status;
  final List<CommandeRestaurantPanier> restaurantCommande;
  double? prixLivraison;
  final PaiementType paiementType;

  factory CommandeRestaurant.fromJson(Map<String, dynamic> json) =>
      _$CommandeRestaurantFromJson(json);

  Map<String, dynamic> toJson() => _$CommandeRestaurantToJson(this);
}

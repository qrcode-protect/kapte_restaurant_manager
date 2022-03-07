import 'package:json_annotation/json_annotation.dart';
import 'package:kapte_cms/models/restaurant/restaurant.dart';
import 'package:kapte_cms/models/restaurant_menu/restaurant_menu.dart';
import 'package:kapte_cms/models/restautrant_produit/restaurant_produit.dart';

part 'commande_restaurant_panier.g.dart';

@JsonSerializable()
class CommandeRestaurantPanier {
  CommandeRestaurantPanier({
    this.restaurant,
    this.menu,
    this.prix = 0.0,
    this.quantite = 0,
    this.listRestaurantProduitRequis,
    this.listRestaurantProduit,
  });
  Restaurant? restaurant;
  RestaurantMenu? menu;
  List<RestaurantProduit>? listRestaurantProduitRequis;
  List<RestaurantProduit>? listRestaurantProduit;
  int? quantite;
  num? prix;

  setRestaurant(Restaurant restaurant) {
    this.restaurant = restaurant;
  }

  setMenu(RestaurantMenu menu) {
    this.menu = menu;
  }

  addRestaurantProduitRequis(RestaurantProduit value) {
    listRestaurantProduitRequis!.add(value);
  }

  removeRestaurantProduitRequis(String value) {
    listRestaurantProduitRequis!.removeWhere((item) => item.groupeId == value);
  }

  addRestaurantProduit(RestaurantProduit value) {
    listRestaurantProduit!.add(value);
  }

  removeRestaurantProduit(String value) {
    listRestaurantProduit!.removeWhere((item) => item.id == value);
  }

  setQuantite(int quantite) {
    this.quantite = quantite;
  }

  setPrix(double prix) {
    this.prix = prix;
  }

  factory CommandeRestaurantPanier.fromJson(Map<String, dynamic> json) =>
      _$CommandeRestaurantPanierFromJson(json);

  Map<String, dynamic> toJson() => _$CommandeRestaurantPanierToJson(this);
}

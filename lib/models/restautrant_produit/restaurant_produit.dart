import 'package:json_annotation/json_annotation.dart';

part 'restaurant_produit.g.dart';

@JsonSerializable()
class RestaurantProduit {
  RestaurantProduit({this.id, this.nom, this.prix, this.groupeId});
  String? id;
  String? nom;
  String? groupeId;
  double? prix;

  factory RestaurantProduit.fromJson(Map<String, dynamic> json) =>
      _$RestaurantProduitFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantProduitToJson(this);
}

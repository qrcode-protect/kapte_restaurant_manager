import 'package:json_annotation/json_annotation.dart';

part 'restaurant_groupe_produits.g.dart';

@JsonSerializable()
class RestaurantGroupeProduits {
  RestaurantGroupeProduits({
    this.rank,
    this.id,
    this.nom,
    this.description,
    this.requis,
  });
  final int? rank;
  final String? id;
  final String? nom;
  final String? description;
  final bool? requis;

  factory RestaurantGroupeProduits.fromJson(Map<String, dynamic> json) =>
      _$RestaurantGroupeProduitsFromJson(json);
  Map<String, dynamic> toJson() => _$RestaurantGroupeProduitsToJson(this);
}

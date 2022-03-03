import 'package:json_annotation/json_annotation.dart';

part 'restaurant_menu_categorie.g.dart';

@JsonSerializable()
class RestaurantMenuCategorie {
  RestaurantMenuCategorie({
    this.rank,
    required this.id,
    required this.nom,
  });
  int? rank;
  final String id;
  final String nom;

  factory RestaurantMenuCategorie.fromJson(Map<String, dynamic> json) =>
      _$RestaurantMenuCategorieFromJson(json);
  Map<String, dynamic> toJson() => _$RestaurantMenuCategorieToJson(this);
}

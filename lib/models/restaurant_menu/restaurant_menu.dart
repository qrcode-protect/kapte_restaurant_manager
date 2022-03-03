import 'package:json_annotation/json_annotation.dart';
import 'package:libertyrestaurant/models/categorie/categorie.dart';

part 'restaurant_menu.g.dart';

@JsonSerializable()
class RestaurantMenu {
  RestaurantMenu({
    required this.id,
    required this.nom,
    required this.prix,
    this.categorie,
    this.description,
    this.avatar,
  });
  final String id;
  Categorie? categorie;
  String? avatar;
  final String nom;
  final double prix;
  String? description;

  factory RestaurantMenu.fromJson(Map<String, dynamic> json) =>
      _$RestaurantMenuFromJson(json);
  Map<String, dynamic> toJson() => _$RestaurantMenuToJson(this);
}

import 'package:json_annotation/json_annotation.dart';
import 'package:kapte_cms/models/categorie/categorie.dart';

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

  setCategorie(Categorie categorie) {
    this.categorie = categorie;
  }

  setAvatar(String avatar) {
    this.avatar = avatar;
  }

  setDescription(String description) {
    this.description = description;
  }

  factory RestaurantMenu.fromJson(Map<String, dynamic> json) =>
      _$RestaurantMenuFromJson(json);
  Map<String, dynamic> toJson() => _$RestaurantMenuToJson(this);
}

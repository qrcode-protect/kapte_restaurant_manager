import 'package:json_annotation/json_annotation.dart';
import 'package:libertyrestaurant/models/adresse/adresse.dart';
import 'package:libertyrestaurant/models/categorie/categorie.dart';

part 'restaurant.g.dart';

@JsonSerializable()
class Restaurant {
  Restaurant({
    this.id,
    this.nom,
    this.avatar,
    this.description,
    this.categorie,
    this.adresse,
    this.enLigne,
  });
  String? id;
  String? nom;
  String? avatar;
  Categorie? categorie;
  String? description;
  Adresse? adresse;
  bool? enLigne;

  factory Restaurant.fromJson(Map<String, dynamic> json) =>
      _$RestaurantFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantToJson(this);
}

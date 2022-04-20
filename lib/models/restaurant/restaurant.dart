import 'package:json_annotation/json_annotation.dart';
import 'package:kapte_cms/models/adresse/adresse.dart';
import 'package:kapte_cms/models/categorie/categorie.dart';
import 'package:kapte_cms/models/paiements/paiements.dart';

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
    this.paiements,
  });
  String? id;
  String? nom;
  String? avatar;
  Categorie? categorie;
  String? description;
  Adresse? adresse;
  bool? enLigne;
  Paiements? paiements;

  factory Restaurant.fromJson(Map<String, dynamic> json) =>
      _$RestaurantFromJson(json);

  Map<String, dynamic> toJson() => _$RestaurantToJson(this);
}

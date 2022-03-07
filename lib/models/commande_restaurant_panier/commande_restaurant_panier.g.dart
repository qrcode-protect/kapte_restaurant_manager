// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commande_restaurant_panier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommandeRestaurantPanier _$CommandeRestaurantPanierFromJson(Map json) =>
    CommandeRestaurantPanier(
      restaurant: json['restaurant'] == null
          ? null
          : Restaurant.fromJson(
              Map<String, dynamic>.from(json['restaurant'] as Map)),
      menu: json['menu'] == null
          ? null
          : RestaurantMenu.fromJson(
              Map<String, dynamic>.from(json['menu'] as Map)),
      prix: json['prix'] as num? ?? 0.0,
      quantite: json['quantite'] as int? ?? 0,
      listRestaurantProduitRequis: (json['listRestaurantProduitRequis']
              as List<dynamic>?)
          ?.map((e) =>
              RestaurantProduit.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      listRestaurantProduit: (json['listRestaurantProduit'] as List<dynamic>?)
          ?.map((e) =>
              RestaurantProduit.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );

Map<String, dynamic> _$CommandeRestaurantPanierToJson(
        CommandeRestaurantPanier instance) =>
    <String, dynamic>{
      'restaurant': instance.restaurant?.toJson(),
      'menu': instance.menu?.toJson(),
      'listRestaurantProduitRequis':
          instance.listRestaurantProduitRequis?.map((e) => e.toJson()).toList(),
      'listRestaurantProduit':
          instance.listRestaurantProduit?.map((e) => e.toJson()).toList(),
      'quantite': instance.quantite,
      'prix': instance.prix,
    };

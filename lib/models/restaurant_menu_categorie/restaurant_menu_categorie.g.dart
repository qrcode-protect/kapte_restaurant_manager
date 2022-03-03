// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_menu_categorie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestaurantMenuCategorie _$RestaurantMenuCategorieFromJson(Map json) =>
    RestaurantMenuCategorie(
      rank: json['rank'] as int?,
      id: json['id'] as String,
      nom: json['nom'] as String,
    );

Map<String, dynamic> _$RestaurantMenuCategorieToJson(
        RestaurantMenuCategorie instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'id': instance.id,
      'nom': instance.nom,
    };

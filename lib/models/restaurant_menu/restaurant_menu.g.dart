// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_menu.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestaurantMenu _$RestaurantMenuFromJson(Map json) => RestaurantMenu(
      id: json['id'] as String,
      nom: json['nom'] as String,
      prix: (json['prix'] as num).toDouble(),
      categorie: json['categorie'] == null
          ? null
          : Categorie.fromJson(
              Map<String, dynamic>.from(json['categorie'] as Map)),
      description: json['description'] as String?,
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$RestaurantMenuToJson(RestaurantMenu instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categorie': instance.categorie?.toJson(),
      'avatar': instance.avatar,
      'nom': instance.nom,
      'prix': instance.prix,
      'description': instance.description,
    };

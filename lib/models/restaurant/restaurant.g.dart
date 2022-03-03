// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Restaurant _$RestaurantFromJson(Map json) => Restaurant(
      id: json['id'] as String?,
      nom: json['nom'] as String?,
      avatar: json['avatar'] as String?,
      description: json['description'] as String?,
      categorie: json['categorie'] == null
          ? null
          : Categorie.fromJson(
              Map<String, dynamic>.from(json['categorie'] as Map)),
      adresse: json['adresse'] == null
          ? null
          : Adresse.fromJson(Map<String, dynamic>.from(json['adresse'] as Map)),
      enLigne: json['enLigne'] as bool?,
    );

Map<String, dynamic> _$RestaurantToJson(Restaurant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'avatar': instance.avatar,
      'categorie': instance.categorie?.toJson(),
      'description': instance.description,
      'adresse': instance.adresse?.toJson(),
      'enLigne': instance.enLigne,
    };

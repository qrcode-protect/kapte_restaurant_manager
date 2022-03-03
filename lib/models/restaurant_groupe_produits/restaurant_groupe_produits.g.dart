// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant_groupe_produits.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RestaurantGroupeProduits _$RestaurantGroupeProduitsFromJson(Map json) =>
    RestaurantGroupeProduits(
      rank: json['rank'] as int?,
      id: json['id'] as String?,
      nom: json['nom'] as String?,
      description: json['description'] as String?,
      requis: json['requis'] as bool?,
    );

Map<String, dynamic> _$RestaurantGroupeProduitsToJson(
        RestaurantGroupeProduits instance) =>
    <String, dynamic>{
      'rank': instance.rank,
      'id': instance.id,
      'nom': instance.nom,
      'description': instance.description,
      'requis': instance.requis,
    };

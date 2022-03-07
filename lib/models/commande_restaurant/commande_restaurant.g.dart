// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commande_restaurant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommandeRestaurant _$CommandeRestaurantFromJson(Map json) => CommandeRestaurant(
      id: json['id'] as String,
      restaurant: Restaurant.fromJson(
          Map<String, dynamic>.from(json['restaurant'] as Map)),
      client: Utilisateur.fromJson(
          Map<String, dynamic>.from(json['client'] as Map)),
      date: DateTime.parse(json['date'] as String),
      status: CommandeStatusRestaurant.fromJson(
          Map<String, dynamic>.from(json['status'] as Map)),
      restaurantCommande: (json['restaurantCommande'] as List<dynamic>)
          .map((e) => CommandeRestaurantPanier.fromJson(
              Map<String, dynamic>.from(e as Map)))
          .toList(),
      prixLivraison: (json['prixLivraison'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CommandeRestaurantToJson(CommandeRestaurant instance) =>
    <String, dynamic>{
      'id': instance.id,
      'restaurant': instance.restaurant.toJson(),
      'client': instance.client.toJson(),
      'date': instance.date.toIso8601String(),
      'status': instance.status.toJson(),
      'restaurantCommande':
          instance.restaurantCommande.map((e) => e.toJson()).toList(),
      'prixLivraison': instance.prixLivraison,
    };

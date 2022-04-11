// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Client _$ClientFromJson(Map json) => Client(
      id: json['id'] as String,
      nom: json['nom'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      token: json['token'] as String,
      avatar: json['avatar'] as String,
      idRestaurant: json['idRestaurant'] as String?,
      creationDate: json['creationDate'] == null
          ? null
          : DateTime.parse(json['creationDate'] as String),
    );

Map<String, dynamic> _$ClientToJson(Client instance) => <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'email': instance.email,
      'phone': instance.phone,
      'token': instance.token,
      'avatar': instance.avatar,
      'idRestaurant': instance.idRestaurant,
      'creationDate': instance.creationDate?.toIso8601String(),
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paiements.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Paiements _$PaiementsFromJson(Map json) => Paiements(
      carte: json['carte'] as bool,
      espece: json['espece'] as bool,
    );

Map<String, dynamic> _$PaiementsToJson(Paiements instance) => <String, dynamic>{
      'carte': instance.carte,
      'espece': instance.espece,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adresse.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Adresse _$AdresseFromJson(Map json) => Adresse(
      json['id'] as String,
      json['rue'] as String,
      json['ville'] as String,
      json['codepostal'] as int,
      json['pays'] as String,
    );

Map<String, dynamic> _$AdresseToJson(Adresse instance) => <String, dynamic>{
      'id': instance.id,
      'rue': instance.rue,
      'ville': instance.ville,
      'codepostal': instance.codepostal,
      'pays': instance.pays,
    };

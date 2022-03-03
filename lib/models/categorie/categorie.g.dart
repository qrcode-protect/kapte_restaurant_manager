// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categorie.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Categorie _$CategorieFromJson(Map json) => Categorie(
      rank: json['rank'] as int?,
      id: json['id'] as String?,
      nom: json['nom'] as String?,
      avatar: json['avatar'] as String?,
    );

Map<String, dynamic> _$CategorieToJson(Categorie instance) => <String, dynamic>{
      'rank': instance.rank,
      'id': instance.id,
      'nom': instance.nom,
      'avatar': instance.avatar,
    };

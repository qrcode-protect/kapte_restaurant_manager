import 'package:json_annotation/json_annotation.dart';

part 'categorie.g.dart';

@JsonSerializable()
class Categorie {
  Categorie({
    this.rank,
    this.id,
    this.nom,
    this.avatar,
  });
  int? rank;
  String? id;
  String? nom;
  String? avatar;

  factory Categorie.fromJson(Map<String, dynamic> json) =>
      _$CategorieFromJson(json);

  Map<String, dynamic> toJson() => _$CategorieToJson(this);
}

import 'package:json_annotation/json_annotation.dart';

part 'adresse.g.dart';

@JsonSerializable()
class Adresse {
  Adresse(
    this.id,
    this.rue,
    this.ville,
    this.codepostal,
    this.pays,
  );

  final String id;
  final String rue;
  final String ville;
  final int codepostal;
  final String pays;

  factory Adresse.fromJson(Map<String, dynamic> json) =>
      _$AdresseFromJson(json);

  Map<String, dynamic> toJson() => _$AdresseToJson(this);
}

import 'package:json_annotation/json_annotation.dart';

part 'paiements.g.dart';

@JsonSerializable()
class Paiements {
  Paiements({
    required this.carte,
    required this.espece,
  });
  final bool carte;
  final bool espece;

  factory Paiements.fromJson(Map<String, dynamic> json) =>
      _$PaiementsFromJson(json);

  Map<String, dynamic> toJson() => _$PaiementsToJson(this);
}

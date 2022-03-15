import 'package:json_annotation/json_annotation.dart';

part 'utilisateur.g.dart';

@JsonSerializable()
class Utilisateur {
  Utilisateur({
    required this.id,
    required this.nom,
    required this.email,
    this.phone,
    required this.token,
    required this.avatar,
    this.idRestaurant,
    required this.validated,
    required this.suspended,
    this.creationDate,
  });
  final String id;
  final String nom;
  final String email;
  final String? phone;
  final String token;
  final String avatar;
  String? idRestaurant;
  bool validated;
  bool suspended;
  DateTime? creationDate;

  factory Utilisateur.fromJson(Map<String, dynamic> json) =>
      _$UtilisateurFromJson(json);

  Map<String, dynamic> toJson() => _$UtilisateurToJson(this);

  @override
  String toString() {
    return '{id: $id, nom: $nom, email: $email,phone: $phone, token: $token, avatar: $avatar,idRestaurant: $idRestaurant, }';
  }
}

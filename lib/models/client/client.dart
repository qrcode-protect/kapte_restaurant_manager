import 'package:json_annotation/json_annotation.dart';

part 'client.g.dart';

@JsonSerializable()
class Client {
  Client({
    required this.id,
    required this.nom,
    required this.email,
    this.phone,
    required this.token,
    required this.avatar,
    this.idRestaurant,
    this.creationDate,
  });
  final String id;
  final String nom;
  final String email;
  final String? phone;
  final String token;
  final String avatar;
  String? idRestaurant;
  DateTime? creationDate;

  factory Client.fromJson(Map<String, dynamic> json) => _$ClientFromJson(json);

  Map<String, dynamic> toJson() => _$ClientToJson(this);

  @override
  String toString() {
    return '{id: $id, nom: $nom, email: $email,phone: $phone, token: $token, avatar: $avatar,idRestaurant: $idRestaurant, }';
  }
}

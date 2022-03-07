import 'package:json_annotation/json_annotation.dart';

part 'commande_status_restaurant.g.dart';

@JsonSerializable()
class CommandeStatusRestaurant {
  CommandeStatusRestaurant({
    this.demande = true,
    this.encours = false,
    this.termine = false,
    this.annule = false,
  });
  bool? demande;
  bool? encours;
  bool? termine;
  bool? annule;
  factory CommandeStatusRestaurant.fromJson(Map<String, dynamic> json) =>
      _$CommandeStatusRestaurantFromJson(json);

  Map<String, dynamic> toJson() => _$CommandeStatusRestaurantToJson(this);
}

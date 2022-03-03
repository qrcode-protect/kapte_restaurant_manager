import 'package:firebase_storage/firebase_storage.dart';

class RestaurantMedia {
  RestaurantMedia(
    this.index,
    this.type,
    this.reference,
  );
  final int index;
  final String type;
  final Reference reference;

  @override
  String toString() {
    return '{index: $index, type: $type, reference: $reference}';
  }
}

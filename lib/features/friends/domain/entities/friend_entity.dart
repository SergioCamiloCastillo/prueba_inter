import 'package:prueba_inter/features/locations/domain/entities/location_entity.dart';

class FriendEntity {
  final int? idFriend;
  final String firstName;
  final String lastName;
  final String email;
  final String telephone;
  final String photo;

  FriendEntity({
    this.idFriend,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.telephone,
    required this.photo
  });
}

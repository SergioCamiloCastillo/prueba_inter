import 'package:prueba_inter/features/friends/domain/entities/friend_entity.dart';
import 'package:prueba_inter/features/locations/domain/entities/location_entity.dart';

abstract class FriendsDatasource {
  Future<bool> addFriend(FriendEntity friend);
  Future<List<FriendEntity>> getFriends();
  Future<bool> deleteFriend(int idFriend);
  Future<void> assignLocationToFriend(int friendId, int location);
}

import 'package:prueba_inter/features/friends/domain/entities/friend_entity.dart';

abstract class FriendsRepository {
  Future<bool> addFriend(FriendEntity friend);
  Future<List<FriendEntity>> getFriends();
  Future<bool> deleteFriend(int idFriend);
  Future<void> assignLocationToFriend(int friendId, int location);
  Future<bool> updateFriend(FriendEntity friend);
}

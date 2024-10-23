import 'package:prueba_inter/features/friends/domain/datasources/friends_datasource.dart';
import 'package:prueba_inter/features/friends/domain/entities/friend_entity.dart';
import 'package:prueba_inter/features/friends/domain/repositories/friends_repository.dart';
import 'package:prueba_inter/features/locations/domain/entities/location_entity.dart';

class FriendsRepositoryImpl extends FriendsRepository {
  final FriendsDatasource datasource;

  FriendsRepositoryImpl({required this.datasource});
  @override
  Future<bool> addFriend(FriendEntity friend) {
    return datasource.addFriend(friend);
  }

  @override
  Future<bool> deleteFriend(int idFriend) {
    return datasource.deleteFriend(idFriend);
  }

  @override
  Future<List<FriendEntity>> getFriends() {
    return datasource.getFriends();
  }

  @override
  Future<void> assignLocationToFriend(int friendId, int location) {
    return datasource.assignLocationToFriend(friendId, location);
  }
}

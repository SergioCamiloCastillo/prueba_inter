import 'package:prueba_inter/config/helpers/database_helper.dart';
import 'package:prueba_inter/features/friends/domain/datasources/friends_datasource.dart';
import 'package:prueba_inter/features/friends/domain/entities/friend_entity.dart';
import 'package:prueba_inter/features/locations/domain/entities/location_entity.dart';

class FriendsDatasourceLocaldatabaseImpl extends FriendsDatasource {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  @override
  Future<bool> addFriend(FriendEntity friend) async {
    try {
      final db = await _databaseHelper.database;
      await db.insert('friends', {
        'firstName': friend.firstName,
        'lastName': friend.lastName,
        'email': friend.email,
        'phoneNumber': friend.telephone,
        'photoUrl': friend.photo,
        'assignedLocations': friend.assignedLocations.join(','),
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteFriend(int idFriend) {
    // TODO: implement deleteFriend
    throw UnimplementedError();
  }

  @override
  Future<List<FriendEntity>> getFriends() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('friends');
    return List.generate(maps.length, (i) {
      return FriendEntity(
        idFriend: maps[i]['id'],
        firstName: maps[i]['firstName'],
        lastName: maps[i]['lastName'],
        email: maps[i]['email'],
        telephone: maps[i]['phoneNumber'],
        photo: maps[i]['photoUrl'],
        assignedLocations: maps[i]['assignedLocations']?.split(',') ?? [],
      );
    });
  }

  @override
  Future<void> assignLocationToFriend(
      int friendId, int location) {
    // TODO: implement assignLocationToFriend
    throw UnimplementedError();
  }
}

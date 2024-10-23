import 'package:prueba_inter/config/helpers/database_helper.dart';
import 'package:prueba_inter/features/friends/domain/datasources/friends_datasource.dart';
import 'package:prueba_inter/features/friends/domain/entities/friend_entity.dart';
import 'package:prueba_inter/features/locations/domain/entities/location_entity.dart';
import 'package:sqflite/sqflite.dart';

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
        'photoUrl': friend.photo
      });
      print('Amigo agregado correctamente');
      return true;
    } catch (e) {
      print('Hubo un error al agregar el amigo: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteFriend(int idFriend) async {
    try {
      final db = await _databaseHelper.database;
      int result = await db.delete(
        'friends',
        where: 'id = ?',
        whereArgs: [idFriend],
      );
      if (result > 0) {
        print('Amigo eliminado correctamente');
        return true; // Operación exitosa
      } else {
        print('No se encontró el amigo con el ID: $idFriend');
        return false; // No se encontró el amigo
      }
    } catch (e) {
      print('Hubo un error al eliminar el amigo: $e');
      return false; // Indica que hubo un error
    }
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
      );
    });
  }

  @override
  Future<void> assignLocationToFriend(int friendId, int locationId) async {
    final db = await _databaseHelper.database;
    await db.insert(
      'friend_locations',
      {
        'friendId': friendId,
        'locationId': locationId,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<bool> updateFriend(FriendEntity friend) async {
    try {
      final db = await _databaseHelper.database;
      int result = await db.update(
        'friends',
        {
          'firstName': friend.firstName,
          'lastName': friend.lastName,
          'email': friend.email,
          'phoneNumber': friend.telephone,
          'photoUrl': friend.photo,
        },
        where: 'id = ?',
        whereArgs: [
          friend.idFriend
        ], // Usar el ID del amigo para la actualización
      );

      if (result > 0) {
        print('Amigo actualizado correctamente');
        return true; // Indica que la operación fue exitosa
      } else {
        print('No se encontró el amigo con el ID: ${friend.idFriend}');
        return false; // Indica que no se encontró el amigo
      }
    } catch (e) {
      print('Hubo un error al actualizar el amigo: $e');
      return false; // Indica que hubo un error
    }
  }
}

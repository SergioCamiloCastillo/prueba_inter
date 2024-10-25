import 'package:prueba_inter/config/helpers/database_helper.dart';
import 'package:prueba_inter/features/friends/domain/datasources/friends_datasource.dart';
import 'package:prueba_inter/features/friends/domain/entities/friend_entity.dart';
import 'package:prueba_inter/features/locations/domain/entities/location_entity.dart';
import 'package:sqflite/sqflite.dart';

class FriendsDatasourceLocaldatabaseImpl extends FriendsDatasource {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Future<Map<String, dynamic>> addFriend(FriendEntity friend) async {
    try {
      final db = await _databaseHelper.database;
      final response = await db.insert('friends', {
        'firstName': friend.firstName,
        'lastName': friend.lastName,
        'email': friend.email,
        'phoneNumber': friend.telephone,
        'photoUrl': friend.photo
      });
      print('Amigo agregado correctamente $response');
      return {
        "success": true,
        "message": "Amigo agregado correctamente",
        "id": response
      };
    } catch (e) {
      print('Hubo un error al agregar el amigo: $e');
      return {"success": false, "message": "Hubo un error al agregar el amigo"};
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
        return true; 
      } else {
        print('No se encontró el amigo con el ID: $idFriend');
        return false;
      }
    } catch (e) {
      print('Hubo un error al eliminar el amigo: $e');
      return false; 
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
  Future<Map<String, dynamic>> assignLocationToFriend(
      int friendId, int locationId) async {
    try {
      final db = await _databaseHelper.database;

      final countResult = await db.rawQuery('''
      SELECT COUNT(*) as count FROM friend_locations
      WHERE friendId = ?
    ''', [friendId]);

      final int count = Sqflite.firstIntValue(countResult) ?? 0;

      if (count >= 5) {
        return {
          "success": false,
          "message": "Este amigo ya tiene el máximo de 5 ubicaciones."
        };
      }

      await db.insert('friend_locations', {
        'friendId': friendId,
        'locationId': locationId,
      });
      return {"success": true, "message": "Ubicación agregada correctamente."};
    } catch (e) {
      return {
        "success": true,
        "message": "Hubo un error al agregar la ubicación."
      };
    }
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
        whereArgs: [friend.idFriend],
      );

      if (result > 0) {
        print('Amigo actualizado correctamente');
        return true;
      } else {
        print('No se encontró el amigo con el ID: ${friend.idFriend}');
        return false;
      }
    } catch (e) {
      print('Hubo un error al actualizar el amigo: $e');
      return false;
    }
  }

  @override
  Future<List<LocationEntity>> getLocationsByFriend(int friendId) async {
    try {
      final db = await _databaseHelper.database;

      final List<Map<String, dynamic>> locationIds = await db.rawQuery('''
      SELECT locationId 
      FROM friend_locations 
      WHERE friendId = ?
    ''', [friendId]);

      if (locationIds.isEmpty) {
        return [];
      }

      List<int> ids = locationIds.map((e) => e['locationId'] as int).toList();

      List<LocationEntity> locations = [];
      for (int locationId in ids) {
        final List<Map<String, dynamic>> locationData = await db.query(
          'locations',
          where: 'id = ?',
          whereArgs: [locationId],
        );

        if (locationData.isNotEmpty) {
          LocationEntity location = LocationEntity(
            idLocation: locationData[0]['id'],
            name: locationData[0]['name'],
            description: locationData[0]['description'],
            latitude: locationData[0]['latitude'] ?? 0.0,
            location: locationData[0]['location'],
            longitude: locationData[0]['longitude'] ?? 0.0,
            photos: await getPhotosForLocation(locationId),
          );
          locations.add(location);
        }
      }

      return locations;
    } catch (e) {
      print('Error al obtener ubicaciones para el amigo: $e');
      return [];
    }
  }

  Future<List<String>> getPhotosForLocation(int locationId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> photosMaps = await db.query(
      'photos',
      where: 'locationId = ?',
      whereArgs: [locationId],
    );

    return List.generate(
        photosMaps.length, (i) => photosMaps[i]['url'] as String);
  }

  @override
  Future<bool> deleteLocationByFriend(int friendId, int locationId) async {
    try {
      final db = await _databaseHelper.database;
      int result = await db.delete(
        'friend_locations',
        where: 'friendId = ? AND locationId = ?',
        whereArgs: [friendId, locationId],
      );

      if (result > 0) {
        print(
            'Ubicación eliminada correctamente para el amigo con ID: $friendId');
        return true;
      } else {
        print('No se encontró la ubicación para el amigo con ID: $friendId');
        return false;
      }
    } catch (e) {
      print('Hubo un error al eliminar la ubicación: $e');
      return false;
    }
  }

  @override
  Future<List<LocationEntity>> getLocationsOcupped(int friendId) async {
    try {
      final db = await _databaseHelper.database;
      String query;
      List<dynamic> args;

      if (friendId == 0) {
        query = '''
      SELECT l.*
      FROM locations l
      JOIN friend_locations fl ON l.id = fl.locationId;
      ''';
        args = [];
      } else {
        query = '''
      SELECT l.* 
      FROM locations l
      JOIN friend_locations fl ON l.id = fl.locationId
      WHERE fl.friendId != ?;
      ''';
        args = [friendId];
      }

      final List<Map<String, dynamic>> maps = await db.rawQuery(query, args);

      List<LocationEntity> locations = [];
      print('lsss Ubicaciones ocupadas: $maps');
      for (var map in maps) {
        LocationEntity location = LocationEntity(
          idLocation: map['id'],
          name: map['name'],
          location: map['location'],
          description: map['description'],
          latitude: map['latitude'] ?? 0.0,
          longitude: map['longitude'] ?? 0.0,
          photos: await getPhotosForLocation(map['id']),
        );
        locations.add(location);
      }

      return locations;
    } catch (e) {
      print('Error al obtener ubicaciones ocupadas: $e');
      return [];
    }
  }

  @override
  Future<void> deleteFriendLocation(int friendId) async {
    final db = await _databaseHelper.database;

    await db.delete(
      'friend_locations',
      where: 'friendId = ?',
      whereArgs: [friendId],
    );
  }
}

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
  Future<Map<String, dynamic>> assignLocationToFriend(
      int friendId, int locationId) async {
    try {
      final db = await _databaseHelper.database;

      // Ver cuántas ubicaciones tiene asignadas el amigo
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

      // Si tiene menos de 5, agregar la nueva ubicación
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

  @override
  Future<List<LocationEntity>> getLocationsByFriend(int friendId) async {
    try {
      final db = await _databaseHelper.database;

      // 1. Obtener los IDs de las ubicaciones asociadas al amigo
      final List<Map<String, dynamic>> locationIds = await db.rawQuery('''
      SELECT locationId 
      FROM friend_locations 
      WHERE friendId = ?
    ''', [friendId]);

      // 2. Verificar si hay ubicaciones asignadas
      if (locationIds.isEmpty) {
        return []; // Si no hay ubicaciones, devolver una lista vacía
      }

      // 3. Crear una lista de IDs de ubicaciones
      List<int> ids = locationIds.map((e) => e['locationId'] as int).toList();

      // 4. Obtener los detalles de las ubicaciones
      List<LocationEntity> locations = [];
      for (int locationId in ids) {
        final List<Map<String, dynamic>> locationData = await db.query(
          'locations',
          where: 'id = ?',
          whereArgs: [locationId],
        );

        // 5. Si se encuentra la ubicación, crear el objeto LocationEntity
        if (locationData.isNotEmpty) {
          LocationEntity location = LocationEntity(
            idLocation: locationData[0]['id'],
            name: locationData[0]['name'],
            description: locationData[0]['description'],
            latitude: locationData[0]['latitude'] ?? 0.0,
            longitude: locationData[0]['longitude'] ?? 0.0,
            // 6. Obtener fotos asociadas a la ubicación
            photos: await getPhotosForLocation(locationId),
          );
          locations.add(location);
        }
      }

      return locations; // Devolver la lista de ubicaciones con fotos
    } catch (e) {
      print('Error al obtener ubicaciones para el amigo: $e');
      return []; // Devolver una lista vacía en caso de error
    }
  }

// Método para obtener fotos asociadas a una ubicación
  Future<List<String>> getPhotosForLocation(int locationId) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> photosMaps = await db.query(
      'photos',
      where: 'locationId = ?',
      whereArgs: [locationId],
    );

    // Retornar solo las URLs de las fotos
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
        return true; // Operación exitosa
      } else {
        print('No se encontró la ubicación para el amigo con ID: $friendId');
        return false; // No se encontró la ubicación
      }
    } catch (e) {
      print('Hubo un error al eliminar la ubicación: $e');
      return false; // Indica que hubo un error
    }
  }

  @override
  Future<List<LocationEntity>> getLocationsOcupped(int friendId) async {
    try {
      final db = await _databaseHelper.database;

      // Consulta para obtener las ubicaciones ocupadas por otros amigos
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT l.* 
      FROM locations l
      JOIN friend_locations fl ON l.id = fl.locationId
      WHERE fl.friendId != ?;
    ''', [friendId]);

      // Crear una lista vacía para almacenar las ubicaciones
      List<LocationEntity> locations = [];

      // Usar un bucle for para procesar cada ubicación y esperar a que se resuelva getPhotosForLocation
      for (var map in maps) {
        LocationEntity location = LocationEntity(
          idLocation: map['id'],
          name: map['name'],
          description: map['description'],
          latitude: map['latitude'] ?? 0.0,
          longitude: map['longitude'] ?? 0.0,
          photos: await getPhotosForLocation(
              map['id']), // Esperar el resultado de las fotos
        );
        locations.add(location); // Agregar la ubicación a la lista
      }

      return locations; // Devolver la lista de ubicaciones
    } catch (e) {
      print('Error al obtener ubicaciones ocupadas: $e');
      return []; // Devolver una lista vacía en caso de error
    }
  }
}

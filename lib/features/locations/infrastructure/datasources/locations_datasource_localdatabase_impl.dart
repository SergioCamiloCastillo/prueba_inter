import 'package:prueba_inter/config/helpers/database_helper.dart';
import 'package:prueba_inter/config/helpers/distance_helper.dart';
import 'package:prueba_inter/features/locations/domain/datasources/locations_datasource.dart';
import 'package:prueba_inter/features/locations/domain/entities/location_entity.dart';

class LocationsDatasourceLocaldatabaseImpl extends LocationsDatasource {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  Future<Map<String, dynamic>> addLocation(LocationEntity location) async {
    try {
      final db = await _databaseHelper.database;

      // 1. Obtener todas las ubicaciones existentes
      final List<Map<String, dynamic>> existingLocations =
          await db.query('locations');

      // 2. Revisar la distancia de la nueva ubicación con las existentes
      for (var existingLocation in existingLocations) {
        double existingLat = existingLocation['latitude'];
        double existingLon = existingLocation['longitude'];

        double distance = calculateDistance(
          4.6964175,
          -74.1228677,
          existingLat,
          existingLon,
        );
        print('Distancia: $distance');
        // 3. Verificar si la distancia es menor a 500 metros
        if (distance < 500) {
          print(
              'La nueva ubicación está demasiado cerca de una ubicación existente.');
          return {
            "success": false,
            "message":
                "La ubicación está dentro de un radio de 500 metros de otra ubicación."
          };
        }
      }

      final locationId = await db.insert('locations', {
        'name': location.name,
        'description': location.description,
        'latitude': 4.6965929,
        'longitude': -74.1223724,
      });

      final photosMap = location.photos;
      for (var photo in photosMap) {
        await db.insert('photos', {
          'locationId': locationId,
          'url': photo,
        });
      }

      print('Ubicación agregada correctamente');
      return {"success": true, "message": "Ubicación agregada correctamente"};
    } catch (e) {
      print('Hubo un error al agregar la ubicación: $e');
      return {
        "success": false,
        "message": "Hubo un error al agregar la ubicación"
      };
    }
  }

  @override
  Future<bool> deleteLocation(int idLocation) async {
    try {
      final db = await _databaseHelper.database;
      int result = await db.delete(
        'locations',
        where: 'id = ?',
        whereArgs: [idLocation],
      );
      if (result > 0) {
        print('Ubicación eliminada correctamente');
        return true; // Operación exitosa
      } else {
        print('No se encontró la ubicación con el ID: $idLocation');
        return false; // No se encontró la ubicación
      }
    } catch (e) {
      print('Hubo un error al eliminar la ubicación: $e');
      return false; // Indica que hubo un error
    }
  }

  @override
  Future<List<LocationEntity>> getLocations() async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('locations');

    return List.generate(maps.length, (i) {
      return LocationEntity(
        idLocation: maps[i]['id'],
        name: maps[i]['name'],
        description: maps[i]['description'],
        latitude: maps[i]['latitude'] ?? 0.0,
        longitude: maps[i]['longitude'] ?? 0.0,
        photos: maps[i]['photos'] ?? [],
      );
    });
  }

  @override
  Future<void> updateLocation(LocationEntity location) async {
    final db = await _databaseHelper.database;

    await db.update(
      'locations',
      {
        'name': location.name,
        'description': location.description,
        // Agrega otros campos según sea necesario
      },
      where: 'id = ?',
      whereArgs: [location.idLocation],
    );
    print('Ubicación actualizada correctamente');
  }

  @override
  Future<LocationEntity?> getLocationById(int idLocation) async {
    final db = await _databaseHelper.database;

    // Consulta para obtener la ubicación por ID
    final List<Map<String, dynamic>> maps = await db.query(
      'locations',
      where: 'id = ?',
      whereArgs: [idLocation],
    );

    // Verificar si se encontró la ubicación
    if (maps.isNotEmpty) {
      // Si existe, crear y devolver la entidad de ubicación
      return LocationEntity(
        idLocation: maps[0]['id'],
        name: maps[0]['name'],
        description: maps[0]['description'],
        latitude: maps[0]['latitude'] ?? 0.0,
        longitude: maps[0]['longitude'] ?? 0.0,
        // Para obtener las fotos, podrías hacer otra consulta aquí
        photos:
            await getPhotosForLocation(idLocation), // Método para obtener fotos
      );
    }
    // Retornar null si no se encontró la ubicación
    return null;
  }

  @override
  Future<List<String>> getPhotosForLocation(int idLocation) async {
    final db = await _databaseHelper.database;
    final List<Map<String, dynamic>> photosMaps = await db.query(
      'photos',
      where: 'locationId = ?',
      whereArgs: [idLocation],
    );

    // Retornar solo las URLs de las fotos
    return List.generate(
        photosMaps.length, (i) => photosMaps[i]['url'] as String);
  }
}

import 'package:prueba_inter/features/locations/domain/entities/location_entity.dart';

abstract class LocationsDatasource {
  Future<Map<String, dynamic>> addLocation(LocationEntity location);
  Future<List<LocationEntity>> getLocations();
  Future<bool> deleteLocation(int idLocation);
  Future<void> updateLocation(LocationEntity location);
  Future<LocationEntity?> getLocationById(int idLocation);
  Future<List<String>> getPhotosForLocation(int idLocation);
}

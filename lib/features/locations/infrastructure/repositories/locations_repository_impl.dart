import 'package:prueba_inter/features/locations/domain/datasources/locations_datasource.dart';
import 'package:prueba_inter/features/locations/domain/entities/location_entity.dart';
import 'package:prueba_inter/features/locations/domain/repositories/locations_repository.dart';

class LocationsRepositoryImpl extends LocationsRepository {
  final LocationsDatasource datasource;

  LocationsRepositoryImpl({required this.datasource});

  @override
  Future<Map<String, dynamic>> addLocation(LocationEntity location) {
    return datasource.addLocation(location);
  }

  @override
  Future<bool> deleteLocation(int idLocation) async {
    await datasource.deleteLocationFriend(idLocation);
    return datasource.deleteLocation(idLocation);
  }

  @override
  Future<List<LocationEntity>> getLocations() {
    return datasource.getLocations();
  }

  @override
  Future<void> updateLocation(LocationEntity location) {
    return datasource.updateLocation(location);
  }

  @override
  Future<LocationEntity?> getLocationById(int idLocation) {
    return datasource.getLocationById(idLocation);
  }

  @override
  Future<List<String>> getPhotosForLocation(int idLocation) {
    return datasource.getPhotosForLocation(idLocation);
  }
}

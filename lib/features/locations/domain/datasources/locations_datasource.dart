import 'package:prueba_inter/features/locations/domain/entities/location_entity.dart';

abstract class LocationsDatasource {
  Future<bool> addLocation(LocationEntity location);
  Future<List<LocationEntity>> getLocations();
  Future<bool> deleteLocation(int idLocation);
}

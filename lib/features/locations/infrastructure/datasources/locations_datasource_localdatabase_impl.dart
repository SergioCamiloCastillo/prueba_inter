import 'package:prueba_inter/features/friends/domain/datasources/friends_datasource.dart';
import 'package:prueba_inter/features/friends/domain/entities/friend_entity.dart';
import 'package:prueba_inter/features/locations/domain/datasources/locations_datasource.dart';
import 'package:prueba_inter/features/locations/domain/entities/location_entity.dart';

class LocationsDatasourceLocaldatabaseImpl extends LocationsDatasource {
  @override
  Future<bool> addLocation(LocationEntity location) {
    // TODO: implement addLocation
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteLocation(int idLocation) {
    // TODO: implement deleteLocation
    throw UnimplementedError();
  }

  @override
  Future<List<LocationEntity>> getLocations() {
    // TODO: implement getLocations
    throw UnimplementedError();
  }
}

import 'package:mobx/mobx.dart';
import 'package:prueba_inter/features/locations/domain/entities/location_entity.dart';
import 'package:prueba_inter/features/locations/domain/repositories/locations_repository.dart';

part 'locations_store.g.dart';

class LocationsStore = _LocationsStore with _$LocationsStore;

abstract class _LocationsStore with Store {
  final LocationsRepository locationsRepository;

  _LocationsStore(this.locationsRepository);

  @observable
  ObservableList<LocationEntity> locations = ObservableList<LocationEntity>();

  @action
  Future<List<LocationEntity>> fetchLocations() async {
    locations.clear();
    final List<LocationEntity> fetchedLocations =
        await locationsRepository.getLocations();
    locations.addAll(fetchedLocations);
    return fetchedLocations; 
  }
  
  @action
  Future<Map<String, dynamic>> addLocation(LocationEntity location) async {
    try {
      print('la latitud al guardar=>${location.latitude}');
      print('la longitud al guardar=>${location.longitude}');
      final response = await locationsRepository.addLocation(location);
      await fetchLocations();
      return response;
    } catch (e) {
      print("Error al agregar ubicación: $e");
      return {"success": false, "message": "Error al agregar ubicación."};
    }
  }

  @action
  Future<bool> deleteLocation(int idLocation) async {
    try {
      bool success = await locationsRepository.deleteLocation(idLocation);
      if (success) {
        await fetchLocations();
      }
      return success;
    } catch (e) {
      print("Error al eliminar ubicación: $e");
      return false;
    }
  }

  @action
  Future<void> updateLocation(LocationEntity location) async {
    try {
      await locationsRepository.updateLocation(location);
      await fetchLocations(); 
    } catch (e) {
      print("Error al actualizar ubicación: $e");
    }
  }

  @action
  Future<LocationEntity?> getLocationById(int idLocation) async {
    await fetchLocations(); 
    print("Buscando ubicación con id $idLocation");
    try {
      return locations
          .firstWhere((location) => location.idLocation == idLocation);
    } catch (e) {
      print("Ubicación con id $idLocation no encontrada.");
      return null;
    }
  }
}

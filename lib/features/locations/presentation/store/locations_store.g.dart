// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'locations_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$LocationsStore on _LocationsStore, Store {
  late final _$locationsAtom =
      Atom(name: '_LocationsStore.locations', context: context);

  @override
  ObservableList<LocationEntity> get locations {
    _$locationsAtom.reportRead();
    return super.locations;
  }

  @override
  set locations(ObservableList<LocationEntity> value) {
    _$locationsAtom.reportWrite(value, super.locations, () {
      super.locations = value;
    });
  }

  late final _$fetchLocationsAsyncAction =
      AsyncAction('_LocationsStore.fetchLocations', context: context);

  @override
  Future<List<LocationEntity>> fetchLocations() {
    return _$fetchLocationsAsyncAction.run(() => super.fetchLocations());
  }

  late final _$addLocationAsyncAction =
      AsyncAction('_LocationsStore.addLocation', context: context);

  @override
  Future<Map<String, dynamic>> addLocation(LocationEntity location) {
    return _$addLocationAsyncAction.run(() => super.addLocation(location));
  }

  late final _$deleteLocationAsyncAction =
      AsyncAction('_LocationsStore.deleteLocation', context: context);

  @override
  Future<bool> deleteLocation(int idLocation) {
    return _$deleteLocationAsyncAction
        .run(() => super.deleteLocation(idLocation));
  }

  late final _$updateLocationAsyncAction =
      AsyncAction('_LocationsStore.updateLocation', context: context);

  @override
  Future<void> updateLocation(LocationEntity location) {
    return _$updateLocationAsyncAction
        .run(() => super.updateLocation(location));
  }

  late final _$getLocationByIdAsyncAction =
      AsyncAction('_LocationsStore.getLocationById', context: context);

  @override
  Future<LocationEntity?> getLocationById(int idLocation) {
    return _$getLocationByIdAsyncAction
        .run(() => super.getLocationById(idLocation));
  }

  @override
  String toString() {
    return '''
locations: ${locations}
    ''';
  }
}

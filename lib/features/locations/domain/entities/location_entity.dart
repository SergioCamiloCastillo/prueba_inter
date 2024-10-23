class LocationEntity {
  final String idLocation;
  final String name;
  final double latitude;
  final double longitude;
  final List<String> photos;
  final String descripcion;

  LocationEntity({
    required this.idLocation,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.photos,
    required this.descripcion,
  });
}

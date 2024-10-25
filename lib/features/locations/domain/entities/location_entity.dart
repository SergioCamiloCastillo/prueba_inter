class LocationEntity {
  final int? idLocation;
  final String name;
  final double latitude;
  final double longitude;
  final List<String> photos;
  final String location;
  final String? description;

  LocationEntity({
    this.idLocation,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.photos,
    required this.location,
    this.description,
  });
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:prueba_inter/features/locations/domain/entities/location_entity.dart';
import 'package:prueba_inter/features/locations/infrastructure/datasources/locations_datasource_localdatabase_impl.dart';
import 'package:prueba_inter/features/locations/infrastructure/repositories/locations_repository_impl.dart';

class LocationDetailScreen extends StatefulWidget {
  static const name = "location-detail-screen";
  final int idLocation;

  const LocationDetailScreen({required this.idLocation, super.key});

  @override
  _LocationDetailScreenState createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends State<LocationDetailScreen> {
  LocationEntity? location;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLocationDetails();
  }

  Future<void> _fetchLocationDetails() async {
    // Aquí deberías tener una instancia de tu repository
    final repository = LocationsRepositoryImpl(
        datasource: LocationsDatasourceLocaldatabaseImpl());
    location = await repository.getLocationById(
        widget.idLocation); // Método para obtener la ubicación por ID

    setState(() {
      isLoading =
          false; // Cambiar el estado una vez que se haya cargado la ubicación
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator()); // Mostrar un indicador de carga
    }

    if (location == null) {
      return const Center(
          child: Text(
              "Ubicación no encontrada.")); // Manejar el caso de ubicación no encontrada
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(location!.name), // Título con el nombre de la ubicación
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location!.description ?? "",
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Latitud: ${location!.latitude}',
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              'Longitud: ${location!.longitude}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Fotos:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (location!.photos.isNotEmpty) ...[
              // Muestra las imágenes si hay alguna
              Expanded(
                child: ListView.builder(
                  itemCount: location!.photos.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Image.file(
                        File(location!.photos[
                            index]), // Cargar la imagen desde el archivo
                        fit: BoxFit.cover,
                        height: 200, // Ajusta el tamaño de la imagen
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              const Text("No hay fotos disponibles.")
            ],
          ],
        ),
      ),
    );
  }
}

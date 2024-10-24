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
    final repository = LocationsRepositoryImpl(
        datasource: LocationsDatasourceLocaldatabaseImpl());
    location = await repository.getLocationById(widget.idLocation);

    setState(() {
      isLoading =
          false; // Cambiar el estado una vez que se haya cargado la ubicación
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
            child:
                CircularProgressIndicator()), // Mostrar un indicador de carga
      );
    }

    if (location == null) {
      return const Scaffold(
        body: Center(
          child:
              Text("Ubicación no encontrada.", style: TextStyle(fontSize: 18)),
        ), // Manejar el caso de ubicación no encontrada
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(location!.name),
        backgroundColor: const Color(0xFF64D0DE), // Color más bonito
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Descripción de la ubicación
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Descripción: ',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            location!.description ??
                                "Descripción no disponible",
                            style: const TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.pin_drop, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text(
                            'Latitud: ${location!.latitude}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.pin_drop, color: Colors.teal),
                          const SizedBox(width: 8),
                          Text(
                            'Longitud: ${location!.longitude}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Fotos:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (location!.photos.isNotEmpty) ...[
                // Muestra las imágenes si hay alguna
                GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: location!.photos.length,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 7,
                              offset: const Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Image.file(
                          File(location!.photos[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ] else ...[
                const Text("No hay fotos disponibles.",
                    style: TextStyle(fontSize: 16)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

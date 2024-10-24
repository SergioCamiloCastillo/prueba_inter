import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prueba_inter/features/locations/domain/entities/location_entity.dart';
import 'package:prueba_inter/features/locations/infrastructure/datasources/locations_datasource_localdatabase_impl.dart';
import 'package:prueba_inter/features/locations/infrastructure/repositories/locations_repository_impl.dart';
import 'package:prueba_inter/features/locations/presentation/store/locations_store.dart';

class LocationsScreen extends StatefulWidget {
  static const name = "locations-screen";

  const LocationsScreen({super.key});

  @override
  _LocationsScreenState createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  late LocationsStore _locationsStore;

  @override
  void initState() {
    super.initState();

    // Instanciar el datasource, repositorio y el store
    final datasource = LocationsDatasourceLocaldatabaseImpl();
    final repository = LocationsRepositoryImpl(datasource: datasource);
    _locationsStore = LocationsStore(repository);

    // Cargar ubicaciones cuando se inicializa el estado
    _locationsStore.fetchLocations();
  }

  void _showAddLocationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddLocationDialog(locationsStore: _locationsStore);
      },
    );
  }

  void _deleteLocation(int locationId) async {
    bool success = await _locationsStore.deleteLocation(locationId);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Ubicación eliminada exitosamente."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al eliminar ubicación."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ubicaciones")
      ),
      body: Observer(
        builder: (_) {
          if (_locationsStore.locations.isEmpty) {
            return const Center(child: Text("No hay ubicaciones."));
          }
          return ListView.builder(
            itemCount: _locationsStore.locations.length,
            itemBuilder: (context, index) {
              final location = _locationsStore.locations[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(location.name),
                  subtitle: Text(location.description ?? ""),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _deleteLocation(location.idLocation!);
                    },
                  ),
                  onTap: () {
                    GoRouter.of(context)
                        .push('/location/${location.idLocation}');
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddLocationDialog,
        tooltip: "Agregar Ubicación",
        child: const Icon(Icons.add_location),
      ),
    );
  }
}

class AddLocationDialog extends StatefulWidget {
  final LocationsStore locationsStore;

  const AddLocationDialog({required this.locationsStore, super.key});

  @override
  _AddLocationDialogState createState() => _AddLocationDialogState();
}

class _AddLocationDialogState extends State<AddLocationDialog> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  double? latitude;
  double? longitude;
  List<XFile>? images; // Lista para almacenar imágenes

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    images = [];
  }

  Future<void> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      await _getCurrentLocation();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Permiso de ubicación denegado."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
    } catch (e) {
      print("Error al obtener la ubicación: $e");
    }
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();

    // Verifica cuántas imágenes ya hay seleccionadas
    int remainingSlots = 3 - images!.length;

    if (remainingSlots > 0) {
      final List<XFile> selectedImages = await picker.pickMultiImage();

      // Si el usuario selecciona más imágenes de las que puede añadir, recorta la lista
      if (selectedImages.length > remainingSlots) {
        selectedImages.removeRange(remainingSlots, selectedImages.length);
      }

      setState(() {
        images!.addAll(selectedImages);
      });
    } else {
      // Mostrar mensaje indicando que no se pueden seleccionar más de 3 imágenes
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Solo puedes seleccionar hasta 3 imágenes."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Agregar Ubicación"),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Nombre"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Descripción"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImages,
                child: const Text("Seleccionar Imágenes (máx. 3)"),
              ),
              const SizedBox(height: 10),
              if (images != null && images!.isNotEmpty)
                Column(
                  children: images!.map((image) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Image.file(
                        File(image.path),
                        height: 100,
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            String name = nameController.text;
            String description = descriptionController.text;
            if (name.isNotEmpty &&
                latitude != null &&
                longitude != null) {
              // Agregar la ubicación
              final response = await widget.locationsStore.addLocation(
                LocationEntity(
                  name: name,
                  description: description,
                  latitude: latitude!,
                  longitude: longitude!,
                  photos: images?.map((img) => img.path).toList() ?? [],
                ),
              );

              Navigator.of(context).pop();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(response['message']),
                  backgroundColor:
                      response['success'] ? Colors.green : Colors.red,
                ),
              );

              // Limpiar los campos del formulario
              nameController.clear();
              descriptionController.clear();
              setState(() {
                images = [];
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Por favor, completa todos los campos."),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: const Text("Agregar"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Cerrar el diálogo
          },
          child: const Text("Cancelar"),
        ),
      ],
    );
  }
}

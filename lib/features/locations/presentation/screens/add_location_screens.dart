import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:prueba_inter/features/locations/domain/entities/location_entity.dart';
import 'package:prueba_inter/features/locations/infrastructure/datasources/locations_datasource_localdatabase_impl.dart';
import 'package:prueba_inter/features/locations/infrastructure/repositories/locations_repository_impl.dart';
import 'package:prueba_inter/features/locations/presentation/store/locations_store.dart';

class AddLocationScreen extends StatefulWidget {
  static const name = 'add-location-screens';

  const AddLocationScreen({super.key});

  @override
  _AddLocationScreenState createState() => _AddLocationScreenState();
}

class _AddLocationScreenState extends State<AddLocationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final ValueNotifier<LatLng?> _selectedLocationNotifier = ValueNotifier(null);
  List<XFile>? images = [];
  late LocationsStore _locationsStore;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final datasource = LocationsDatasourceLocaldatabaseImpl();
    final repository = LocationsRepositoryImpl(datasource: datasource);
    _locationsStore = LocationsStore(repository);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLocationChoiceDialog();
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true; 
    });

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("El servicio de ubicación está deshabilitado."),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Permiso de ubicación denegado."),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Los permisos de ubicación han sido denegados permanentemente."),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();

      LatLng currentLocation = LatLng(position.latitude, position.longitude);
      _selectedLocationNotifier.value = currentLocation;
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        addressController.text =
            "${placemarks.first.street}, ${placemarks.first.locality}, ${placemarks.first.country}";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al obtener la ubicación."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<bool> _convertAddressToCoordinates(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        LatLng newLatLng =
            LatLng(locations.first.latitude, locations.first.longitude);
        _selectedLocationNotifier.value = newLatLng;
        return true;
      } else {
        _showErrorMessage("No se encontraron ubicaciones para esta dirección.");
        return false;
      }
    } catch (e) {
      _showErrorMessage("Error al buscar la dirección.");
      return false;
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showAddressInputDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Ingresar Dirección"),
          content: TextField(
            controller: addressController,
            decoration: const InputDecoration(hintText: "Escribe la dirección"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (addressController.text.isNotEmpty) {
                  final responseConvert = await _convertAddressToCoordinates(
                      addressController.text);
                  print('responseConvert: $responseConvert');
                  if (responseConvert == true) {
                    print('Ubicación encontrada');
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text("Buscar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancelar"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLocationChoiceDialog() async {
    showModalBottomSheet(
      context: context,
      isDismissible: false, 
      enableDrag: false, 
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.gps_fixed),
                title: const Text("Usar ubicación actual del dispositivo"),
                onTap: () async {
                  await _getCurrentLocation();
                  Navigator.pop(context); 
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text("Ingresar dirección"),
                onTap: () {
                  Navigator.pop(context); 
                  _showAddressInputDialog(); 
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    int remainingSlots = 3 - (images?.length ?? 0);

    if (remainingSlots > 0) {
      final List<XFile> selectedImages = await picker.pickMultiImage();
      if (selectedImages.length > remainingSlots) {
        selectedImages.removeRange(remainingSlots, selectedImages.length);
      }
      setState(() {
        images!.addAll(selectedImages);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Solo puedes seleccionar hasta 3 imágenes."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _saveLocation() async {
    if (_selectedLocationNotifier.value != null &&
        nameController.text.isNotEmpty) {
      final locationEntity = LocationEntity(
        name: nameController.text,
        description: descriptionController.text,
        latitude: _selectedLocationNotifier.value!.latitude,
        longitude: _selectedLocationNotifier.value!.longitude,
        location: addressController.text,
        photos: images?.map((img) => img.path).toList() ?? [],
      );

      final response = await _locationsStore.addLocation(locationEntity);
      if (response['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor completa todos los campos obligatorios."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFFA3AEC2)),
          border: const OutlineInputBorder(),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFA3AEC2), width: 2.0),
          ),
        ),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      images!.removeAt(index);
    });
  }

  Widget _buildMapPreview(LatLng selectedLocation) {
    return SizedBox(
      height: 200,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: selectedLocation, 
          initialZoom: 16.0,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: selectedLocation,
                child: const Icon(
                  Icons.location_pin,
                  size: 40,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddressField() {
    return TextField(
      controller: addressController,
      decoration: InputDecoration(
        labelText: 'Dirección',
        labelStyle: const TextStyle(color: Color(0xFFA3AEC2)),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _selectedLocationNotifier.value = null; 
            });
            _convertAddressToCoordinates(addressController.text);
          },
        ),
        border: const OutlineInputBorder(),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFA3AEC2), width: 2.0),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    if (images != null && images!.isNotEmpty) {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0, 
          childAspectRatio: 1, 
        ),
        physics:
            const NeverScrollableScrollPhysics(),
        shrinkWrap: true, 
        itemCount: images!.length,
        itemBuilder: (context, index) {
          return Stack(
            alignment: Alignment.topRight,
            children: [
              SizedBox(
                height: 80,
                width: double
                    .infinity, 
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(images![index].path),
                    fit: BoxFit
                        .cover, 
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () =>
                    _removeImage(index),
              ),
            ],
          );
        },
      );
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Ubicación", style: TextStyle(fontSize: 18)),
        backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1)
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8F8FA),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(nameController, "Nombre del lugar"),
              _buildTextField(descriptionController, "Descripción"),
              _buildAddressField(),
              const SizedBox(height: 10),
              ValueListenableBuilder<LatLng?>(
                valueListenable: _selectedLocationNotifier,
                builder: (context, selectedLocation, child) {
                  if (selectedLocation != null) {
                    return _buildMapPreview(selectedLocation);
                  } else {
                    return const SizedBox();
                  }
                },
              ),
              const SizedBox(height: 10),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _pickImages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF64D0DE),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: const Text("Agregar imágenes"),
                ),
              ),
              const SizedBox(height: 10),
              _buildImagePreview(),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF111B54), 
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 10), 
                    textStyle: const TextStyle(fontSize: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20), 
                    ),
                  ),
                  child: const Text("Guardar ubicación",
                      style: TextStyle(color: Colors.white, fontSize: 15)),
                ),
              ),
              if (_isLoading) 
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}

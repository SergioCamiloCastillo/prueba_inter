import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prueba_inter/features/friends/domain/entities/friend_entity.dart';
import 'package:prueba_inter/features/friends/infrastructure/datasources/friends_datasource_localdatabase_impl.dart';
import 'package:prueba_inter/features/friends/infrastructure/repositories/friends_repository_impl.dart';
import 'package:prueba_inter/features/friends/presentation/stores/friends_store.dart';
import 'package:go_router/go_router.dart';
import 'package:prueba_inter/features/locations/domain/entities/location_entity.dart';
import 'package:prueba_inter/features/locations/infrastructure/datasources/locations_datasource_localdatabase_impl.dart';
import 'package:prueba_inter/features/locations/infrastructure/repositories/locations_repository_impl.dart';
import 'package:prueba_inter/features/locations/presentation/store/locations_store.dart';

class FriendDetailScreen extends StatefulWidget {
  static const String name = "friend-detail-screen";
  final int idFriend;

  const FriendDetailScreen({super.key, required this.idFriend});

  @override
  _FriendDetailScreenState createState() => _FriendDetailScreenState();
}

class _FriendDetailScreenState extends State<FriendDetailScreen> {
  late FriendsStore _friendsStore;
  late LocationsStore _locationsStore;
  FriendEntity? _friend;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  String? _imagePath;
  List<LocationEntity> _locations = [];
  List<LocationEntity> _availableLocations =
      []; // Lista de ubicaciones disponibles para seleccionar
  final List<int> _selectedLocationIds =
      []; // Lista de IDs de ubicaciones seleccionadas

  @override
  void initState() {
    super.initState();
    _initializeStores();
    _loadFriendDetails();
    _loadLocations(); // Cargar ubicaciones al iniciar
  }

  void _initializeStores() {
    final friendsDatasource = FriendsDatasourceLocaldatabaseImpl();
    final friendsRepository =
        FriendsRepositoryImpl(datasource: friendsDatasource);
    _friendsStore = FriendsStore(friendsRepository);

    final locationsDatasource = LocationsDatasourceLocaldatabaseImpl();
    final locationsRepository =
        LocationsRepositoryImpl(datasource: locationsDatasource);
    _locationsStore = LocationsStore(locationsRepository);
  }

  Future<void> _loadFriendDetails() async {
    final friend = await _friendsStore.getFriendById(widget.idFriend);
    if (friend != null) {
      setState(() {
        _friend = friend;
        firstNameController.text = friend.firstName;
        lastNameController.text = friend.lastName;
        emailController.text = friend.email;
        phoneNumberController.text = friend.telephone;
        _imagePath = friend.photo; // Cargar la foto del amigo si existe
      });
      // Cargar las ubicaciones del amigo
      await _loadFriendLocations(); // Cargar ubicaciones del amigo
    } else {
      setState(() {
        _friend = null; // Establece _friend en null si no se encuentra
      });
    }
  }

  Future<void> _loadFriendLocations() async {
    if (_friend != null) {
      // Obtener ubicaciones asociadas al amigo
      List<LocationEntity> friendLocations =
          await _friendsStore.fetchLocationsByFriend(_friend!.idFriend!);
      setState(() {
        // Obtener solo los IDs de las ubicaciones
        _selectedLocationIds
            .addAll(friendLocations.map((location) => location.idLocation!));
      });
    }
  }

  Future<void> _loadLocations() async {
    // Cargar todas las ubicaciones de la base de datos
    List<LocationEntity> allLocations = await _locationsStore.fetchLocations();
    List<LocationEntity> occupiedLocations = await _friendsStore
        .fetchOccupiedLocationsExcludingFriend(widget.idFriend);

    // Filtrar ubicaciones ocupadas
    _availableLocations = allLocations
        .where((location) => !occupiedLocations
            .any((occupied) => occupied.idLocation == location.idLocation))
        .toList();

    setState(() {
      _locations = _availableLocations; // Asigna solo ubicaciones disponibles
    });
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _imagePath =
              image.path; // Actualizar la ruta de la imagen seleccionada
        });
      }
    } catch (e) {
      print("Error al seleccionar imagen: $e");
    }
  }

  Future<void> _saveFriendDetails() async {
    if (_friend != null) {
      final updatedFriend = FriendEntity(
        idFriend: _friend!.idFriend,
        firstName: firstNameController.text,
        lastName: lastNameController.text,
        email: emailController.text,
        telephone: phoneNumberController.text,
        photo: _imagePath ?? _friend!.photo,
      );

      await _friendsStore.updateFriend(updatedFriend);
      await _removeUnselectedLocations(); // Eliminar ubicaciones no seleccionadas al guardar
      await _assignLocations(); // Asignar las ubicaciones aquí
      GoRouter.of(context).replace('/friends');
    }
  }

  Future<void> _removeUnselectedLocations() async {
    if (_friend != null) {
      // Obtener ubicaciones actuales asociadas al amigo
      List<LocationEntity> friendLocations =
          await _friendsStore.fetchLocationsByFriend(_friend!.idFriend!);

      for (var location in friendLocations) {
        if (!_selectedLocationIds.contains(location.idLocation)) {
          await _friendsStore.removeLocation(
              _friend!.idFriend!, location.idLocation!);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "Ubicación ${location.name} eliminada de ${_friend!.firstName}"),
            ),
          );
        }
      }
    }
  }

  Future<void> _assignLocations() async {
    if (_friend != null && _selectedLocationIds.isNotEmpty) {
      for (var locationId in _selectedLocationIds) {
        await _friendsStore.assignLocation(_friend!.idFriend!, locationId);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ubicaciones asignadas a ${_friend!.firstName}"),
        ),
      );
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detalles del Amigo")),
      body: _friend == null
          ? const Center(
              child: Text("No hay información disponible sobre este amigo."))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(firstNameController, "Nombre"),
                  _buildTextField(lastNameController, "Apellido"),
                  _buildTextField(emailController, "Email"),
                  _buildTextField(phoneNumberController, "Teléfono"),
                  const SizedBox(height: 20),
                  _buildImagePicker(),
                  const SizedBox(height: 20),
                  const Text("Seleccionar Ubicaciones:",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  _buildLocationSelection(), // Método para construir la selección de ubicaciones

                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveFriendDetails,
                    child: const Text("Guardar Cambios"),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text("Seleccionar Imagen"),
        ),
        const SizedBox(height: 10),
        _imagePath != null &&
                _imagePath!.isNotEmpty &&
                File(_imagePath!).existsSync()
            ? Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Image.file(
                  File(_imagePath!),
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              )
            : const Text("No se ha seleccionado ninguna imagen"),
      ],
    );
  }

  Widget _buildLocationSelection() {
    return Wrap(
      spacing: 10.0,
      runSpacing: 10.0,
      children: _locations.map((location) {
        return GestureDetector(
          onTap: () {
            setState(() {
              if (_selectedLocationIds.contains(location.idLocation)) {
                // Si la ubicación ya está seleccionada, simplemente la deselecciona
                _selectedLocationIds.remove(location.idLocation);
              } else {
                if (_selectedLocationIds.length < 5) {
                  _selectedLocationIds.add(location.idLocation!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text("Solo puedes seleccionar hasta 5 ubicaciones."),
                    ),
                  );
                }
              }
            });
          },
          child: Card(
            color: _selectedLocationIds.contains(location.idLocation)
                ? Colors.blueAccent
                : Colors.grey[300],
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                location.name,
                style: TextStyle(
                  color: _selectedLocationIds.contains(location.idLocation)
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

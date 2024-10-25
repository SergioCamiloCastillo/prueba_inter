import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:prueba_inter/features/friends/domain/entities/friend_entity.dart';
import 'package:prueba_inter/features/friends/infrastructure/datasources/friends_datasource_localdatabase_impl.dart';
import 'package:prueba_inter/features/friends/infrastructure/repositories/friends_repository_impl.dart';
import 'package:prueba_inter/features/friends/presentation/stores/friends_store.dart';
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
  List<LocationEntity> _availableLocations = [];
  final List<int> _selectedLocationIds = [];
  String? _originalFirstName;
  String? _originalLastName;
  String? _originalEmail;
  String? _originalPhoneNumber;
  String? _originalImagePath;
  List<int> _originalSelectedLocationIds = [];
  final Map<String, String> _errorMessages = {
    'firstName': '',
    'lastName': '',
    'email': '',
    'phoneNumber': '',
  };

  @override
  void initState() {
    super.initState();
    _initializeStores();
    _loadFriendDetails();
    _loadLocations();
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
        _imagePath = friend.photo;
        _originalFirstName = friend.firstName;
        _originalLastName = friend.lastName;
        _originalEmail = friend.email;
        _originalPhoneNumber = friend.telephone;
        _originalImagePath = friend.photo;
      });
      await _loadFriendLocations();
    } else {
      setState(() {
        _friend = null;
      });
    }
  }

  Future<void> _loadFriendLocations() async {
    if (_friend != null) {
      List<LocationEntity> friendLocations =
          await _friendsStore.fetchLocationsByFriend(_friend!.idFriend!);
      setState(() {
        _selectedLocationIds
            .addAll(friendLocations.map((location) => location.idLocation!));
        _originalSelectedLocationIds = List<int>.from(_selectedLocationIds);
      });
    }
  }

  Future<void> _loadLocations() async {
    List<LocationEntity> allLocations = await _locationsStore.fetchLocations();
    List<LocationEntity> occupiedLocations = await _friendsStore
        .fetchOccupiedLocationsExcludingFriend(widget.idFriend);

    _availableLocations = allLocations
        .where((location) => !occupiedLocations
            .any((occupied) => occupied.idLocation == location.idLocation))
        .toList();

    setState(() {
      _locations = _availableLocations;
    });
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _imagePath = image.path;
        });
      }
    } catch (e) {
      print("Error al seleccionar imagen: $e");
    }
  }

  bool _isEmailValid(String email) {
    String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    RegExp regex = RegExp(pattern);
    return regex.hasMatch(email);
  }

  Future<void> _saveFriendDetails() async {
    _errorMessages.forEach((key, value) {
      _errorMessages[key] = '';
    });

    if (firstNameController.text.isEmpty) {
      _errorMessages['firstName'] = 'Este campo es obligatorio';
    } else {
      _errorMessages['firstName'] = '';
    }

    if (lastNameController.text.isEmpty) {
      _errorMessages['lastName'] = 'Este campo es obligatorio';
    } else {
      _errorMessages['lastName'] = '';
    }
    if (emailController.text.isEmpty) {
      _errorMessages['email'] = 'Este campo es obligatorio';
    } else if (!_isEmailValid(emailController.text)) {
      _errorMessages['email'] =
          'Por favor, introduce un correo electrónico válido';
    } else {
      _errorMessages['email'] = '';
    }
    if (phoneNumberController.text.isEmpty) {
      _errorMessages['phoneNumber'] = 'Este campo es obligatorio';
    } else {
      _errorMessages['phoneNumber'] = '';
    }

    if (_errorMessages.values.any((msg) => msg.isNotEmpty)) {
      setState(() {});
      return;
    }

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
      await _removeUnselectedLocations();
      await _assignLocations();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Datos del amigo actualizados correctamente."),
          backgroundColor: Colors.green,
        ),
      );
      context.pop(true);
    }
  }

  Future<void> _removeUnselectedLocations() async {
    if (_friend != null) {
      List<LocationEntity> friendLocations =
          await _friendsStore.fetchLocationsByFriend(_friend!.idFriend!);
      for (var location in friendLocations) {
        if (!_selectedLocationIds.contains(location.idLocation)) {
          await _friendsStore.removeLocation(
              _friend!.idFriend!, location.idLocation!);
        }
      }
    }
  }

  Future<void> _assignLocations() async {
    if (_friend != null && _selectedLocationIds.isNotEmpty) {
      for (var locationId in _selectedLocationIds) {
        await _friendsStore.assignLocation(_friend!.idFriend!, locationId);
      }
    }
  }

  bool _hasChanges() {
    return firstNameController.text != _originalFirstName ||
        lastNameController.text != _originalLastName ||
        emailController.text != _originalEmail ||
        phoneNumberController.text != _originalPhoneNumber ||
        _imagePath != _originalImagePath ||
        !_listEquals(_selectedLocationIds, _originalSelectedLocationIds);
  }

  bool _listEquals(List<int> list1, List<int> list2) {
    if (list1.length != list2.length) return false;
    for (var item in list1) {
      if (!list2.contains(item)) return false;
    }
    return true;
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
      appBar: AppBar(
        title: const Text("Detalles del Amigo", style: TextStyle(fontSize: 18)),
        backgroundColor: Colors.orangeAccent.withOpacity(0.2),
      ),
      body: _friend == null
          ? const Center(
              child: Text("No hay información disponible sobre este amigo."),
            )
          : Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8F8FA),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                            child: _buildTextField(
                                firstNameController, "Nombre", 'firstName')),
                        const SizedBox(width: 10),
                        Expanded(
                            child: _buildTextField(
                                lastNameController, "Apellido", 'lastName')),
                      ],
                    ),
                    _buildTextField(
                        emailController, "Correo electrónico", 'email'),
                    _buildTextField(phoneNumberController, "Teléfono o celular",
                        'phoneNumber'),
                    const SizedBox(height: 20),
                    Text(
                        _locations.isNotEmpty
                            ? "Asignar ubicaciones:"
                            : "Sin ubicaciones disponibles",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _buildLocationSelection(),
                    const SizedBox(height: 20),
                    _buildSaveButton(),
                  ],
                ),
              ),
            ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildProfileHeader() {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipOval(
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: _imagePath != null &&
                            _imagePath!.isNotEmpty &&
                            File(_imagePath!).existsSync()
                        ? Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.person,
                            size: 100,
                            color: Colors.grey,
                          ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.orangeAccent,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _friend?.firstName ?? 'Nombre',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            _friend?.lastName ?? 'Apellido',
            style: const TextStyle(fontSize: 18, color: Color(0xFFA3AEC2)),
          ),
          const SizedBox(height: 8),
          const Text(
            "Toca la imagen para cambiarla",
            style: TextStyle(fontSize: 12, color: Color(0xFFA3AEC2)),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            onChanged: (value) {
              setState(() {});
            },
            decoration: InputDecoration(
              labelStyle: const TextStyle(color: Color(0xFFA3AEC2)),
              labelText: label,
              border: const OutlineInputBorder(),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFA3AEC2), width: 2.0),
              ),
            ),
          ),
          if (_errorMessages[key]!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                _errorMessages[key]!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
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
                ? Colors.orangeAccent
                : Colors.grey[300],
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                location.name,
                style: TextStyle(
                  color: _selectedLocationIds.contains(location.idLocation)
                      ? Colors.white
                      : Colors.black,
                  fontWeight: _selectedLocationIds.contains(location.idLocation)
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        onPressed: _hasChanges() ? _saveFriendDetails : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF111B54),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
          textStyle: const TextStyle(fontSize: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text("Guardar Cambios",
            style: TextStyle(color: Colors.white, fontSize: 15)),
      ),
    );
  }
}

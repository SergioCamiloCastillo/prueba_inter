import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prueba_inter/config/helpers/functions.dart';
import 'package:prueba_inter/features/friends/domain/entities/friend_entity.dart';
import 'package:prueba_inter/features/friends/infrastructure/datasources/friends_datasource_localdatabase_impl.dart';
import 'package:prueba_inter/features/friends/infrastructure/repositories/friends_repository_impl.dart';
import 'package:prueba_inter/features/friends/presentation/stores/friends_store.dart';
import 'package:prueba_inter/features/locations/domain/entities/location_entity.dart';
import 'package:prueba_inter/features/locations/infrastructure/datasources/locations_datasource_localdatabase_impl.dart';
import 'package:prueba_inter/features/locations/infrastructure/repositories/locations_repository_impl.dart';
import 'package:prueba_inter/features/locations/presentation/store/locations_store.dart';
import 'package:prueba_inter/features/shared/widgets/card_list.dart';

class FriendsScreen extends StatefulWidget {
  static const name = "friends-screen";
  const FriendsScreen({super.key});

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  late FriendsStore _friendsStore;
  late LocationsStore _locationsStore;
  String? _imagePath;
  final List<LocationEntity> _availableLocations = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    final friendsDatasource = FriendsDatasourceLocaldatabaseImpl();
    final friendsRepository =
        FriendsRepositoryImpl(datasource: friendsDatasource);
    _friendsStore = FriendsStore(friendsRepository);
    _friendsStore.fetchFriends();

    final locationsDatasource = LocationsDatasourceLocaldatabaseImpl();
    final locationsRepository =
        LocationsRepositoryImpl(datasource: locationsDatasource);
    _locationsStore = LocationsStore(locationsRepository);
  }

  void _showAddFriendDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddFriendDialog(
          onImagePicked: (String path) {
            setState(() {
              _imagePath = path;
            });
          },
          friendsStore: _friendsStore,
          locationsStore: _locationsStore,
        );
      },
    );
  }

  void _deleteFriend(int friendId) async {
    bool success = await _friendsStore.deleteFriend(friendId);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Amigo eliminado exitosamente."),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al eliminar amigo."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<FriendEntity> _filterFriends(List<FriendEntity> friends) {
    if (_searchQuery.isEmpty) {
      return friends;
    } else {
      return friends
          .where((friend) =>
              friend.firstName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ||
              friend.lastName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Amigos registrados")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  setState(() {
                    _searchQuery = query;
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Buscar por nombre',
                  hintStyle: TextStyle(color: Colors.grey),
                  prefixIcon: Icon(Icons.search, color: Colors.grey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          Expanded(
            child: Observer(
              builder: (_) {
                if (_friendsStore.friends.isEmpty) {
                  return const Center(child: Text("No hay amigos."));
                }

                final filteredFriends = _filterFriends(_friendsStore.friends);

                if (filteredFriends.isEmpty) {
                  return const Center(
                      child: Text("No se encontraron coincidencias."));
                }

                return ListView.builder(
                  itemCount: filteredFriends.length,
                  itemBuilder: (context, index) {
                    final friend = filteredFriends[index];

                    return FutureBuilder<int>(
                      future: _friendsStore
                          .fetchLocationsByFriend(friend.idFriend!)
                          .then((locations) => locations.length),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (snapshot.hasError) {
                          return const Center(
                              child: Text("Error al cargar ubicaciones"));
                        }

                        final int locationCount = snapshot.data ?? 0;

                        return CardList(
                          icon: Icons.person,
                          photo: friend.photo,
                          title:
                              "${capitalizeFirstLetter(friend.firstName)} ${capitalizeFirstLetter(friend.lastName)}",
                          subTitle: locationCount > 0
                              ? locationCount > 1
                                  ? '$locationCount ubicaciones asignadas'
                                  : '$locationCount ubicación asignada'
                              : 'Sin ubicaciones asignadas',
                          onDelete: () {
                            if (friend.idFriend != null) {
                              _deleteFriend(friend.idFriend!);
                            }
                          },
                          colorCard: Colors.orangeAccent,
                          onTap: () async {
                            if (friend.idFriend != null) {
                              final result = await GoRouter.of(context)
                                  .push('/friend/${friend.idFriend}');
                              if (result == true) {
                                _friendsStore.fetchFriends();
                              }
                            }
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFriendDialog,
        tooltip: "Agregar Amigo",
        child: const Icon(Icons.person_add),
      ),
    );
  }
}

class AddFriendDialog extends StatefulWidget {
  final Function(String) onImagePicked;
  final LocationsStore locationsStore;
  final FriendsStore friendsStore;

  const AddFriendDialog({
    super.key,
    required this.onImagePicked,
    required this.locationsStore,
    required this.friendsStore,
  });

  @override
  _AddFriendDialogState createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<AddFriendDialog> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  String? _imagePath;
  List<LocationEntity> _locations = [];
  final List<int> _selectedLocationIds = [];

  bool _hasSubmitted = false;
  final Map<String, String> _errorMessages = {
    'firstName': '',
    'lastName': '',
    'email': '',
    'phoneNumber': '',
  };

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    List<LocationEntity> allLocations =
        await widget.locationsStore.fetchLocations();
    List<LocationEntity> occupiedLocations =
        await widget.friendsStore.fetchOccupiedLocationsExcludingFriend(0);
    setState(() {
      _locations = allLocations
          .where((location) => !occupiedLocations
              .any((occupied) => occupied.idLocation == location.idLocation))
          .toList();
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
      widget.onImagePicked(image.path);
    }
  }

  bool _validateFields() {
    bool isValid = true;

    setState(() {
      _errorMessages['firstName'] =
          firstNameController.text.isEmpty ? 'El nombre es obligatorio' : '';
      _errorMessages['lastName'] =
          lastNameController.text.isEmpty ? 'El apellido es obligatorio' : '';
      _errorMessages['email'] = _isValidEmail(emailController.text)
          ? ''
          : 'Introduce un correo válido';
      _errorMessages['phoneNumber'] =
          _isValidPhoneNumber(phoneNumberController.text)
              ? ''
              : 'Introduce un número de teléfono válido';

      isValid = _errorMessages.values.every((error) => error.isEmpty);
    });

    return isValid;
  }

  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    final phoneRegExp = RegExp(r'^\d{3,}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Agregar Amigo",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
      ),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(firstNameController, "Nombre", 'firstName'),
              _buildErrorText('firstName'),
              const SizedBox(height: 10),
              _buildTextField(lastNameController, "Apellido", 'lastName'),
              _buildErrorText('lastName'),
              const SizedBox(height: 10),
              _buildTextField(emailController, "Email", 'email'),
              _buildErrorText('email'),
              const SizedBox(height: 10),
              _buildTextField(
                  phoneNumberController, "Número de Teléfono", 'phoneNumber'),
              _buildErrorText('phoneNumber'),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text("Seleccionar Imagen"),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.orange.withOpacity(0.5),
                ),
              ),
              if (_imagePath != null) ...[
                const SizedBox(height: 10),
                Image.file(File(_imagePath!), height: 100),
              ],
              const SizedBox(height: 10),
              Text(
                _locations.isNotEmpty
                    ? "Seleccionar Ubicaciones:"
                    : 'Sin ubicaciones disponibles',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              _buildLocationSelection(),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.orangeAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            elevation: 5,
          ),
          onPressed: () {
            setState(() {
              _hasSubmitted = true;
            });

            if (_validateFields()) {
              _addFriend();
            }
          },
          child: const Text("Agregar Amigo"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancelar"),
        ),
      ],
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String key) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[200],
      ),
      onChanged: (value) {
        if (_hasSubmitted) {
          _validateFields();
        }
      },
    );
  }

  Widget _buildErrorText(String key) {
    return Visibility(
      visible: _errorMessages[key]!.isNotEmpty && _hasSubmitted,
      child: Text(
        _errorMessages[key]!,
        style: const TextStyle(color: Colors.red),
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

  Future<void> _addFriend() async {
    FriendEntity newFriend = FriendEntity(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      email: emailController.text,
      telephone: phoneNumberController.text,
      photo: _imagePath ?? '',
    );

    final response = await widget.friendsStore.addFriend(newFriend);
    if (response["success"]) {
      int friendId = response['id'];
      await _assignLocations(friendId);

      await widget.friendsStore.fetchFriends();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"]),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response["message"]),
          backgroundColor: Colors.red,
        ),
      );
    }
    Navigator.of(context).pop();
  }

  Future<void> _assignLocations(int friendId) async {
    for (var locationId in _selectedLocationIds) {
      await widget.friendsStore.assignLocation(friendId, locationId);
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prueba_inter/features/friends/domain/entities/friend_entity.dart';
import 'package:prueba_inter/features/friends/infrastructure/datasources/friends_datasource_localdatabase_impl.dart';
import 'package:prueba_inter/features/friends/infrastructure/repositories/friends_repository_impl.dart';
import 'package:prueba_inter/features/friends/presentation/stores/friends_store.dart';
import 'package:prueba_inter/features/locations/domain/entities/location_entity.dart';
import 'package:prueba_inter/features/locations/infrastructure/datasources/locations_datasource_localdatabase_impl.dart';
import 'package:prueba_inter/features/locations/infrastructure/repositories/locations_repository_impl.dart';
import 'package:prueba_inter/features/locations/presentation/store/locations_store.dart';

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

  @override
  void initState() {
    super.initState();
    final friendsDatasource = FriendsDatasourceLocaldatabaseImpl();
    final friendsRepository =
        FriendsRepositoryImpl(datasource: friendsDatasource);
    _friendsStore = FriendsStore(friendsRepository);
    _friendsStore.fetchFriends(); // Carga los amigos al iniciar la pantalla

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
              _imagePath = path; // Actualiza la imagen seleccionada
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Amigos")),
      body: Observer(
        builder: (_) {
          if (_friendsStore.friends.isEmpty) {
            return const Center(child: Text("No hay amigos."));
          }
          return ListView.builder(
            itemCount: _friendsStore.friends.length,
            itemBuilder: (context, index) {
              final friend = _friendsStore.friends[index];
              return GestureDetector(
                onTap: () =>
                    GoRouter.of(context).push('/friend/${friend.idFriend}'),
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: friend.photo.isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: FileImage(File(friend.photo)),
                          )
                        : const CircleAvatar(child: Icon(Icons.person)),
                    title: Text('${friend.firstName} ${friend.lastName}'),
                    subtitle: Text(friend.email),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteFriend(friend.idFriend!),
                    ),
                  ),
                ),
              );
            },
          );
        },
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
  final FriendsStore friendsStore;
  final LocationsStore locationsStore;

  const AddFriendDialog({
    required this.onImagePicked,
    required this.friendsStore,
    required this.locationsStore,
    super.key,
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
    print('Ubicaciones ocupadas: $occupiedLocations');
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
        _imagePath = image.path; // Almacena la ruta de la imagen seleccionada
      });
      widget.onImagePicked(
          image.path); // Llama a la función para actualizar la imagen
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Agregar Amigo"),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(labelText: "Nombre"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(labelText: "Apellido"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneNumberController,
                decoration:
                    const InputDecoration(labelText: "Número de Teléfono"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text("Seleccionar Imagen"),
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
          onPressed: () async {
            FriendEntity newFriend = FriendEntity(
              firstName: firstNameController.text,
              lastName: lastNameController.text,
              email: emailController.text,
              telephone: phoneNumberController.text,
              photo: _imagePath ??
                  '', // Usa la imagen seleccionada o una cadena vacía
            );

            final response = await widget.friendsStore.addFriend(newFriend);
            if (response["success"]) {
              await _assignLocations(response['id']);
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
          },
          child: const Text("Agregar Amigo"),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Cierra el diálogo
          },
          child: const Text("Cancelar"),
        ),
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
                ? const Color(0xFF64D0DE)
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

  Future<void> _assignLocations(int friendId) async {
    for (var locationId in _selectedLocationIds) {
      await widget.friendsStore.assignLocation(friendId, locationId);
    }
  }
}

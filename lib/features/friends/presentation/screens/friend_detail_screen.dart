import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prueba_inter/features/friends/domain/entities/friend_entity.dart';
import 'package:prueba_inter/features/friends/infrastructure/datasources/friends_datasource_localdatabase_impl.dart';
import 'package:prueba_inter/features/friends/infrastructure/repositories/friends_repository_impl.dart';
import 'package:prueba_inter/features/friends/presentation/stores/friends_store.dart';
import 'package:go_router/go_router.dart';

class FriendDetailScreen extends StatefulWidget {
  static const String name = "friend-detail-screen";
  final int idFriend;

  const FriendDetailScreen({super.key, required this.idFriend});

  @override
  _FriendDetailScreenState createState() => _FriendDetailScreenState();
}

class _FriendDetailScreenState extends State<FriendDetailScreen> {
  late FriendsStore _friendsStore;
  FriendEntity? _friend;

  // Controladores de texto para editar la información del amigo
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  String? _imagePath;

  @override
  void initState() {
    super.initState();

    // Instanciar manualmente el datasource, repositorio y el store
    final datasource = FriendsDatasourceLocaldatabaseImpl();
    final repository = FriendsRepositoryImpl(datasource: datasource);
    _friendsStore = FriendsStore(repository);

    // Cargar los detalles del amigo
    _loadFriendDetails();
  }

  Future<void> _loadFriendDetails() async {
    // Cambiar getFriendById a un método que devuelva Future<FriendEntity?>
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
    } else {
      setState(() {
        _friend = null; // Establece _friend en null si no se encuentra
      });
    }
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
      // Manejo de errores
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
        photo: _imagePath ??
            _friend!
                .photo, // Mantener la foto existente si no se selecciona una nueva
      );

      // Actualizar el amigo en el store
      await _friendsStore.updateFriend(updatedFriend);
      GoRouter.of(context).replace('/friends'); // Volver a la pantalla anterior
    }
  }

  @override
  void dispose() {
    // Limpiar los controladores de texto cuando se elimine la pantalla
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
                    decoration: const InputDecoration(labelText: "Teléfono"),
                  ),
                  const SizedBox(height: 20),
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
                            File(_imagePath!), // Mostrar la imagen seleccionada
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Text("No se ha seleccionado ninguna imagen"),
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
}

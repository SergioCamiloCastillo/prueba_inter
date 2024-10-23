import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:prueba_inter/features/friends/domain/entities/friend_entity.dart';
import 'package:prueba_inter/features/friends/infrastructure/datasources/friends_datasource_localdatabase_impl.dart';
import 'package:prueba_inter/features/friends/infrastructure/repositories/friends_repository_impl.dart';
import 'package:prueba_inter/features/friends/presentation/stores/friends_store.dart';

class FriendsScreen extends StatefulWidget {
  static const name = "friends-screen";
  const FriendsScreen({super.key});

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  late FriendsStore _friendsStore;

  @override
  void initState() {
    super.initState();

    // Instanciar manualmente el datasource, repositorio y el store
    final datasource = FriendsDatasourceLocaldatabaseImpl();
    final repository = FriendsRepositoryImpl(datasource: datasource);
    _friendsStore = FriendsStore(repository);

    // Cargar amigos cuando se inicializa el estado
    _friendsStore.fetchFriends();
  }

  void _showAddFriendDialog() {
    final TextEditingController firstNameController = TextEditingController();
    final TextEditingController lastNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneNumberController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar Amigo"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: "Nombre"),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: "Apellido"),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: phoneNumberController,
                  decoration: const InputDecoration(labelText: "Teléfono"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Aquí podrías añadir la lógica para agregar un amigo
                String firstName = firstNameController.text;
                String lastName = lastNameController.text;
                String email = emailController.text;
                String phoneNumber = phoneNumberController.text;

                if (firstName.isNotEmpty && lastName.isNotEmpty) {
                  // Agregar amigo a la lista
                  _friendsStore.addFriend(
                    FriendEntity(
                      idFriend: DateTime.now().toString(),
                      firstName: firstName,
                      lastName: lastName,
                      email: email,
                      telephone: phoneNumber,
                      photo:
                          '', // Puedes añadir una lógica para subir fotos si es necesario
                      assignedLocations: [],
                    ),
                  );
                  Navigator.of(context).pop();
                } else {
                  // Puedes mostrar un mensaje de error si es necesario
                }
              },
              child: const Text("Agregar"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Amigos")),
      body: Observer(
        builder: (_) {
          return ListView.builder(
            itemCount: _friendsStore.friends.length,
            itemBuilder: (context, index) {
              final amigo = _friendsStore.friends[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text('${amigo.firstName} ${amigo.lastName}'),
                  subtitle: Text(amigo.email),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // Lógica para eliminar un amigo
                      // _friendsStore.deleteFriend(amigo.id);
                    },
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
        child: const Icon(Icons.add),
      ),
    );
  }
}

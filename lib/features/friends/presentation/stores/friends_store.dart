import 'package:mobx/mobx.dart';
import 'package:prueba_inter/features/friends/domain/entities/friend_entity.dart';
import 'package:prueba_inter/features/friends/domain/repositories/friends_repository.dart';

part 'friends_store.g.dart';

class FriendsStore = _FriendsStore with _$FriendsStore;

abstract class _FriendsStore with Store {
  final FriendsRepository friendsRepository;

  @observable
  ObservableList<FriendEntity> friends = ObservableList<FriendEntity>();

  _FriendsStore(this.friendsRepository);

  @action
  Future<void> fetchFriends() async {
    friends.clear();
    friends.addAll(await friendsRepository.getFriends());
  }

  @action
  Future<Map<String, dynamic>> addFriend(FriendEntity friend) async {
    // Verificar si la cantidad de amigos es menor a 5
    if (friends.length >= 5) {
      print('No se puede agregar más amigos, ya tienes 5.');
      return {
        "success": false,
        "message": "No se pueden agregar más amigos, máximo 5"
      }; // No se puede agregar más amigos
    }

    try {
      await friendsRepository.addFriend(friend);
      await fetchFriends(); // Refrescar la lista después de agregar
      return {
        "success": true,
        "message": "Agregado exitosamente"
      }; // Operación exitosa
    } catch (e) {
      // Manejo de errores
      print("Error al agregar amigo: $e");
      return {
        "success": false,
        "message": "Error al agregar amigo"
      }; // Indica que hubo un error
    }
  }

  @action
  Future<void> updateFriend(FriendEntity friend) async {
    try {
      await friendsRepository.updateFriend(friend);
      await fetchFriends(); // Refrescar la lista después de actualizar
    } catch (e) {
      print("Error al actualizar amigo: $e");
    }
  }

  @action
  Future<bool> deleteFriend(int idFriend) async {
    try {
      bool success = await friendsRepository.deleteFriend(idFriend);
      if (success) {
        await fetchFriends(); // Refrescar la lista después de eliminar
      }
      return success;
    } catch (e) {
      print("Error al eliminar amigo: $e");
      return false; // Indica que hubo un error
    }
  }

  @action
  Future<FriendEntity?> getFriendById(int idFriend) async {
    await fetchFriends(); // Esperar a que la lista de amigos se cargue
    print("Buscando amigo con id $idFriend");
    print('Amigos: $friends');
    try {
      return friends.firstWhere((friend) => friend.idFriend == idFriend);
    } catch (e) {
      print("Amigo con id $idFriend no encontrado.");
      return null; // Si no se encuentra, devuelve null
    }
  }

  @action
  Future<void> assignLocation(int friendId, int locationId) async {
    await friendsRepository.assignLocationToFriend(friendId, locationId);
    await fetchFriends(); // Refrescar la lista después de la asignación
  }
}

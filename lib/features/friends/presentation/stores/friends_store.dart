import 'package:mobx/mobx.dart';
import 'package:prueba_inter/features/friends/domain/entities/friend_entity.dart';
import 'package:prueba_inter/features/friends/domain/repositories/friends_repository.dart';
import 'package:prueba_inter/features/locations/domain/entities/location_entity.dart';

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
  if (friends.length >= 5) {
    print('No se puede agregar más amigos, ya tienes 5.');
    return {
      "success": false,
      "message": "No se pueden agregar más amigos, máximo 5"
    }; 
  }

  try {
    final response = await friendsRepository.addFriend(friend);
    friends.add(friend); // Agrega el amigo directamente sin hacer fetch
    return response; 
  } catch (e) {
    print("Error al agregar amigo: $e");
    return {
      "success": false,
      "message": "Error al agregar amigo"
    }; 
  }
}

  @action
Future<void> updateFriend(FriendEntity friend) async {
  try {
    await friendsRepository.updateFriend(friend);
    final index = friends.indexWhere((f) => f.idFriend == friend.idFriend);
    if (index != -1) {
      friends[index] = friend; // Actualiza directamente el amigo en la lista
    }
  } catch (e) {
    print("Error al actualizar amigo: $e");
  }
}

  @action
  Future<bool> deleteFriend(int idFriend) async {
    try {
      bool success = await friendsRepository.deleteFriend(idFriend);
      if (success) {
        await fetchFriends();
      }
      return success;
    } catch (e) {
      print("Error al eliminar amigo: $e");
      return false; 
    }
  }

  @action
  Future<FriendEntity?> getFriendById(int idFriend) async {
    await fetchFriends(); 
    print("Buscando amigo con id $idFriend");
    print('Amigos: $friends');
    try {
      return friends.firstWhere((friend) => friend.idFriend == idFriend);
    } catch (e) {
      print("Amigo con id $idFriend no encontrado.");
      return null; 
    }
  }

  @action
  Future<List<LocationEntity>> fetchLocationsByFriend(int friendId) async {
    try {
      List<LocationEntity> locations =
          await friendsRepository.getLocationsByFriend(friendId);

      return locations;
    } catch (e) {
      print("Error al obtener ubicaciones del amigo: $e");
      return [];
    }
  }

  @action
  Future<List<LocationEntity>> fetchOccupiedLocationsExcludingFriend(
      int friendId) async {
    try {
      List<LocationEntity> locations =
          await friendsRepository.getLocationsOcupped(friendId);

      return locations;
    } catch (e) {
      print("Error al obtener ubicaciones del amigo: $e");
      return [];
    }
  }

  @action
  Future<void> assignLocation(int friendId, int locationId) async {
    await friendsRepository.assignLocationToFriend(friendId, locationId);
    await fetchFriends();
  }

  @action
  Future<bool> removeLocation(int friendId, int locationId) async {
    try {
      await friendsRepository.deleteLocationByFriend(friendId, locationId);

      return true;
    } catch (e) {
      print("Error al obtener ubicaciones del amigo: $e");
      return false;
    }
  }
}

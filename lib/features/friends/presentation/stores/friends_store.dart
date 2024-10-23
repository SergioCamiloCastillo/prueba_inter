// lib/presentation/store/friend_store.dart
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
  Future<void> addFriend(FriendEntity friend) async {
    await friendsRepository.addFriend(friend);
    await fetchFriends(); // Refrescar la lista después de agregar
  }

  @action
  Future<void> assignLocation(int friendId, int locationId) async {
    await friendsRepository.assignLocationToFriend(friendId, locationId);
    await fetchFriends(); // Refrescar la lista después de la asignación
  }
}

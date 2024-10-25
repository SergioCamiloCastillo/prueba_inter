// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friends_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$FriendsStore on _FriendsStore, Store {
  late final _$friendsAtom =
      Atom(name: '_FriendsStore.friends', context: context);

  @override
  ObservableList<FriendEntity> get friends {
    _$friendsAtom.reportRead();
    return super.friends;
  }

  @override
  set friends(ObservableList<FriendEntity> value) {
    _$friendsAtom.reportWrite(value, super.friends, () {
      super.friends = value;
    });
  }

  late final _$fetchFriendsAsyncAction =
      AsyncAction('_FriendsStore.fetchFriends', context: context);

  @override
  Future<void> fetchFriends() {
    return _$fetchFriendsAsyncAction.run(() => super.fetchFriends());
  }

  late final _$addFriendAsyncAction =
      AsyncAction('_FriendsStore.addFriend', context: context);

  @override
  Future<Map<String, dynamic>> addFriend(FriendEntity friend) {
    return _$addFriendAsyncAction.run(() => super.addFriend(friend));
  }

  late final _$updateFriendAsyncAction =
      AsyncAction('_FriendsStore.updateFriend', context: context);

  @override
  Future<void> updateFriend(FriendEntity friend) {
    return _$updateFriendAsyncAction.run(() => super.updateFriend(friend));
  }

  late final _$deleteFriendAsyncAction =
      AsyncAction('_FriendsStore.deleteFriend', context: context);

  @override
  Future<bool> deleteFriend(int idFriend) {
    return _$deleteFriendAsyncAction.run(() => super.deleteFriend(idFriend));
  }

  late final _$getFriendByIdAsyncAction =
      AsyncAction('_FriendsStore.getFriendById', context: context);

  @override
  Future<FriendEntity?> getFriendById(int idFriend) {
    return _$getFriendByIdAsyncAction.run(() => super.getFriendById(idFriend));
  }

  late final _$fetchLocationsByFriendAsyncAction =
      AsyncAction('_FriendsStore.fetchLocationsByFriend', context: context);

  @override
  Future<List<LocationEntity>> fetchLocationsByFriend(int friendId) {
    return _$fetchLocationsByFriendAsyncAction
        .run(() => super.fetchLocationsByFriend(friendId));
  }

  late final _$fetchOccupiedLocationsExcludingFriendAsyncAction = AsyncAction(
      '_FriendsStore.fetchOccupiedLocationsExcludingFriend',
      context: context);

  @override
  Future<List<LocationEntity>> fetchOccupiedLocationsExcludingFriend(
      int friendId) {
    return _$fetchOccupiedLocationsExcludingFriendAsyncAction
        .run(() => super.fetchOccupiedLocationsExcludingFriend(friendId));
  }

  late final _$assignLocationAsyncAction =
      AsyncAction('_FriendsStore.assignLocation', context: context);

  @override
  Future<void> assignLocation(int friendId, int locationId) {
    return _$assignLocationAsyncAction
        .run(() => super.assignLocation(friendId, locationId));
  }

  late final _$removeLocationAsyncAction =
      AsyncAction('_FriendsStore.removeLocation', context: context);

  @override
  Future<bool> removeLocation(int friendId, int locationId) {
    return _$removeLocationAsyncAction
        .run(() => super.removeLocation(friendId, locationId));
  }

  @override
  String toString() {
    return '''
friends: ${friends}
    ''';
  }
}

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
  Future<void> addFriend(FriendEntity friend) {
    return _$addFriendAsyncAction.run(() => super.addFriend(friend));
  }

  late final _$assignLocationAsyncAction =
      AsyncAction('_FriendsStore.assignLocation', context: context);

  @override
  Future<void> assignLocation(int friendId, int locationId) {
    return _$assignLocationAsyncAction
        .run(() => super.assignLocation(friendId, locationId));
  }

  @override
  String toString() {
    return '''
friends: ${friends}
    ''';
  }
}

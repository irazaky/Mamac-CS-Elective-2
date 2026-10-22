import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Nicknames keyed by Pokémon id. The Pokémon's original name is never touched.
class NicknameNotifier extends Notifier<Map<int, String>> {
  @override
  Map<int, String> build() => {};

  /// Adds a nickname, or edits the existing one. An empty text removes it.
  void setNickname(int id, String nickname) {
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) {
      removeNickname(id);
      return;
    }
    // New map object -> Riverpod sees a change and rebuilds listeners.
    state = {...state, id: trimmed};
  }

  void removeNickname(int id) {
    if (!state.containsKey(id)) return;
    state = {...state}..remove(id);
  }
}

final nicknameProvider =
    NotifierProvider<NicknameNotifier, Map<int, String>>(NicknameNotifier.new);

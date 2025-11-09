import 'package:flutter/foundation.dart';

import '../data/dummy_profiles.dart';
import '../models/profile_item.dart';

/// Simple in-memory store that keeps the player list in sync across screens.
class PlayerStore extends ChangeNotifier {
  PlayerStore._internal() {
    _players.addAll(DummyProfiles.profiles);
  }

  static final PlayerStore _instance = PlayerStore._internal();

  factory PlayerStore() => _instance;

  final List<ProfileItem> _players = [];

  List<ProfileItem> get players => List.unmodifiable(_players);

  void add(ProfileItem profile) {
    _players.add(profile);
    notifyListeners();
  }

  void update(ProfileItem updatedProfile) {
    final idx = _players.indexWhere((p) => p.id == updatedProfile.id);
    if (idx == -1) return;
    _players[idx] = updatedProfile;
    notifyListeners();
  }

  void remove(ProfileItem profile) {
    _players.removeWhere((p) => p.id == profile.id);
    notifyListeners();
  }
}

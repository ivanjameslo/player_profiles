import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'new_profile.dart';
import 'edit_profile.dart';
import 'models/profile_item.dart';
import 'data/dummy_profiles.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final List<ProfileItem> _profiles = List.from(DummyProfiles.profiles);
  final TextEditingController _searchController = TextEditingController();
  List<ProfileItem> _filteredProfiles = [];

  @override
  void initState() {
    super.initState();
    _filteredProfiles = List.from(_profiles);
    _searchController.addListener(_filterProfiles);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterProfiles() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredProfiles = List.from(_profiles);
      } else {
        _filteredProfiles = _profiles.where((profile) {
          return profile.nickname.toLowerCase().contains(query) ||
              profile.fullName.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  // Avatar colors based on skill level (darker = more expert)
  final List<Color> _skillLevelColors = [
    const Color(0xFF8ED1B8), // 200 - Beginners (lightest)
    const Color(0xFF62BFA0), // 300 - Intermediate
    const Color(0xFF4DAE8D), // 400 - Level G
    const Color(0xFF33B96D), // 500 - Level F
    const Color(0xFF2DAA61), // 600 - Level E
    const Color(0xFF249B54), // 700 - Level D
    const Color(0xFF214D45), // Primary - Open Player (darkest)
  ];

  Color _getAvatarColorBySkillLevel(ProfileItem profile) {
    // Calculate average skill level
    double avgLevel = (profile.badmintonLevelMin + profile.badmintonLevelMax) / 2;
    
    // Map skill level (0-20) to color index (0-6)
    // 0-2: Beginners, 3-5: Intermediate, 6-8: Level G, 9-11: Level F, 
    // 12-14: Level E, 15-17: Level D, 18-20: Open Player
    int colorIndex = (avgLevel / 3).floor();
    
    // Ensure we don't exceed array bounds
    if (colorIndex >= _skillLevelColors.length) {
      colorIndex = _skillLevelColors.length - 1;
    }
    
    return _skillLevelColors[colorIndex];
  }

  void _addProfile(ProfileItem profile) {
    setState(() {
      _profiles.add(profile);
      _filterProfiles(); // Refresh filtered list
    });
  }

  void _updateProfile(ProfileItem oldProfile, ProfileItem updatedProfile) {
    setState(() {
      final index = _profiles.indexWhere((p) => p.id == oldProfile.id);
      if (index != -1) {
        _profiles[index] = updatedProfile;
        _filterProfiles(); // Refresh filtered list
      }
    });
  }

  void _deleteProfile(ProfileItem profile) {
    setState(() {
      _profiles.remove(profile);
      _filterProfiles(); // Refresh filtered list
    });
  }

  void _openEditProfileModal(ProfileItem profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => EditProfile(
        profile: profile,
        onUpdateProfile: _updateProfile,
        onDeleteProfile: _deleteProfile,
      ),
    );
  }

  Future<void> _confirmDelete(ProfileItem profile) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Player'),
          content: Text(
            'Are you sure you want to delete ${profile.nickname} (${profile.fullName})?\n\nThis action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      _deleteProfile(profile);
    }
  }

  void _openAddProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => NewProfile(onAddProfile: _addProfile),
    );
  }

  String _getBadmintonLevelLabel(double value) {
    final List<String> levels = [
      'Beginners',
      'Intermediate', 
      'Level G',
      'Level F',
      'Level E',
      'Level D',
      'Open Player'
    ];
    
    int levelIndex = (value / 3).floor();
    
    if (levelIndex >= levels.length) {
      levelIndex = levels.length - 1;
    }
    
    return levels[levelIndex];
  }

  String _formatLevelRange(double min, double max) {
    if (min == max) {
      return _getBadmintonLevelLabel(min);
    }
    return '${_getBadmintonLevelLabel(min)} - ${_getBadmintonLevelLabel(max)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Profile', 
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF214D45),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'All Players',
              style: GoogleFonts.tourney(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              cursorColor: const Color(0xFF147A3A),
              decoration: InputDecoration(
                hintText: 'Search players by nickname or name...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: const BorderSide(
                    color: Color(0xFF147A3A),
                    width: 1.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _profiles.isEmpty
                  ? const Center(
                      child: Text(
                        'No players added yet.\nTap the + button to add a player.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : _filteredProfiles.isEmpty
                      ? const Center(
                          child: Text(
                            'No players found.\nTry a different search term.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _filteredProfiles.length,
                          itemBuilder: (context, index) {
                            final profile = _filteredProfiles[index];
                            return Dismissible(
                              key: Key(profile.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: Colors.red,
                                child: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              confirmDismiss: (direction) async {
                                await _confirmDelete(profile);
                                return false; // We handle deletion in confirmDelete
                              },
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  onTap: () {
                                    _openEditProfileModal(profile);
                                  },
                            leading: CircleAvatar(
                              backgroundColor: _getAvatarColorBySkillLevel(profile),
                              child: Text(
                                profile.nickname.substring(0, 1).toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              profile.nickname,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: profile.fullName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ' • ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: _formatLevelRange(profile.badmintonLevelMin, profile.badmintonLevelMax),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF214D45),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddProfileModal,
        backgroundColor: const Color(0xFF214D45),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
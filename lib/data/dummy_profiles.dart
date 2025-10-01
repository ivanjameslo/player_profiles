import '../models/profile_item.dart';

/// Dummy profile data for testing and demonstration purposes
class DummyProfiles {
  static List<ProfileItem> get profiles => [
    ProfileItem(
      id: 'dummy_player_001',
      nickname: 'Phoenix',
      fullName: 'Alex Chen',
      contactNumber: '09123456789',
      email: 'alex.chen@email.com',
      address: '123 Badminton Street, Manila, Philippines',
      remarks: 'Prefers doubles play, available weekends, has own racket',
      badmintonLevelMin: 9.0, // Level F (Weak)
      badmintonLevelMax: 14.0, // Level D (Mid)
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    ProfileItem(
      id: 'dummy_player_002',
      nickname: 'Ace',
      fullName: 'Maria Rodriguez',
      contactNumber: '09987654321',
      email: 'maria.santos@gmail.com',
      address: '456 Victory Lane, Quezon City, Philippines',
      remarks: 'Coach certified, left-handed player, prefers morning sessions',
      badmintonLevelMin: 15.0, // Level D (Strong)
      badmintonLevelMax: 18.0, // Open Player (Weak)
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    ProfileItem(
      id: 'dummy_player_003',
      nickname: 'Thunder',
      fullName: 'John Torres',
      contactNumber: '09456789123',
      email: 'john.torres@yahoo.com',
      address: '789 Champion Drive, Makati City, Philippines',
      remarks: 'Aggressive playstyle, tournament player, available evenings',
      badmintonLevelMin: 3.0, // Intermediate (Weak)
      badmintonLevelMax: 6.0, // Level G (Weak)
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    ProfileItem(
      id: 'dummy_player_004',
      nickname: 'Swift',
      fullName: 'Lee Anderson',
      contactNumber: '09321654987',
      email: 'kim.anderson@hotmail.com',
      address: '321 Shuttlecock Street, Pasig City, Philippines',
      remarks: 'Fast reflexes, doubles specialist, owns multiple rackets',
      badmintonLevelMin: 12.0, // Level E (Weak)
      badmintonLevelMax: 15.0, // Level D (Strong)
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ProfileItem(
      id: 'dummy_player_005',
      nickname: 'Blaze',
      fullName: 'Grace Delfin',
      contactNumber: '09654321789',
      email: 'sarah.delgado@outlook.com',
      address: '654 Smash Avenue, Taguig City, Philippines',
      remarks: 'Beginner friendly, learning fast, needs equipment recommendations',
      badmintonLevelMin: 0.0, // Beginners (Weak)
      badmintonLevelMax: 2.0, // Beginners (Strong)
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    ProfileItem(
      id: 'dummy_player_006',
      nickname: 'Viper',
      fullName: 'Carlos Fernandez',
      contactNumber: '09789456123',
      email: 'carlos.fernandez@gmail.com',
      address: '987 Court Side Plaza, Cebu City, Philippines',
      remarks: 'Professional player, tournament winner, available for coaching',
      badmintonLevelMin: 18.0, // Open Player (Weak)
      badmintonLevelMax: 20.0, // Open Player (Strong)
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];
}
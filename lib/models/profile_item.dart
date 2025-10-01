import 'package:flutter/foundation.dart';

@immutable
class ProfileItem {
  const ProfileItem({
    required this.id,
    required this.nickname,
    required this.fullName,
    required this.contactNumber,
    required this.email,
    required this.address,
    required this.remarks,
    required this.createdAt,
  });

  final String id;
  final String nickname;
  final String fullName;
  final String contactNumber;
  final String email;
  final String address;
  final String remarks;
  final DateTime createdAt;
}

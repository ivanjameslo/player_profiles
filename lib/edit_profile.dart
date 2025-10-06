import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/profile_item.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({
    super.key,
    required this.profile,
    required this.onUpdateProfile,
    required this.onDeleteProfile,
  });

  final ProfileItem profile;
  final void Function(ProfileItem oldProfile, ProfileItem updatedProfile) onUpdateProfile;
  final void Function(ProfileItem profile) onDeleteProfile;

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameController;
  late final TextEditingController _fullNameController;
  late final TextEditingController _contactController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _remarksController;

  // Badminton level slider values
  late RangeValues _badmintonLevelRange;

  // Badminton levels with their respective labels
  final List<String> _badmintonLevels = [
    'Beginners',
    'Intermediate', 
    'Level G',
    'Level F',
    'Level E',
    'Level D',
    'Open Player'
  ];

  final List<String> _subLevels = ['Weak', 'Mid', 'Strong'];

  @override
  void initState() {
    super.initState();
    // Pre-fill controllers with existing data
    _nicknameController = TextEditingController(text: widget.profile.nickname);
    _fullNameController = TextEditingController(text: widget.profile.fullName);
    _contactController = TextEditingController(text: widget.profile.contactNumber);
    _emailController = TextEditingController(text: widget.profile.email);
    _addressController = TextEditingController(text: widget.profile.address);
    _remarksController = TextEditingController(text: widget.profile.remarks);
    
    // Set badminton level range to current values
    _badmintonLevelRange = RangeValues(
      widget.profile.badmintonLevelMin,
      widget.profile.badmintonLevelMax,
    );
  }

  String _getBadmintonLevelLabel(double value) {
    int levelIndex = (value / 3).floor();
    int subLevelIndex = (value % 3).floor();

    if (levelIndex >= _badmintonLevels.length) {
      levelIndex = _badmintonLevels.length - 1;
      subLevelIndex = 2; // Strong
    }

    return '${_badmintonLevels[levelIndex]} (${_subLevels[subLevelIndex]})';
  }

  void _updateProfileData() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedProfile = ProfileItem(
      id: widget.profile.id, // Keep the same ID
      nickname: _nicknameController.text.trim(),
      fullName: _fullNameController.text.trim(),
      contactNumber: _contactController.text.trim(),
      email: _emailController.text.trim(),
      address: _addressController.text.trim(),
      remarks: _remarksController.text.trim(),
      badmintonLevelMin: _badmintonLevelRange.start,
      badmintonLevelMax: _badmintonLevelRange.end,
      createdAt: widget.profile.createdAt, // Keep original creation date
    );

    widget.onUpdateProfile(widget.profile, updatedProfile);
    Navigator.pop(context);
  }

  Future<void> _confirmDelete() async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Player'),
          content: Text(
            'Are you sure you want to permanently delete ${widget.profile.nickname} (${widget.profile.fullName})?\\n\\nThis action cannot be undone.',
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
      widget.onDeleteProfile(widget.profile);
      Navigator.pop(context); // Close the edit screen
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _fullNameController.dispose();
    _contactController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Player Profile'),
        backgroundColor: const Color(0xFF214D45),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
            tooltip: 'Delete Player',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, keyboardSpace + 16),
          child: Column(
            children: [
              // Nickname input
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Nickname',
                  hintText: 'Enter player nickname',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a nickname';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Full Name input
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter full name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Contact Number input
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\+?[0-9]*')),
                  LengthLimitingTextInputFormatter(13), // +63 + 10 digits
                ],
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  hintText: 'Enter phone number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter contact number';
                  }
                  
                  final cleanValue = value.trim();
                  
                  // Check for +63 format (should be +63 followed by 10 digits)
                  if (cleanValue.startsWith('+63')) {
                    if (!RegExp(r'^\+639[0-9]{9}$').hasMatch(cleanValue)) {
                      return 'Format: +639XXXXXXXXX (10 digits after +63)';
                    }
                  }
                  // Check for 09 format (should be 11 digits starting with 09)
                  else if (cleanValue.startsWith('09')) {
                    if (!RegExp(r'^09[0-9]{9}$').hasMatch(cleanValue)) {
                      return 'Format: 09XXXXXXXXX (11 digits total)';
                    }
                  }
                  else {
                    return 'Phone must start with 09 or +639';
                  }
                  
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Email input
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter email address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  prefixIcon: Icon(Icons.email),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter email address';
                  }
                  if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Address input
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'Enter address (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  prefixIcon: Icon(Icons.location_on),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 16),
              
              // Remarks input
              TextFormField(
                controller: _remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks',
                  hintText: 'Additional notes (optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  prefixIcon: Icon(Icons.note),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 24),
              
              // Badminton Level Slider
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Badminton Level Range',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'From: ${_getBadmintonLevelLabel(_badmintonLevelRange.start)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'To: ${_getBadmintonLevelLabel(_badmintonLevelRange.end)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    RangeSlider(
                      values: _badmintonLevelRange,
                      min: 0,
                      max: 20, // 7 levels × 3 sub-levels - 1
                      divisions: 20,
                      activeColor: const Color(0xFF214D45),
                      inactiveColor: Colors.grey.shade300,
                      onChanged: (RangeValues values) {
                        setState(() {
                          _badmintonLevelRange = values;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    // Level indicators
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Beginners',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Intermediate',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Level G',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Level F',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Level E',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Level D',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Open Player',
                              textAlign: TextAlign.end,
                              style: TextStyle(
                                fontSize: 8,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _updateProfileData();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF214D45),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Update Player'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
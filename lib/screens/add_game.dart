import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/court_schedule.dart';
import '../models/game.dart';
import '../models/profile_item.dart';
import '../services/app_prefs.dart';
import '../services/player_store.dart';
import '../services/game_store.dart';

class AddGameScreen extends StatefulWidget {
  const AddGameScreen({
    super.key,
    this.onSaved,
    this.initialGame,
  });

  final ValueChanged<Game>? onSaved;
  final Game? initialGame;
  @override
  State<AddGameScreen> createState() => _AddGameScreenState();
}

class _AddGameScreenState extends State<AddGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _courtNameController = TextEditingController();
  final _courtRateController = TextEditingController();
  final _shuttleCockPriceController = TextEditingController();
  bool _divideCourtEqually = true;
  String? _shuttleAccidentPlayerId;
  final List<CourtSchedule> _schedules = [];
  final List<ProfileItem> _selectedPlayers = [];
  late final PlayerStore _playerStore;
  late final GameStore _gameStore;

  List<ProfileItem> get _availablePlayers => _playerStore.players;

  bool get _hasReachedPlayerLimit => _selectedPlayers.length >= 4;
  int get _playerShareCount =>
      _selectedPlayers.isEmpty ? 1 : _selectedPlayers.length;
  String? get _validChargePlayerId {
    if (_shuttleAccidentPlayerId == null) return null;
    final exists = _selectedPlayers.any((p) => p.id == _shuttleAccidentPlayerId);
    return exists ? _shuttleAccidentPlayerId : null;
  }
  String get _shuttleHelperText {
    if (_selectedPlayers.isEmpty) {
      return 'Select players to split the shuttlecock cost';
    }
    final chargeId = _validChargePlayerId;
    if (chargeId == null) {
      return 'Shuttlecock cost splits among $_playerShareCount player(s)';
    }
    ProfileItem? chargedPlayer;
    for (final player in _selectedPlayers) {
      if (player.id == chargeId) {
        chargedPlayer = player;
        break;
      }
    }
    final name = chargedPlayer?.nickname ?? 'Selected player';
    return '$name will shoulder the full shuttlecock cost';
  }

  void _handlePlayerSelection(ProfileItem player, bool shouldSelect) {
    final alreadySelected =
        _selectedPlayers.any((element) => element.id == player.id);

    if (shouldSelect && alreadySelected) return;

    if (shouldSelect && _hasReachedPlayerLimit) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can only select up to 4 players.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      if (shouldSelect) {
        _selectedPlayers.add(player);
      } else {
        _selectedPlayers.removeWhere((p) => p.id == player.id);
        if (_shuttleAccidentPlayerId == player.id) {
          _shuttleAccidentPlayerId = null;
        }
      }
    });
  }
  
  @override
  void initState() {
    super.initState();
    _playerStore = PlayerStore();
    _gameStore = GameStore();
    _playerStore.addListener(_handlePlayerStoreChange);
    if (widget.initialGame != null) {
      _populateFromGame(widget.initialGame!);
    } else {
      _loadDefaultValues();
    }
  }

  void _handlePlayerStoreChange() {
    if (!mounted) return;
    final availableIds = _playerStore.players.map((p) => p.id).toSet();
    setState(() {
      _selectedPlayers.removeWhere((p) => !availableIds.contains(p.id));
      if (_shuttleAccidentPlayerId != null &&
          !availableIds.contains(_shuttleAccidentPlayerId)) {
        _shuttleAccidentPlayerId = null;
      }
    });
  }

  void _populateFromGame(Game game) {
    _titleController.text = game.title ?? '';
    _courtNameController.text = game.courtName;
    _courtRateController.text = game.courtRate.toStringAsFixed(2);
    _shuttleCockPriceController.text = game.shuttleCockPrice.toStringAsFixed(2);
    _divideCourtEqually = game.divideCostEqually;
    _shuttleAccidentPlayerId = game.shuttlecockChargedPlayerId;
    _selectedPlayers
      ..clear()
      ..addAll(game.players);
    _schedules
      ..clear()
      ..addAll(
        game.schedules.map(
          (schedule) => CourtSchedule(
            courtNumber: schedule.courtNumber,
            startTime: schedule.startTime,
            endTime: schedule.endTime,
          ),
        ),
      );
  }

  Future<void> _loadDefaultValues() async {
    final d = await AppPrefs.loadDefaults();
    if (!mounted) return;
    setState(() {
      _courtNameController.text         = d.courtName;
      _courtRateController.text         = d.courtRate.toStringAsFixed(0);   // or 2 decimals if you like
      _shuttleCockPriceController.text  = d.shuttlecockPrice.toStringAsFixed(0);
      _divideCourtEqually               = d.divideEqually;
      _shuttleAccidentPlayerId          = null;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _courtNameController.dispose();
    _courtRateController.dispose();
    _shuttleCockPriceController.dispose();
    _playerStore.removeListener(_handlePlayerStoreChange);
    super.dispose();
  }

  Future<void> _selectSchedule(BuildContext context) async {
    // First, pick a date
    final today = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(2030),
    );
    if (!mounted || selectedDate == null) return;

    // Then pick start time
    final startTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (!mounted || startTime == null) return;

    // Then pick end time
    final endTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: (startTime.hour + 1) % 24,
        minute: startTime.minute,
      ),
    );
    if (!mounted || endTime == null) return;

    // Ask for court number
    final courtNumber = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Enter Court Number'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Court Number',
              hintText: 'e.g., Court 1',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(controller.text),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    if (!mounted || courtNumber == null || courtNumber.isEmpty) return;

    // Combine date and time
    final startDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      startTime.hour,
      startTime.minute,
    );

    final endDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      endTime.hour,
      endTime.minute,
    );

    // --- ✅ VALIDATION: Prevent overlapping times for the same court only ---
    final hasOverlap = _schedules.any((existing) {
      if (existing.courtNumber != courtNumber) return false; // different court is fine
      final existingStart = existing.startTime;
      final existingEnd = existing.endTime;

      // Check time overlap
      final overlaps = startDateTime.isBefore(existingEnd) &&
                      endDateTime.isAfter(existingStart);
      return overlaps;
    });

    if (hasOverlap) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Overlapping schedule detected for $courtNumber.\nPlease adjust the time or choose a different court.',
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return; // 🚫 Don't add duplicate overlapping schedules for same court
    }

    // --- ✅ Otherwise, add schedule ---
    setState(() {
      _schedules.add(
        CourtSchedule(
          courtNumber: courtNumber,
          startTime: startDateTime,
          endTime: endDateTime,
        ),
      );
    });
  }

  void _removeSchedule(int index) {
    setState(() {
      _schedules.removeAt(index);
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, y - hh:mm a').format(dateTime);
  }

  Future<void> _saveGame() async {
      if (_formKey.currentState!.validate()) {
        if (_schedules.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please add at least one court schedule'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
        if (_selectedPlayers.isEmpty) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select at least one player'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final now = DateTime.now();
        final existingGame = widget.initialGame;
        final chargePlayerId = _validChargePlayerId;
        final newGame = Game(
          id: existingGame?.id ?? now.millisecondsSinceEpoch.toString(),
          title: _titleController.text.trim().isEmpty
              ? null
              : _titleController.text.trim(),
          courtName: _courtNameController.text.trim(),
          courtRate: double.tryParse(_courtRateController.text.trim()) ?? 0,
          shuttleCockPrice: double.tryParse(_shuttleCockPriceController.text.trim()) ?? 0,
          divideCostEqually: _divideCourtEqually,
          shuttlecockChargedPlayerId: chargePlayerId,
          schedules: List.from(_schedules),
          createdAt: existingGame?.createdAt ?? now,
          players: List.unmodifiable(_selectedPlayers),
        );

        // --- ✅ GLOBAL VALIDATION: Prevent overlapping games on same court ---
        final conflict = _gameStore.findConflict(
          newGame,
          excludeGameId: existingGame?.id,
        );

        if (conflict != null) {
          final dateFormat = DateFormat('MMM d, y h:mm a');
          final message =
              'Court ${conflict.newSchedule.courtNumber} is already booked '
              'from ${dateFormat.format(conflict.existingSchedule.startTime)} '
              'to ${dateFormat.format(conflict.existingSchedule.endTime)} '
              '(${conflict.existingGame.displayTitle}).';

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
          return; // 🚫 stop saving the game
        }

        final isEditing = existingGame != null;

      // Debug
      print('✅ ${isEditing ? 'EDIT' : 'ADD'}: saving Game ${newGame.id}  title=${newGame.displayTitle}  cost=${newGame.totalCost}  schedules=${newGame.schedules.length}  players=${newGame.playerCount}');
      print('🔍 onSaved callback exists: ${widget.onSaved != null}');

      // Check if we're in tab navigation or pushed navigation
      final canPop = Navigator.of(context).canPop();
      print('🔍 Can pop: $canPop');

        // Always call the callback (legacy flows toggle tabs)
        if (widget.onSaved != null) {
          print('📤 Calling onSaved callback...');
          widget.onSaved!(newGame);
        }

      if (canPop) {
        print('⬅️ Popping and returning game...');
        Navigator.of(context).pop(newGame);
        return;
      }
      if (isEditing) {
        print('⚠️ Editing without navigation stack, attempting maybePop...');
        await Navigator.of(context).maybePop(newGame);
        return;
      }

      // We're in tab navigation, clear the form and show success
      print('🎯 In tab navigation, clearing form...');
      _titleController.clear();
      _courtNameController.clear();
      setState(() {
        _schedules.clear();
        _selectedPlayers.clear();
      });
      
      // Reload defaults
      await _loadDefaultValues();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Game saved successfully! Check the Games tab.'),
          backgroundColor: Color(0xFF214D45),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          widget.initialGame == null ? 'Add New Game' : 'Edit Game',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF214D45),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, MediaQuery.of(context).viewInsets.bottom + 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Game Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF214D45),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Game Title (Optional)',
                        hintText: 'Leave blank to use scheduled date',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _courtNameController,
                      decoration: const InputDecoration(
                        labelText: 'Court Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        prefixIcon: Icon(Icons.sports_tennis),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter court name';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Players',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF214D45),
                          ),
                        ),
                        Text(
                          '${_selectedPlayers.length}/4 selected',
                          style: TextStyle(
                            color: _hasReachedPlayerLimit
                                ? Colors.red
                                : Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pick up to four players from your profile list to split the game cost.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_availablePlayers.isEmpty)
                      Center(
                        child: Text(
                          'No players available. Add players first in the Players tab.',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                    else
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _availablePlayers.map((player) {
                          final isSelected = _selectedPlayers
                              .any((element) => element.id == player.id);
                          return FilterChip(
                            avatar: CircleAvatar(
                              backgroundColor: isSelected
                                  ? Colors.white24
                                  : const Color(0xFF214D45).withOpacity(0.1),
                              child: Text(
                                player.nickname.isNotEmpty
                                    ? player.nickname[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF214D45),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            label: SizedBox(
                              width: 120,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    player.nickname,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF214D45),
                                    ),
                                  ),
                                  Text(
                                    player.fullName,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isSelected
                                          ? Colors.white70
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) =>
                                _handlePlayerSelection(player, selected),
                            selectedColor: const Color(0xFF214D45),
                            backgroundColor: Colors.grey.shade200,
                            showCheckmark: false,
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Court Schedules Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Court Schedules',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF214D45),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _selectSchedule(context),
                          icon: const Icon(Icons.add_circle),
                          color: const Color(0xFF214D45),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_schedules.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No schedules added yet',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _schedules.length,
                        itemBuilder: (context, index) {
                          final schedule = _schedules[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(schedule.courtNumber),
                              subtitle: Text(
                                '${_formatDateTime(schedule.startTime)}\n${_formatDateTime(schedule.endTime)}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _removeSchedule(index),
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pricing Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pricing Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF214D45),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _courtRateController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Court Rate (per hour)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter court rate';
                        }
                        final rate = double.tryParse(value);
                        if (rate == null || rate <= 0) {
                          return 'Please enter a valid rate';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _shuttleCockPriceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Shuttlecock Price (Total)',
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        prefixIcon: const Icon(Icons.sports_baseball),
                        helperText: _shuttleHelperText,
                        helperStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter shuttlecock price';
                        }
                        final price = double.tryParse(value);
                        if (price == null || price <= 0) {
                          return 'Please enter a valid price';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Divide court rate equally among players'),
                      value: _divideCourtEqually,
                      onChanged: (bool value) {
                        setState(() {
                          _divideCourtEqually = value;
                        });
                      },
                      activeColor: const Color(0xFF214D45),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String?>(
                      value: _validChargePlayerId,
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Divide shuttlecock equally'),
                        ),
                        ..._selectedPlayers.map(
                          (player) => DropdownMenuItem<String?>(
                            value: player.id,
                            child: Text('Charge ${player.nickname}'),
                          ),
                        ),
                      ],
                      onChanged: _selectedPlayers.isEmpty
                          ? null
                          : (value) {
                              setState(() {
                                _shuttleAccidentPlayerId = value;
                              });
                            },
                      decoration: const InputDecoration(
                        labelText: 'Shuttlecock Incident',
                        helperText:
                            'Choose who covers the shuttlecock if it is damaged',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
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
                      onPressed: _saveGame,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF214D45),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(widget.initialGame == null ? 'Save Game' : 'Update Game'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

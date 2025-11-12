import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import '../data/dummy_games.dart';
import '../models/game.dart';
import 'add_game.dart';
import '../services/game_store.dart';


class GameListScreen extends StatefulWidget {
  const GameListScreen({super.key});

  @override
  GameListScreenState createState() => GameListScreenState();
}

class GameListScreenState extends State<GameListScreen> {
  final GameStore _gameStore = GameStore();
  List<Game> get _games => _gameStore.games;
  final TextEditingController _searchController = TextEditingController();
  List<Game> _filteredGames = [];
  final currencyFormat = NumberFormat.currency(
    symbol: '₱',
    decimalDigits: 2,
  );
  String _safeCurrency(double v) =>
    (!v.isFinite || v.isNaN) ? '₱0.00' : currencyFormat.format(v);

  void _refreshFilteredGames() {
    final query = _searchController.text.toLowerCase();
    _filteredGames = query.isEmpty
        ? List.from(_games)
        : _games.where((game) {
            return game.displayTitle.toLowerCase().contains(query) ||
                game.courtName.toLowerCase().contains(query);
          }).toList();
  }

  void addGame(Game g) {
    setState(() {
      _gameStore.upsertGame(g);
      _refreshFilteredGames();
    });
  }

  @override
  void initState() {
    super.initState();
    _filteredGames = List.from(_games);
    _searchController.addListener(_filterGames);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterGames() {
    setState(() {
      _refreshFilteredGames();
    });
  }

  String _formatFirstSchedule(Game game) {
    final schedules = game.schedules;
    if (schedules.isEmpty) return 'No schedule';
    final dateFormat = DateFormat('MMM d, y');
    final timeFormat = DateFormat('h:mm a');
    final s = schedules.first;
    return '${dateFormat.format(s.startTime)} at ${timeFormat.format(s.startTime)}';
  }


  Future<void> _confirmDelete(Game game) async {
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Game'),
          content: Text(
            'Are you sure you want to delete "${game.displayTitle}"?\n\nThis action cannot be undone.',
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
      setState(() {
        _gameStore.removeGame(game.id);
        _refreshFilteredGames();
      });
    }
  }

  Future<void> _viewGameDetails(Game game) async {
    final shouldEdit = await showModalBottomSheet<bool>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final dateFormat = DateFormat('MMM d, y');
        final timeFormat = DateFormat('h:mm a');

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                game.displayTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF214D45),
                ),
              ),
              const SizedBox(height: 16),

              _buildDetailRow('Court Name', game.courtName),

              const SizedBox(height: 12),
                  const Text(
                    'Computation',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF214D45),
                    ),
                  ),
                  const SizedBox(height: 6),

              // ✅ Compute total hours played across all schedules
              Builder(
                builder: (context) {
                  double totalHours = 0.0;
                  for (final s in game.schedules) {
                    final minutes = s.endTime.difference(s.startTime).inMinutes;
                    if (minutes > 0) totalHours += minutes / 60.0;
                  }

                  final courtTotal = game.courtRate * totalHours;
                  final total = game.totalGameCost;

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Court Rate (₱${game.courtRate.toStringAsFixed(0)} × ${totalHours.toStringAsFixed(1)} hrs):',
                          ),
                          Text('₱${courtTotal.toStringAsFixed(2)}'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Shuttlecock:'),
                          Text('₱${game.shuttleCockPrice.toStringAsFixed(2)}'),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          game.shuttlecockChargedPlayer != null
                              ? 'Charged to ${game.shuttlecockChargedPlayer!.nickname}'
                              : 'Divided among ${game.playerCount} player(s)',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '₱${total.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            game.divideCostEqually
                                ? 'Total per Player'
                                : 'Total Game Cost',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF214D45),
                            ),
                          ),
                          Text(
                            currencyFormat.format(game.totalCost),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF214D45),
                            ),
                          ),
                        ],
                      ),
                      if (game.divideCostEqually &&
                          game.shuttlecockChargedPlayer != null) ...[
                        const SizedBox(height: 4),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${game.shuttlecockChargedPlayer!.nickname} pays '
                            '${currencyFormat.format(game.costForPlayer(game.shuttlecockChargedPlayer!))}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.redAccent.shade200,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              
              const Text(
                'Schedules',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: game.schedules.map((s) {
                  final date = dateFormat.format(s.startTime);
                  final start = timeFormat.format(s.startTime);
                  final end = timeFormat.format(s.endTime);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.schedule, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Court ${s.courtNumber} • $date $start - $end',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            if (game.players.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Players',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
            ...game.players.map(
              (player) {
                final bool isCourtPayer = game.isCourtCostPayer(player);
                final bool isShuttlePayer = game.isChargedForShuttlecock(player);
                final bool splitsShuttleOnly = !game.divideCostEqually &&
                    game.shuttlecockChargedPlayer == null &&
                    game.shuttleCockPrice > 0;
                final double shuttleShare = splitsShuttleOnly
                    ? game.shuttleShareForPlayer(player)
                    : 0.0;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor:
                        const Color(0xFF214D45).withOpacity(0.1),
                    child: Text(
                      player.nickname.isNotEmpty
                          ? player.nickname[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Color(0xFF214D45),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    player.nickname,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        player.fullName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (game.divideCostEqually) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Share: ${_safeCurrency(game.costForPlayer(player))}'
                          '${isShuttlePayer ? ' (shuttle incident)' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isShuttlePayer
                                ? Colors.redAccent
                                : Colors.grey.shade700,
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 4),
                        if (isCourtPayer || isShuttlePayer)
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              if (isCourtPayer)
                                _buildTag(
                                  'Pays full court rate',
                                  background: Colors.orange.shade50,
                                  foreground: Colors.orange.shade700,
                                ),
                              if (isShuttlePayer)
                                _buildTag(
                                  'Pays shuttlecock',
                                  background: Colors.red.shade50,
                                  foreground: Colors.red.shade700,
                                ),
                            ],
                          ),
                        if (!isShuttlePayer &&
                            splitsShuttleOnly &&
                            shuttleShare > 0)
                          Text(
                            'Shuttle share: ${_safeCurrency(shuttleShare)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                      ],
                    ],
                  ),
                );
              },
            ),
            ] else ...[
              const SizedBox(height: 16),
              Text(
                'No players added yet',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context, false),
                    icon: const Icon(Icons.close),
                    label: const Text('Close'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF214D45),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            ],
          ),
        );
      },
    );

    if (!mounted || shouldEdit != true) return;
    await _editGame(game);
  }

  Future<void> _editGame(Game game) async {
    final updatedGame = await Navigator.of(context).push<Game>(
      MaterialPageRoute(
        builder: (_) => AddGameScreen(initialGame: game),
        fullscreenDialog: true,
      ),
    );

    if (!mounted || updatedGame == null) return;

    setState(() {
      _gameStore.upsertGame(updatedGame);
      _refreshFilteredGames();
    });


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Game updated'),
        backgroundColor: Color(0xFF214D45),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'All Games',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF214D45),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search games...',
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
          ),
          Expanded(
            child: _games.isEmpty
                ? const Center(
                    child: Text(
                      'No games added yet.\nTap the + button to add a game.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : _filteredGames.isEmpty
                    ? const Center(
                        child: Text(
                          'No games found.\nTry a different search term.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredGames.length,
                        itemBuilder: (context, index) {
                          try {
                          final game = _filteredGames[index];
                          return Dismissible(
                            key: Key(game.id),
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
                              await _confirmDelete(game);
                              return false; // We handle deletion in confirmDelete
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                onTap: () => _viewGameDetails(game),
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  game.displayTitle,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  game.courtName,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF214D45),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              '${game.playerCount} Players',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _formatFirstSchedule(game),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Builder(
                                            builder: (_) {
                                              final chargedPlayer = game.divideCostEqually
                                                  ? game.shuttlecockChargedPlayer
                                                  : null;
                                              final chargedShare = chargedPlayer != null
                                                  ? _safeCurrency(game.costForPlayer(chargedPlayer))
                                                  : null;
                                              return RichText(
                                                text: TextSpan(
                                                  children: [
                                                    TextSpan(
                                                      text: _safeCurrency(game.totalCost),
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Color(0xFF214D45),
                                                      ),
                                                    ),
                                                    if (game.divideCostEqually) ...[
                                                      const TextSpan(
                                                        text: ' per player',
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.grey,
                                                          fontWeight: FontWeight.w400,
                                                        ),
                                                      ),
                                                    ],
                                                    if (chargedPlayer != null && chargedShare != null) ...[
                                                      TextSpan(
                                                        text: '\n${chargedPlayer.nickname}: $chargedShare',
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.redAccent,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      if (game.schedules.length > 1) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          '+${game.schedules.length - 1} more schedule(s)',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                          } catch (e, st) {
                            // ignore: avoid_print
                            print('❌ itemBuilder error at index $index: $e\n$st');
                            return Card(
                              color: Colors.red.shade50,
                              child: ListTile(
                                title: const Text('Failed to render game'),
                                subtitle: Text('$e'),
                              ),
                            );
                          }
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Push AddGameScreen and WAIT for the Game to be returned
          final newGame = await Navigator.of(context).push<Game>(
            MaterialPageRoute(
              builder: (_) => const AddGameScreen(),
              fullscreenDialog: true,
            ),
          );

          // Debug: prove we got back to this screen
          // ignore: avoid_print
          print('⬅️ GameList: received from AddGame => $newGame');

          if (!mounted || newGame == null) return;

          setState(() {
            _gameStore.upsertGame(newGame);
            _refreshFilteredGames();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Game added'),
              backgroundColor: Color(0xFF214D45),
            ),
          );
        },
        backgroundColor: const Color(0xFF214D45),
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),

    );
  }
  Widget _buildTag(String text,
      {Color? background, Color? foreground}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background ?? Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: foreground ?? Colors.orange.shade700,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
}

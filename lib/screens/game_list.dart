import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../data/dummy_games.dart';
import '../models/game.dart';
import 'add_game.dart';

class GameListScreen extends StatefulWidget {
  const GameListScreen({super.key});

  @override
  State<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  final List<Game> _games = List.from(DummyGames.games);
  final TextEditingController _searchController = TextEditingController();
  List<Game> _filteredGames = [];
  final currencyFormat = NumberFormat.currency(
    symbol: '₱',
    decimalDigits: 2,
  );
  String _safeCurrency(double v) =>
    (!v.isFinite || v.isNaN) ? '₱0.00' : currencyFormat.format(v);

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
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredGames = List.from(_games);
      } else {
        _filteredGames = _games.where((game) {
          return game.displayTitle.toLowerCase().contains(query) ||
              game.courtName.toLowerCase().contains(query);
        }).toList();
      }
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
        _games.remove(game);
        _filterGames();
      });
    }
  }

  void _viewGameDetails(Game game) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    backgroundColor: Colors.white,
    isScrollControlled: true,
    builder: (BuildContext context) {
      final dateFormat = DateFormat('MMM d, y');
      final timeFormat = DateFormat('h:mm a');
      final schedules = game.schedules.map((s) {
        return '${dateFormat.format(s.startTime)} '
               '${timeFormat.format(s.startTime)} - '
               '${timeFormat.format(s.endTime)}';
      }).toList();

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
            // _buildDetailRow('Players', '${game.numberOfPlayers}'),
            _buildDetailRow('Total Cost', currencyFormat.format(game.totalCost)),
            const SizedBox(height: 12),

            const Text(
              'Schedules',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),

            ...schedules.map(
              (s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.schedule, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(s, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Close'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF214D45),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
    },
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
                                          // Container(
                                          //   padding: const EdgeInsets.symmetric(
                                          //     horizontal: 12,
                                          //     vertical: 6,
                                          //   ),
                                          //   decoration: BoxDecoration(
                                          //     color: const Color(0xFF214D45),
                                          //     borderRadius: BorderRadius.circular(20),
                                          //   ),
                                          //   child: Text(
                                          //     '${game.numberOfPlayers} Players',
                                          //     style: const TextStyle(
                                          //       color: Colors.white,
                                          //       fontSize: 12,
                                          //       fontWeight: FontWeight.w500,
                                          //     ),
                                          //   ),
                                          // ),
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
                                          Text(
                                            _safeCurrency(game.totalCost),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF214D45),
                                            ),
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
            _games.add(newGame);

            final q = _searchController.text.toLowerCase();
            _filteredGames = q.isEmpty
                ? List.from(_games)
                : _games.where((g) =>
                    g.displayTitle.toLowerCase().contains(q) ||
                    g.courtName.toLowerCase().contains(q),
                  ).toList();
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
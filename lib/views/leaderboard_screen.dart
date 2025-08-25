import 'package:flutter/material.dart';
import '../services/leaderboard_service.dart';

class LeaderboardScreen extends StatelessWidget {
  final LeaderboardService service;
  const LeaderboardScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          '🏆 LEADERBOARD',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.tertiary,
            shadows: [
              Shadow(
                offset: const Offset(0, 2),
                blurRadius: 4,
                color: Colors.black.withOpacity(0.5),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<List<Map<String, dynamic>>>(
            stream: service.topScoresStream(),
            builder: (context, snapshot) {
              final data = snapshot.data ?? [];
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading Champions...',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }
              if (data.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 80,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Champions Yet',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Be the first to claim glory!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildPodium(data),
                    const SizedBox(height: 24),
                    Expanded(child: _buildLeaderboardList(data)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPodium(List<Map<String, dynamic>> data) {
    if (data.length < 3) return const SizedBox.shrink();

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (data.length > 1) _buildPodiumPlace(data[1], 2, 140),
          if (data.isNotEmpty) _buildPodiumPlace(data[0], 1, 180),
          if (data.length > 2) _buildPodiumPlace(data[2], 3, 120),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(
    Map<String, dynamic> player,
    int place,
    double height,
  ) {
    final uid = player['uid'] as String? ?? 'unknown';
    final best = player['best'] as int? ?? 0;
    final short = uid.length >= 6 ? uid.substring(0, 6) : uid;

    Color color;
    IconData icon;
    switch (place) {
      case 1:
        color = const Color(0xFFFFD700); // Gold
        icon = Icons.looks_one;
        break;
      case 2:
        color = const Color(0xFFC0C0C0); // Silver
        icon = Icons.looks_two;
        break;
      case 3:
        color = const Color(0xFFCD7F32); // Bronze
        icon = Icons.looks_3;
        break;
      default:
        color = Colors.grey;
        icon = Icons.person;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.black, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          short,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        Text(
          '$best',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withOpacity(0.8), color.withOpacity(0.4)],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border.all(color: color, width: 2),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardList(List<Map<String, dynamic>> data) {
    return ListView.builder(
      itemCount: data.length,
      itemBuilder: (context, index) {
        final row = data[index];
        final uid = row['uid'] as String? ?? 'unknown';
        final best = row['best'] as int? ?? 0;
        final short = uid.length >= 6 ? uid.substring(0, 6) : uid;
        final name = 'Player $short';

        final isTop3 = index < 3;

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isTop3
                  ? [
                      Theme.of(context).colorScheme.tertiary.withOpacity(0.2),
                      Theme.of(context).colorScheme.tertiary.withOpacity(0.05),
                    ]
                  : [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.01),
                    ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isTop3
                  ? Theme.of(context).colorScheme.tertiary.withOpacity(0.3)
                  : Colors.white.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: isTop3
                      ? [
                          Theme.of(context).colorScheme.tertiary,
                          Theme.of(
                            context,
                          ).colorScheme.tertiary.withOpacity(0.7),
                        ]
                      : [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                        ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: isTop3 ? Colors.black : Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            title: Text(
              name,
              style: TextStyle(
                color: isTop3
                    ? Theme.of(context).colorScheme.tertiary
                    : Colors.white,
                fontWeight: isTop3 ? FontWeight.bold : FontWeight.w500,
                fontSize: 16,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isTop3
                    ? Theme.of(context).colorScheme.tertiary.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$best',
                style: TextStyle(
                  color: isTop3
                      ? Theme.of(context).colorScheme.tertiary
                      : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

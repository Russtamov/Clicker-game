import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ads_service.dart';
import '../services/leaderboard_service.dart';
import '../viewmodels/game_view_model.dart';
import 'game_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AdsService _adsService = AdsService();
  final LeaderboardService _leaderboardService = LeaderboardService();
  late final GameViewModel _gameViewModel = GameViewModel(
    leaderboardService: _leaderboardService,
  );
  BannerAd? _banner;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _leaderboardService.tryInitialize();
    await _adsService.initialize();
    if (!mounted) return;
    setState(() {});
    _banner = await _adsService.loadBanner(() {
      if (mounted) setState(() {});
    });
    await _adsService.loadRewarded();
  }

  @override
  void dispose() {
    _adsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'TARGET CLICKER',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            shadows: [
              Shadow(
                offset: const Offset(0, 2),
                blurRadius: 4,
                color: Colors.black.withOpacity(0.5),
              ),
            ],
          ),
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
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildGameTitle(),
                        const SizedBox(height: 48),
                        _buildPlayButton(),
                        const SizedBox(height: 20),
                        _buildLeaderboardButton(),
                        const SizedBox(height: 20),
                        _buildAdButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _buildBannerAd(),
          ],
        ),
      ),
    );
  }

  Widget _buildGameTitle() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.3),
                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(Icons.gps_fixed, size: 80, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Text(
          'CLICKER ARENA',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
            shadows: [
              Shadow(
                offset: const Offset(0, 4),
                blurRadius: 8,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap, Aim, Conquer!',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _onPlayPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow, size: 32, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'START GAME',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.tertiary,
          width: 2,
        ),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
            Theme.of(context).colorScheme.tertiary.withOpacity(0.05),
          ],
        ),
      ),
      child: ElevatedButton(
        onPressed: _onLeaderboardPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            const SizedBox(width: 12),
            Text(
              'LEADERBOARD',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.tertiary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
          width: 2,
        ),
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            Theme.of(context).colorScheme.secondary.withOpacity(0.05),
          ],
        ),
      ),
      child: ElevatedButton(
        onPressed: _onWatchAdPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 12),
            Text(
              'BONUS REWARD',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.secondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerAd() {
    if (_banner == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: _banner!.size.height.toDouble(),
          width: _banner!.size.width.toDouble(),
          child: AdWidget(ad: _banner!),
        ),
      ),
    );
  }

  Future<void> _onPlayPressed() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GameScreen(viewModel: _gameViewModel)),
    );
    await _gameViewModel.submitScore();
  }

  void _onLeaderboardPressed() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LeaderboardScreen(service: _leaderboardService),
      ),
    );
  }

  Future<void> _onWatchAdPressed() async {
    await _adsService.showRewarded(
      onEarned: () => _gameViewModel.applyRewardDouble(),
    );
  }
}

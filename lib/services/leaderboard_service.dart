import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class LeaderboardService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _available = false;

  // Fallback in-memory board when Firebase isn't configured
  static final List<Map<String, dynamic>> _local = [];

  Future<void> tryInitialize() async {
    try {
      await Firebase.initializeApp();
      await ensureSignedIn();
      _available = true;
    } catch (_) {
      _available = false;
    }
  }

  Future<User> ensureSignedIn() async {
    final current = _auth.currentUser;
    if (current != null) return current;
    final cred = await _auth.signInAnonymously();
    return cred.user!;
  }

  Future<void> submitBestScore(int score) async {
    if (!_available) {
      _local.add({
        'uid': 'local-${DateTime.now().millisecondsSinceEpoch}',
        'best': score,
      });
      _local.sort((a, b) => (b['best'] as int).compareTo(a['best'] as int));
      if (_local.length > 10) _local.removeRange(10, _local.length);
      return;
    }
    final user = await ensureSignedIn();
    final doc = _firestore.collection('leaderboard').doc(user.uid);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(doc);
      final best = snap.exists ? (snap.data()!['best'] as int? ?? 0) : 0;
      if (score > best) {
        tx.set(doc, {
          'uid': user.uid,
          'best': score,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    });
  }

  Stream<List<Map<String, dynamic>>> topScoresStream() {
    if (!_available) {
      return Stream<List<Map<String, dynamic>>>.periodic(
        const Duration(milliseconds: 500),
        (_) => List<Map<String, dynamic>>.from(_local),
      );
    }
    return _firestore
        .collection('leaderboard')
        .orderBy('best', descending: true)
        .limit(10)
        .snapshots()
        .map((q) => q.docs.map((d) => d.data()).toList());
  }
}

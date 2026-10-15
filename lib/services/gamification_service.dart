import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/gamification_summary.dart';

class GamificationService {
  GamificationService(this._firestore);

  final FirebaseFirestore _firestore;

  Stream<GamificationSummary> watchSummary(String userId) => _firestore
      .collection('users')
      .doc(userId)
      .collection('gamification_events')
      .snapshots()
      .map(
        (snapshot) => GamificationSummary.fromEvents(
          snapshot.docs.map((document) => document.data()),
        ),
      );
}

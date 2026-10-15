import 'package:flutter_test/flutter_test.dart';
import 'package:petverse/models/gamification_summary.dart';

void main() {
  test('suma puntos y cuenta cada actividad registrada', () {
    final summary = GamificationSummary.fromEvents([
      {'activityType': 'post', 'points': 10},
      {'activityType': 'like', 'points': 1},
      {'activityType': 'comment', 'points': 3},
      {'activityType': 'comment', 'points': 3},
    ]);

    expect(summary.points, 17);
    expect(summary.posts, 1);
    expect(summary.likes, 1);
    expect(summary.comments, 2);
  });

  test('un perfil nuevo comienza sin puntos ni actividades', () {
    final summary = GamificationSummary.fromEvents(const []);

    expect(summary.points, 0);
    expect(summary.posts, 0);
    expect(summary.likes, 0);
    expect(summary.comments, 0);
  });
}

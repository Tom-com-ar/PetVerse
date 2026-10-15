class GamificationSummary {
  const GamificationSummary({
    required this.points,
    required this.posts,
    required this.likes,
    required this.comments,
  });

  const GamificationSummary.empty()
    : points = 0,
      posts = 0,
      likes = 0,
      comments = 0;

  final int points;
  final int posts;
  final int likes;
  final int comments;

  factory GamificationSummary.fromEvents(
    Iterable<Map<String, dynamic>> events,
  ) {
    var points = 0;
    var posts = 0;
    var likes = 0;
    var comments = 0;

    for (final event in events) {
      final activity = event['activityType'];
      final value = (event['points'] as num?)?.toInt() ?? 0;
      points += value;
      switch (activity) {
        case 'post':
          posts++;
        case 'like':
          likes++;
        case 'comment':
          comments++;
      }
    }

    return GamificationSummary(
      points: points,
      posts: posts,
      likes: likes,
      comments: comments,
    );
  }
}

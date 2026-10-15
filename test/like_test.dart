import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petverse/models/post.dart';
import 'package:petverse/widgets/post_card.dart';

void main() {
  const post = Post(
    id: 'post1',
    ownerId: 'owner',
    authorName: 'Ana',
    authorPhotoUrl: '',
    petId: 'pet1',
    petName: 'Luna',
    mediaType: 'image',
    mediaUrl: 'https://example.com/luna.jpg',
    caption: 'Luna en el parque',
    likes: [],
    commentCount: 0,
    createdAt: null,
  );

  testWidgets('botón y doble toque cambian el like', (tester) async {
    var toggles = 0;
    Widget app(Post currentPost) => MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: PostCard(
            post: currentPost,
            currentUserId: 'me',
            onToggleLike: () async {
              toggles++;
            },
          ),
        ),
      ),
    );

    await tester.pumpWidget(app(post));
    await tester.ensureVisible(find.byTooltip('Dar me gusta'));
    await tester.tap(find.byTooltip('Dar me gusta'));
    await tester.pumpAndSettle();
    expect(toggles, 1);

    await tester.pumpWidget(
      app(
        const Post(
          id: 'post1',
          ownerId: 'owner',
          authorName: 'Ana',
          authorPhotoUrl: '',
          petId: 'pet1',
          petName: 'Luna',
          mediaType: 'image',
          mediaUrl: 'https://example.com/luna.jpg',
          caption: 'Luna en el parque',
          likes: ['me'],
          commentCount: 0,
          createdAt: null,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byTooltip('Quitar me gusta'), findsOneWidget);
    expect(find.byIcon(Icons.favorite), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    final image = find.byType(Image);
    await tester.ensureVisible(image);
    await tester.tap(image);
    await tester.pump(const Duration(milliseconds: 80));
    await tester.tap(image);
    await tester.pumpAndSettle();
    expect(toggles, 2);
  });
}

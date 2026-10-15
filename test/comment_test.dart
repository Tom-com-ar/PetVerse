import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petverse/models/post.dart';
import 'package:petverse/models/post_comment.dart';
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

  testWidgets('muestra, agrega y elimina comentarios propios en tiempo real', (
    tester,
  ) async {
    final comments = StreamController<List<PostComment>>();
    addTearDown(comments.close);
    String? addedText;
    String? deletedId;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PostCard(
              post: post,
              currentUserId: 'me',
              onToggleLike: () async {},
              comments: comments.stream,
              onAddComment: (text) async => addedText = text,
              onDeleteComment: (id) async => deletedId = id,
            ),
          ),
        ),
      ),
    );

    comments.add(const [
      PostComment(
        id: 'mine',
        authorId: 'me',
        authorName: 'Tomás',
        authorPhotoUrl: '',
        text: 'Qué linda Luna',
        createdAt: null,
      ),
      PostComment(
        id: 'other',
        authorId: 'other',
        authorName: 'Ana',
        authorPhotoUrl: '',
        text: 'Gracias',
        createdAt: null,
      ),
    ]);
    await tester.pumpAndSettle();
    expect(find.text('Comentarios (2)'), findsOneWidget);

    await tester.ensureVisible(find.text('Comentarios (2)'));
    await tester.tap(find.text('Comentarios (2)'));
    await tester.pumpAndSettle();
    expect(find.text('Qué linda Luna'), findsOneWidget);
    expect(find.text('Gracias'), findsOneWidget);
    expect(find.byTooltip('Eliminar comentario'), findsOneWidget);

    await tester.ensureVisible(find.byType(TextField));
    await tester.enterText(find.byType(TextField), '  ¡Hermosa!  ');
    await tester.pump();
    expect(
      tester
          .widget<IconButton>(find.widgetWithIcon(IconButton, Icons.send))
          .onPressed,
      isNotNull,
    );
    await tester.ensureVisible(find.byTooltip('Enviar comentario'));
    await tester.tap(find.byTooltip('Enviar comentario'));
    await tester.pumpAndSettle();
    expect(addedText, '¡Hermosa!');
    expect(find.widgetWithText(TextField, '¡Hermosa!'), findsNothing);

    await tester.ensureVisible(find.byTooltip('Eliminar comentario'));
    await tester.tap(find.byTooltip('Eliminar comentario'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    expect(deletedId, 'mine');

    comments.add(const [
      PostComment(
        id: 'other',
        authorId: 'other',
        authorName: 'Ana',
        authorPhotoUrl: '',
        text: 'Gracias',
        createdAt: null,
      ),
    ]);
    await tester.pumpAndSettle();
    expect(find.text('Comentarios (1)'), findsOneWidget);
    expect(find.text('Qué linda Luna'), findsNothing);
  });
}

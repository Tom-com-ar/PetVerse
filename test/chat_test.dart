import 'package:flutter_test/flutter_test.dart';
import 'package:petverse/utils/chat_validators.dart';

void main() {
  test('valida mensajes del chat', () {
    expect(validateChatMessage('  '), isNotNull);
    expect(validateChatMessage('Hola, ¿cómo está Luna?'), isNull);
    expect(validateChatMessage('a' * 2001), isNotNull);
  });
}

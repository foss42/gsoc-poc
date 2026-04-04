import 'package:test/test.dart';
import 'package:open_responses_parser/open_responses_parser.dart';

void main() {
  group('ReasoningItem', () {
    test('fromMap with valid data', () {
      final item = ReasoningItem.fromMap({
        'type': 'reasoning',
        'id': 'rs_001',
        'summary': [
          {'type': 'summary_text', 'text': 'Hello'},
        ],
      });
      expect(item.id, equals('rs_001'));
      expect(item.summary.length, equals(1));
      expect(item.summary.first.text, equals('Hello'));
    });

    test('fromMap with missing summary uses empty list', () {
      final item = ReasoningItem.fromMap({'type': 'reasoning', 'id': 'rs_001'});
      expect(item.summary, isEmpty);
    });

    test('equality works correctly', () {
      final a = ReasoningItem.fromMap({
        'type': 'reasoning',
        'id': 'rs_001',
        'summary': [],
      });
      final b = ReasoningItem.fromMap({
        'type': 'reasoning',
        'id': 'rs_001',
        'summary': [],
      });
      expect(a, equals(b));
    });
  });

  group('FunctionCallItem', () {
    test('parsedArguments returns Map for valid JSON', () {
      final item = FunctionCallItem.fromMap({
        'type': 'function_call',
        'id': 'fc_001',
        'call_id': 'call_001',
        'name': 'test',
        'arguments': '{"city": "Tokyo"}',
        'status': 'completed',
      });
      expect(item.parsedArguments?['city'], equals('Tokyo'));
    });

    test('parsedArguments returns null for invalid JSON', () {
      final item = FunctionCallItem.fromMap({
        'type': 'function_call',
        'id': 'fc_001',
        'call_id': 'call_001',
        'name': 'test',
        'arguments': 'not json',
        'status': 'completed',
      });
      expect(item.parsedArguments, isNull);
    });
  });

  group('MessageItem', () {
    test('fullText concatenates all content', () {
      final item = MessageItem.fromMap({
        'type': 'message',
        'id': 'msg_001',
        'role': 'assistant',
        'content': [
          {'type': 'output_text', 'text': 'Hello'},
          {'type': 'output_text', 'text': 'World'},
        ],
      });
      expect(item.fullText, contains('Hello'));
      expect(item.fullText, contains('World'));
    });

    test('fullText is empty for empty content list', () {
      final item = MessageItem.fromMap({
        'type': 'message',
        'id': 'msg_001',
        'role': 'assistant',
        'content': [],
      });
      expect(item.fullText, equals(''));
    });
  });

  group('UnknownItem', () {
    test('preserves raw type string', () {
      final item =
          UnknownItem.fromRaw({'type': 'computer_use', 'action': 'click'});
      expect(item.type, equals('computer_use'));
    });

    test('handles null raw gracefully', () {
      final item = UnknownItem.fromRaw(null);
      expect(item.type, equals('unknown'));
    });
  });

  group('ResponseUsage', () {
    test('totalTokens is sum of input and output', () {
      final usage =
          ResponseUsage.fromMap({'input_tokens': 100, 'output_tokens': 50});
      expect(usage.totalTokens, equals(150));
    });

    test('missing fields default to 0', () {
      final usage = ResponseUsage.fromMap({});
      expect(usage.inputTokens, equals(0));
      expect(usage.outputTokens, equals(0));
    });
  });
}

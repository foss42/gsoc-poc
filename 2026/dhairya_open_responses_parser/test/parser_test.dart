import 'dart:convert';

import 'package:test/test.dart';
import 'package:open_responses_parser/open_responses_parser.dart';

import 'fixtures/weather_response.dart';
import 'fixtures/malformed_fixtures.dart';
import 'fixtures/edge_case_fixtures.dart';

void main() {
  final parser = OpenResponseParser();

  group('Full valid fixture — weather response', () {
    late ParsedOpenResponse result;
    setUpAll(() {
      result = parser.parse(kWeatherResponse);
    });

    test('id is correctly parsed', () {
      expect(result.id, equals('resp_demo_001'));
    });

    test('status is correctly parsed', () {
      expect(result.status, equals('completed'));
    });

    test('model is correctly parsed', () {
      expect(result.model, equals('gpt-4o'));
    });

    test('total items is 6', () {
      expect(result.totalItems, equals(6));
    });

    test('has 1 reasoning item', () {
      expect(result.reasoningItems.length, equals(1));
    });

    test('reasoning item has correct summary text', () {
      expect(result.reasoningItems.first.summary.first.text,
          contains('weather info'));
    });

    test('has 2 function call items', () {
      expect(result.functionCalls.length, equals(2));
    });

    test('function call names are correct', () {
      final names = result.functionCalls.map((c) => c.name).toList();
      expect(
          names, containsAll(['get_current_weather', 'get_current_weather']));
    });

    test('has 2 function call output items', () {
      expect(result.functionCallOutputs.length, equals(2));
    });

    test('has 1 message item', () {
      expect(result.messages.length, equals(1));
    });

    test('message role is assistant', () {
      expect(result.messages.first.role, equals('assistant'));
    });

    test('message fullText contains expected content', () {
      expect(result.messages.first.fullText, contains('Tokyo'));
    });

    test('has 0 unknown items', () {
      expect(result.unknownItems.length, equals(0));
    });

    test('has 2 correlated calls', () {
      expect(result.correlatedCalls.length, equals(2));
    });

    test('tokyo call is complete (has output)', () {
      expect(result.correlatedCalls['call_weather_tokyo']?.isComplete, isTrue);
    });

    test('london call is complete (has output)', () {
      expect(
          result.correlatedCalls['call_weather_london']?.isComplete, isTrue);
    });

    test('tokyo call output contains temperature', () {
      final output = result.correlatedCalls['call_weather_tokyo']?.output;
      expect(output?.parsedOutput?['temperature'], equals(22));
    });

    test('usage is not null', () {
      expect(result.usage, isNotNull);
    });

    test('usage input_tokens is 120', () {
      expect(result.usage?.inputTokens, equals(120));
    });

    test('usage output_tokens is 85', () {
      expect(result.usage?.outputTokens, equals(85));
    });

    test('usage total_tokens is 205', () {
      expect(result.usage?.totalTokens, equals(205));
    });

    test('function call arguments can be parsed as JSON', () {
      final call = result.functionCalls.first;
      expect(call.parsedArguments, isNotNull);
      expect(call.parsedArguments?['city'], isNotNull);
    });
  });

  group('Malformed inputs — never throw', () {
    test('missing output key returns empty items', () {
      final result = parser.parse(kMissingOutput);
      expect(result.items, isEmpty);
      expect(result.correlatedCalls, isEmpty);
    });

    test('null output returns empty items', () {
      final result = parser.parse(kNullOutput);
      expect(result.items, isEmpty);
    });

    test('wrong type for output returns empty items', () {
      final result = parser.parse(kWrongTypeOutput);
      expect(result.items, isEmpty);
    });

    test('item with missing type becomes UnknownItem', () {
      final result = parser.parse(kItemMissingType);
      expect(result.unknownItems.length, equals(1));
    });

    test('function_call with missing call_id uses empty string', () {
      final result = parser.parse(kFunctionCallMissingCallId);
      expect(result.functionCalls.length, equals(1));
      expect(result.functionCalls.first.callId, equals(''));
    });

    test('function_call with invalid JSON arguments does not throw', () {
      final result = parser.parse(kFunctionCallInvalidArgs);
      expect(result.functionCalls.length, equals(1));
      expect(result.functionCalls.first.parsedArguments, isNull);
    });

    test('completely empty map returns safe fallback response', () {
      final result = parser.parse(kEmptyMap);
      expect(result.id, isNotNull);
      expect(result.items, isEmpty);
    });

    test('output list with non-map items produces UnknownItems', () {
      final result = parser.parse(kOutputWithNonMapItems);
      expect(result.unknownItems.length, equals(3));
    });
  });

  group('Edge cases — correlation and mixed types', () {
    test('orphan function_call has null output in correlatedCalls', () {
      final result = parser.parse(kOrphanFunctionCall);
      expect(result.correlatedCalls['call_orphan']?.isComplete, isFalse);
      expect(result.correlatedCalls['call_orphan']?.output, isNull);
    });

    test('orphan function_call_output does not appear in correlatedCalls', () {
      final result = parser.parse(kOrphanFunctionCallOutput);
      expect(result.correlatedCalls, isEmpty);
      expect(result.functionCallOutputs.length, equals(1));
    });

    test('no usage field produces null usage', () {
      final result = parser.parse(kNoUsage);
      expect(result.usage, isNull);
    });

    test('unknown type is preserved and accessible', () {
      final result = parser.parse(kMixedWithUnknown);
      expect(result.unknownItems.length, equals(1));
      expect(result.unknownItems.first.type, equals('computer_use'));
      expect(result.reasoningItems.length, equals(1));
      expect(result.messages.length, equals(1));
    });

    test('reasoning with empty summary list parses without error', () {
      final result = parser.parse(kEmptySummary);
      expect(result.reasoningItems.first.summary, isEmpty);
    });
  });

  group('parseJsonString convenience method', () {
    test('parses valid JSON string correctly', () {
      final jsonStr = json.encode(kWeatherResponse);
      final result = parser.parseJsonString(jsonStr);
      expect(result.id, equals('resp_demo_001'));
    });

    test('invalid JSON string returns safe fallback', () {
      final result = parser.parseJsonString('not json at all {{{');
      expect(result.id, equals('invalid'));
      expect(result.items, isEmpty);
    });

    test('valid JSON but wrong shape (array) returns safe fallback', () {
      final result = parser.parseJsonString('[1, 2, 3]');
      expect(result.items, isEmpty);
    });
  });
}

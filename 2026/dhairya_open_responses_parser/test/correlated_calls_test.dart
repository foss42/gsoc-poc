import 'package:test/test.dart';
import 'package:open_responses_parser/open_responses_parser.dart';

import 'fixtures/weather_response.dart';
import 'fixtures/edge_case_fixtures.dart';

void main() {
  final parser = OpenResponseParser();

  group('Call-output correlation', () {
    test('each call_id maps to correct call name', () {
      final result = parser.parse(kWeatherResponse);
      expect(result.correlatedCalls['call_weather_tokyo']?.call.name,
          equals('get_current_weather'));
      expect(result.correlatedCalls['call_weather_london']?.call.name,
          equals('get_current_weather'));
    });

    test('output call_id matches its call call_id', () {
      final result = parser.parse(kWeatherResponse);
      final tokyo = result.correlatedCalls['call_weather_tokyo']!;
      expect(tokyo.call.callId, equals(tokyo.output?.callId));
    });

    test('duplicate call_id: correlatedCalls still has one entry per call_id',
        () {
      final result = parser.parse(kDuplicateCallId);
      expect(result.correlatedCalls.length, equals(1));
      expect(result.correlatedCalls['call_dup']?.isComplete, isTrue);
    });

    test('CorrelatedCall.isComplete is false for orphan call', () {
      final result = parser.parse(kOrphanFunctionCall);
      expect(result.correlatedCalls['call_orphan']?.isComplete, isFalse);
    });

    test('CorrelatedCall toString is readable', () {
      final result = parser.parse(kWeatherResponse);
      final cc = result.correlatedCalls['call_weather_tokyo']!;
      expect(cc.toString(), contains('call_weather_tokyo'));
      expect(cc.toString(), contains('true'));
    });
  });
}

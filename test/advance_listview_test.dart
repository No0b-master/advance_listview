import 'package:flutter_test/flutter_test.dart';
import 'package:advance_listview/advance_listview.dart';

void main() {
  group('Enums', () {
    test('LoadMode has correct values', () {
      expect(LoadMode.values.length, 2);
      expect(LoadMode.auto, isNotNull);
      expect(LoadMode.button, isNotNull);
    });

    test('ResponseFormat has correct values', () {
      expect(ResponseFormat.values.length, 2);
      expect(ResponseFormat.direct, isNotNull);
      expect(ResponseFormat.wrapped, isNotNull);
    });
  });

  group('Exceptions', () {
    test('ApiException contains status code and body', () {
      final exception = ApiException(404, {'error': 'Not found'});
      expect(exception.statusCode, 404);
      expect(exception.responseBody, {'error': 'Not found'});
      expect(exception.message, contains('404'));
    });

    test('InvalidResponseFormatException contains format info', () {
      final exception = InvalidResponseFormatException(
        'Array',
        'Object',
        message: 'Expected array',
      );
      expect(exception.expectedFormat, 'Array');
      expect(exception.actualFormat, 'Object');
      expect(exception.message, 'Expected array');
    });

    test('NetworkException contains message', () {
      final exception = NetworkException('Connection failed');
      expect(exception.message, 'Connection failed');
    });

    test('JsonParsingException contains message', () {
      final exception = JsonParsingException('Invalid JSON');
      expect(exception.message, 'Invalid JSON');
    });

    test('Exception hierarchy is correct', () {
      final apiException = ApiException(500, {});
      final networkException = NetworkException('Network error');
      final formatException = InvalidResponseFormatException('A', 'B');

      expect(apiException, isA<AdvanceListViewException>());
      expect(networkException, isA<AdvanceListViewException>());
      expect(formatException, isA<AdvanceListViewException>());
    });
  });
}

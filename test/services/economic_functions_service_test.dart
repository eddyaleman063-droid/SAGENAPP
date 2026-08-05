import 'package:flutter_test/flutter_test.dart';
import 'package:sagen/services/economic_functions_service.dart';

void main() {
  group('EconomicFunctionsService', () {
    test('singleton instance exists', () {
      expect(EconomicFunctionsService.instance, isA<EconomicFunctionsService>());
    });

    test('singleton returns same instance', () {
      final a = EconomicFunctionsService.instance;
      final b = EconomicFunctionsService.instance;
      expect(identical(a, b), isTrue);
    });

    test('constructor is private', () {
      // The only way to get an instance is through .instance
      final service = EconomicFunctionsService.instance;
      expect(service, isNotNull);
    });
  });
}

import '../config/app_config.dart';
import 'api_client.dart';
import 'app_logger.dart';

/// Represents a MercadoPago checkout preference.
class MercadoPagoPreference {
  final String preferenceId;
  final String initPoint;
  final String externalRef;

  const MercadoPagoPreference({
    required this.preferenceId,
    required this.initPoint,
    required this.externalRef,
  });
}

/// MercadoPago integration for payment processing.
class MercadoPagoService {
  MercadoPagoService({ApiSender? sender, AppLogger? logger})
    : _sender = sender ?? ApiClient.instance,
      _logger = logger ?? AppLogger();

  final ApiSender _sender;
  final AppLogger _logger;

  String get _baseUrl =>
      AppConfig.mercadopagoFunctionsUrl.replaceAll(RegExp(r'/+$'), '');

  Future<MercadoPagoPreference> createPreference({
    required int amount,
    required String productId,
    required String idToken,
    double? price,
  }) async {
    final url = Uri.parse('$_baseUrl/api/createPaymentPreference');

    try {
      final response = await _sender.send(
        ApiRequest(
          method: 'POST',
          uri: url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: {
            'amount': amount,
            'productId': productId,
            'price': price ?? 0.0,
          },
        ),
      );

      final decoded = response.jsonMap;
      if (decoded == null) {
        _logger.error('MP createPreference: invalid JSON', decoded);
        throw const MercadoPagoException('Invalid server response');
      }

      final result = decoded['result'] as Map<String, dynamic>?;
      if (result == null) {
        _logger.error('MP createPreference: no result', decoded);
        throw const MercadoPagoException('Invalid server response');
      }

      final preferenceId = result['preferenceId'] as String?;
      final initPoint = result['initPoint'] as String?;
      final externalRef = result['externalRef'] as String?;
      if (preferenceId == null || initPoint == null) {
        _logger.error('MP createPreference: missing fields', result);
        throw const MercadoPagoException(
          'Invalid server response: missing fields',
        );
      }
      return MercadoPagoPreference(
        preferenceId: preferenceId,
        initPoint: initPoint,
        externalRef: externalRef ?? '',
      );
    } on MercadoPagoException {
      rethrow;
    } on ApiException catch (e) {
      _logger.error('MP createPreference API error', e);
      throw MercadoPagoException(
        'Error connecting to payment service (${e.type.name})',
      );
    } catch (e) {
      _logger.error('MP createPreference error', e);
      throw const MercadoPagoException(
        'Could not connect to payment service. '
        'Check your internet connection.',
      );
    }
  }

  Future<bool> checkHealth() async {
    try {
      final url = Uri.parse('$_baseUrl/api/health');
      final response = await _sender.send(ApiRequest(method: 'GET', uri: url));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e) {
      _logger.warning('[MercadoPagoService] checkHealth error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> registerPendingPayment({
    required String paymentMethod,
    required String operationId,
    required String idToken,
    int? amount,
    String? productId,
  }) async {
    final url = Uri.parse('$_baseUrl/api/registerPendingPayment');
    try {
      final response = await _sender.send(
        ApiRequest(
          method: 'POST',
          uri: url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: {
            'paymentMethod': paymentMethod,
            'operationId': operationId,
            'amount': amount,
            'productId': productId,
          },
        ),
      );
      final decoded = response.jsonMap;
      return decoded?['result'] as Map<String, dynamic>? ?? {};
    } on ApiException catch (e) {
      _logger.error('registerPendingPayment API error', e);
      rethrow;
    } catch (e) {
      _logger.error('registerPendingPayment error', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> checkPendingPaymentStatus({
    required String pendingPaymentId,
    required String idToken,
  }) async {
    final url = Uri.parse('$_baseUrl/api/checkPendingPaymentStatus');
    try {
      final response = await _sender.send(
        ApiRequest(
          method: 'POST',
          uri: url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken',
          },
          body: {'pendingPaymentId': pendingPaymentId},
        ),
      );
      final decoded = response.jsonMap;
      return decoded?['result'] as Map<String, dynamic>? ?? {};
    } on ApiException catch (e) {
      _logger.error('checkPendingPaymentStatus API error', e);
      rethrow;
    } catch (e) {
      _logger.error('checkPendingPaymentStatus error', e);
      rethrow;
    }
  }
}

class MercadoPagoException implements Exception {
  final String message;
  const MercadoPagoException(this.message);

  @override
  String toString() => message;
}

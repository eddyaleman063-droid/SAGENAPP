import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../config/app_config.dart';
import '../../../core/theme/theme_constants.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/app_logger.dart';
import '../../widgets/common/sagen_notification.dart';

class DonationCreditingService {
  final String _baseUrl = AppConfig.mercadopagoFunctionsUrl;
  final _logger = AppLogger();

  Future<bool> creditDonation({
    required String userId,
    required int amount,
    required String paymentMethod,
  }) async {
    final url = Uri.parse('$_baseUrl/api/adminCreditDonation');

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _logger.error('adminCreditDonation: no authenticated user');
        return false;
      }
      final idToken = await user.getIdToken();
      final key = '$userId|$amount|${DateTime.now().millisecondsSinceEpoch}';
      final idempotencyKey = sha256.convert(utf8.encode(key)).toString();

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $idToken',
            },
            body: jsonEncode({
              'userId': userId,
              'amount': amount,
              'paymentMethod': paymentMethod,
              'idempotencyKey': idempotencyKey,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        _logger.error('adminCreditDonation failed', {
          'status': response.statusCode,
          'bodyLength': response.body.length,
        });
        return false;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final result = decoded['result'] as Map<String, dynamic>?;
      return result?['success'] == true;
    } catch (e) {
      _logger.error('adminCreditDonation error', e);
      return false;
    }
  }
}

class AdminCreditScreen extends StatefulWidget {
  const AdminCreditScreen({super.key});

  @override
  State<AdminCreditScreen> createState() => _AdminCreditScreenState();
}

class _AdminCreditScreenState extends State<AdminCreditScreen> {
  final _userIdController = TextEditingController();
  final _amountController = TextEditingController();
  final _service = DonationCreditingService();
  bool _loading = false;
  String _method = 'whatsapp';
  bool _isAdmin = false;
  bool _checkingAdmin = true;

  @override
  void initState() {
    super.initState();
    _checkAdmin();
  }

  Future<void> _checkAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _isAdmin = false;
          _checkingAdmin = false;
        });
      }
      return;
    }
    try {
      final token = await user.getIdTokenResult();
      if (!mounted) return;
      setState(() {
        _isAdmin = token.claims?['admin'] == true;
        _checkingAdmin = false;
      });
    } catch (e) {
      AppLogger().error('Failed to get ID token result: $e');
      if (!mounted) return;
      setState(() {
        _isAdmin = false;
        _checkingAdmin = false;
      });
    }
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _credit() async {
    final userId = _userIdController.text.trim();
    final amount = int.tryParse(_amountController.text.trim());

    if (!mounted) return;
    final l = AppLocalizations.of(context)!;

    if (userId.isEmpty || amount == null || amount <= 0) {
      if (!mounted) return;
      SagenNotification.show(
        context,
        message: l.adminInvalidInput,
        type: NotificationType.error,
      );
      return;
    }

    setState(() => _loading = true);

    final ok = await _service.creditDonation(
      userId: userId,
      amount: amount,
      paymentMethod: _method,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      SagenNotification.show(
        context,
        message: l.adminCreditSuccessNotification(amount, userId),
      );
      _userIdController.clear();
      _amountController.clear();
    } else {
      SagenNotification.show(
        context,
        message: l.adminCreditError,
        type: NotificationType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.adminCreditDonationTitle)),
      body: _checkingAdmin
          ? const Center(child: CircularProgressIndicator())
          : !_isAdmin
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_rounded,
                      size: 48,
                      color: PremiumColors.warning,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      l.adminVerifyingPermissions,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.body.copyWith(
                        color: PremiumColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    label: l.adminFieldUserId,
                    child: TextField(
                      controller: _userIdController,
                      maxLength: 128,
                      decoration: InputDecoration(
                        labelText: l.adminFieldUserId,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Semantics(
                    label: l.adminFieldDonationAmount,
                    child: TextField(
                      controller: _amountController,
                      maxLength: 10,
                      decoration: InputDecoration(
                        labelText: l.adminFieldDonationAmount,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: _method,
                    decoration: InputDecoration(
                      labelText: l.adminPaymentMethod,
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'whatsapp',
                        child: Text(l.adminWhatsapp),
                      ),
                      DropdownMenuItem(
                        value: 'mercadopago',
                        child: Text(l.adminMercadoPago),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _method = v);
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  SizedBox(
                    height: 52,
                    child: Semantics(
                      button: true,
                      label: l.adminCreditDonationA11y,
                      child: FilledButton(
                        onPressed: _loading ? null : _credit,
                        child: _loading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: Semantics(
                                  label: l.loading,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                l.adminCreditDonationButton,
                                style: AppTextStyle.titleSmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

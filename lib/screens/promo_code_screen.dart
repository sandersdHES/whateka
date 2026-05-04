import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../i18n/strings.dart';
import '../main.dart';
import '../services/subscription_service.dart';
import '../widgets/responsive_center.dart';

/// Ecran de saisie d'un code promo.
class PromoCodeScreen extends StatefulWidget {
  const PromoCodeScreen({super.key});

  @override
  State<PromoCodeScreen> createState() => _PromoCodeScreenState();
}

class _PromoCodeScreenState extends State<PromoCodeScreen> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _redeem() async {
    if (!_formKey.currentState!.validate()) return;
    final code = _controller.text.trim().toUpperCase();
    setState(() {
      _busy = true;
      _error = null;
    });

    final result = await SubscriptionService.instance.redeemPromoCode(code);
    if (!mounted) return;

    setState(() => _busy = false);

    if (result.success) {
      final s = S.current;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            s.promoCodeSuccess
                .replaceAll('{months}', '${result.durationMonths ?? 6}'),
          ),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context, true);
      return;
    }

    // Map error code → message localise.
    final s = S.current;
    final msg = switch (result.error) {
      'code_not_found' => s.promoCodeErrorNotFound,
      'code_inactive' => s.promoCodeErrorInactive,
      'code_expired' => s.promoCodeErrorExpired,
      'code_exhausted' => s.promoCodeErrorExhausted,
      'already_redeemed' => s.promoCodeErrorAlreadyRedeemed,
      'not_authenticated' => s.promoCodeErrorNotAuthenticated,
      _ => s.promoCodeErrorGeneric,
    };
    setState(() => _error = msg);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: LocaleProvider.instance,
      builder: (context, _) {
        final s = S.of(context);
        return Scaffold(
          backgroundColor: AppColors.paper,
          appBar: AppBar(
            backgroundColor: AppColors.paper,
            surfaceTintColor: AppColors.paper,
            title: Text(s.promoCodeTitle),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ResponsiveCenter(
            maxWidth: 480,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(
                      child: Icon(Icons.local_offer_outlined,
                          size: 60, color: AppColors.cyan),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      s.promoCodeHeadline,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.promoCodeSubheadline,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.stone),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _controller,
                      autofocus: true,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        UpperCaseTextFormatter(),
                        LengthLimitingTextInputFormatter(40),
                      ],
                      decoration: InputDecoration(
                        labelText: s.promoCodeLabel,
                        hintText: 'WHATEKA2026',
                        prefixIcon: const Icon(Icons.confirmation_number_outlined),
                      ),
                      style: const TextStyle(
                          letterSpacing: 1.5, fontWeight: FontWeight.w600),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty)
                              ? s.validationRequired
                              : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F0),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: const Color(0xFFE53935), width: 0.5),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline,
                                size: 18, color: Color(0xFFE53935)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _error!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: const Color(0xFFB71C1C)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _busy ? null : _redeem,
                      child: _busy
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(s.promoCodeApply),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Force la saisie en majuscules (UX pour les codes promo).
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

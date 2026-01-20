import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:plebqr_india/component_library/component_library.dart';
import 'package:plebqr_india/plebqr_api/src/models/response/invoice_rm.dart';
import 'package:plebqr_india/plebqr_api/src/models/response/payment_status_rm.dart';

class Step3InvoiceDisplay extends StatelessWidget {
  const Step3InvoiceDisplay({
    required this.invoice,
    required this.amountInSats,
    required this.paymentStatus,
    required this.onCancel,
    super.key,
  });

  final InvoiceRM? invoice;
  final int? amountInSats;
  final PaymentStatusRM? paymentStatus;
  final VoidCallback onCancel;

  Future<void> _copyInvoice(BuildContext context, String bolt11) async {
    await Clipboard.setData(ClipboardData(text: bolt11));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice copied to clipboard')),
      );
    }
  }

  Future<void> _openInvoice(BuildContext context, String bolt11) async {
    final uri = Uri.parse('lightning:$bolt11');
    try {
      // Try to launch directly - canLaunchUrl can return false even if launchUrl works
      final launched = await launchUrl(uri);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No Lightning wallet app found. Please install a Lightning wallet app.',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open invoice: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (invoice == null) {
      return const Center(child: Text('Invoice not generated'));
    }

    final bolt11 = invoice!.pr;
    final amountInInr = invoice!.successAction.ccyAmount;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.mediumLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // QR Code - Compact size
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(Spacing.medium),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: bolt11,
                  version: QrVersions.auto,
                  size: 200.0,
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: Spacing.medium),
            // Amount - Compact
            Text(
              '₹$amountInInr',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (amountInSats != null && amountInSats! > 0) ...[
              const SizedBox(height: Spacing.xSmall),
              Text(
                '$amountInSats sats',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: Spacing.medium),
            // Processing indicator
            if (paymentStatus != null &&
                paymentStatus!.status == 'Processing') ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.medium,
                  vertical: Spacing.small,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.small),
                    Text(
                      'Processing payment...',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.medium),
            ],
            // Action buttons - Compact
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ActionButton(
                  icon: Icons.copy_outlined,
                  label: 'Copy',
                  onPressed: () => _copyInvoice(context, bolt11),
                ),
                const SizedBox(width: Spacing.medium),
                _ActionButton(
                  icon: Icons.launch,
                  label: 'Open',
                  onPressed: () => _openInvoice(context, bolt11),
                ),
              ],
            ),
            const SizedBox(height: Spacing.medium),
            // Cancel button
            TextButton(onPressed: onCancel, child: const Text('Cancel')),
          ],
        ),
      ),
    );
  }
}

// Minimal action button widget
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.medium,
          vertical: Spacing.small,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: Spacing.xSmall),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

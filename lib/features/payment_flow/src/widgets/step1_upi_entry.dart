import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plebqr_india/component_library/component_library.dart';
import 'package:plebqr_india/form_fields/form_fields.dart';
import 'package:plebqr_india/features/payment_flow/src/widgets/qr_scanner_screen.dart';

class Step1UpiEntry extends StatefulWidget {
  const Step1UpiEntry({
    required this.upiId,
    required this.onUpiIdChanged,
    required this.onUpiIdUnfocused,
    required this.onStep1Submit,
    required this.isLoading,
    super.key,
  });

  final UpiId upiId;
  final ValueChanged<String> onUpiIdChanged;
  final VoidCallback onUpiIdUnfocused;
  final VoidCallback onStep1Submit;
  final bool isLoading;

  @override
  State<Step1UpiEntry> createState() => _Step1UpiEntryState();
}

class _Step1UpiEntryState extends State<Step1UpiEntry> {
  final _upiIdFocusNode = FocusNode();
  final _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textEditingController.text = widget.upiId.value;
    _setUpUpiIdFieldFocusListener();
  }

  @override
  void didUpdateWidget(Step1UpiEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.upiId.value != widget.upiId.value) {
      _textEditingController.text = widget.upiId.value;
    }
  }

  void _setUpUpiIdFieldFocusListener() {
    _upiIdFocusNode.addListener(() {
      if (!_upiIdFocusNode.hasFocus) {
        widget.onUpiIdUnfocused();
      }
    });
  }

  Future<void> _handleScanQr() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => const QrScannerScreen()),
    );

    if (result != null && mounted) {
      _textEditingController.text = result;
      widget.onUpiIdChanged(result);
    }
  }

  Future<void> _handlePaste() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final pastedText = clipboardData?.text ?? '';
    if (pastedText.isNotEmpty && mounted) {
      _textEditingController.text = pastedText;
      widget.onUpiIdChanged(pastedText);
    }
  }

  void _handleContinue() {
    // Unfocus the field to trigger validation
    _upiIdFocusNode.unfocus();
    // Then submit (cubit will validate and call API)
    widget.onStep1Submit();
  }

  @override
  Widget build(BuildContext context) {
    // Only show errors if the field has been validated (is dirty)
    final upiIdError =
        !widget.upiId.isPure && !widget.upiId.isValid
            ? widget.upiId.error
            : null;
    final isSubmissionInProgress = widget.isLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        left: Spacing.mediumLarge,
        right: Spacing.mediumLarge,
        top: Spacing.mediumLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: Spacing.xLarge),
          const Icon(Icons.qr_code_scanner, size: 64, color: Colors.grey),
          const SizedBox(height: Spacing.mediumLarge),
          Text(
            'Enter UPI ID',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.small),
          Text(
            'Scan QR code or enter manually',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xxLarge),
          TextField(
            controller: _textEditingController,
            focusNode: _upiIdFocusNode,
            onChanged: widget.onUpiIdChanged,
            textInputAction: TextInputAction.done,
            enabled: !isSubmissionInProgress,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'UPI ID',
              hintText: 'username@bank',
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.paste),
                    onPressed: isSubmissionInProgress ? null : _handlePaste,
                    tooltip: 'Paste',
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: isSubmissionInProgress ? null : _handleScanQr,
                    tooltip: 'Scan QR',
                  ),
                ],
              ),
              errorText:
                  upiIdError == null
                      ? null
                      : (upiIdError == UpiIdValidationError.empty
                          ? 'UPI ID cannot be empty'
                          : 'Invalid UPI ID format. Expected: username@bank'),
            ),
          ),
          const SizedBox(height: Spacing.xLarge),
          ExpandedElevatedButton(
            label: 'Continue',
            onTap: isSubmissionInProgress ? null : _handleContinue,
            icon:
                isSubmissionInProgress
                    ? Transform.scale(
                      scale: 0.5,
                      child: const CircularProgressIndicator(),
                    )
                    : null,
          ),
          const SizedBox(height: Spacing.mediumLarge),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _upiIdFocusNode.dispose();
    _textEditingController.dispose();
    super.dispose();
  }
}

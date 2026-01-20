import 'package:flutter/material.dart';
import 'package:plebqr_india/component_library/component_library.dart';
import 'package:plebqr_india/form_fields/form_fields.dart';
import 'package:plebqr_india/plebqr_api/src/models/response/payment_request_rm.dart';

class Step2AmountEntry extends StatefulWidget {
  const Step2AmountEntry({
    required this.amount,
    required this.paymentRequest,
    required this.onAmountChanged,
    required this.onAmountUnfocused,
    required this.onStep2Submit,
    required this.onBackPressed,
    required this.isLoading,
    super.key,
  });

  final Amount amount;
  final PaymentRequestRM? paymentRequest;
  final ValueChanged<String> onAmountChanged;
  final VoidCallback onAmountUnfocused;
  final VoidCallback onStep2Submit;
  final VoidCallback onBackPressed;
  final bool isLoading;

  @override
  State<Step2AmountEntry> createState() => _Step2AmountEntryState();
}

class _Step2AmountEntryState extends State<Step2AmountEntry> {
  final _amountFocusNode = FocusNode();
  final _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textEditingController.text = widget.amount.value;
    _setUpAmountFieldFocusListener();
  }

  @override
  void didUpdateWidget(Step2AmountEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount.value != widget.amount.value) {
      _textEditingController.text = widget.amount.value;
    }
  }

  void _setUpAmountFieldFocusListener() {
    _amountFocusNode.addListener(() {
      if (!_amountFocusNode.hasFocus) {
        widget.onAmountUnfocused();
      }
    });
  }

  void _handleContinue() {
    // Unfocus the field to trigger validation
    _amountFocusNode.unfocus();
    // Then submit (cubit will validate and call API)
    widget.onStep2Submit();
  }

  @override
  Widget build(BuildContext context) {
    // Only show errors if the field has been validated (is dirty)
    final amountError =
        !widget.amount.isPure && !widget.amount.isValid
            ? widget.amount.error
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
          const Icon(Icons.currency_rupee, size: 64, color: Colors.grey),
          const SizedBox(height: Spacing.mediumLarge),
          Text(
            'Enter Amount',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.small),
          Text(
            'Amount range: ₹${Amount.minAmount.toStringAsFixed(0)} - ₹${Amount.maxAmount.toStringAsFixed(0)}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xxLarge),
          TextField(
            controller: _textEditingController,
            focusNode: _amountFocusNode,
            onChanged: widget.onAmountChanged,
            textInputAction: TextInputAction.done,
            enabled: !isSubmissionInProgress,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'Amount (INR)',
              hintText: 'Enter amount',
              prefixText: '₹ ',
              errorText:
                  amountError == null
                      ? null
                      : (amountError == AmountValidationError.empty
                          ? 'Amount cannot be empty'
                          : amountError == AmountValidationError.invalid
                          ? 'Please enter a valid number'
                          : amountError == AmountValidationError.tooLow
                          ? 'Amount must be at least ₹${Amount.minAmount}'
                          : 'Amount cannot exceed ₹${Amount.maxAmount}'),
            ),
          ),
          const SizedBox(height: Spacing.xLarge),
          // Back and Continue buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed:
                      isSubmissionInProgress ? null : widget.onBackPressed,
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: Spacing.mediumLarge),
              Expanded(
                flex: 2,
                child: ExpandedElevatedButton(
                  label: 'Generate Invoice',
                  onTap: isSubmissionInProgress ? null : _handleContinue,
                  icon:
                      isSubmissionInProgress
                          ? Transform.scale(
                            scale: 0.5,
                            child: const CircularProgressIndicator(),
                          )
                          : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.mediumLarge),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _amountFocusNode.dispose();
    _textEditingController.dispose();
    super.dispose();
  }
}

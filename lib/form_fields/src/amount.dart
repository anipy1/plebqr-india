import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

class Amount extends FormzInput<String, AmountValidationError>
    with EquatableMixin {
  const Amount.unvalidated([super.value = '']) : super.pure();

  const Amount.validated([super.value = '']) : super.dirty();

  static const double minAmount = 1.0;
  static const double maxAmount = 200.0;

  @override
  AmountValidationError? validator(String value) {
    if (value.isEmpty) {
      return AmountValidationError.empty;
    }

    final numericValue = double.tryParse(value);
    if (numericValue == null) {
      return AmountValidationError.invalid;
    }

    if (numericValue < minAmount) {
      return AmountValidationError.tooLow;
    }

    if (numericValue > maxAmount) {
      return AmountValidationError.tooHigh;
    }

    return null;
  }

  /// Returns the numeric value of the amount, or null if invalid.
  double? get numericValue => double.tryParse(value);

  @override
  List<Object?> get props => [value, isPure];
}

enum AmountValidationError { empty, invalid, tooLow, tooHigh }

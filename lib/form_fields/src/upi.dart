import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

class UpiId extends FormzInput<String, UpiIdValidationError>
    with EquatableMixin {
  const UpiId.unvalidated([super.value = '']) : super.pure();

  const UpiId.validated([super.value = '']) : super.dirty();

  static final _upiIdRegex = RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z0-9]+$');

  @override
  UpiIdValidationError? validator(String value) {
    if (value.isEmpty) {
      return UpiIdValidationError.empty;
    } else if (value.length < 5 || value.length > 256) {
      return UpiIdValidationError.invalid;
    } else if (!_upiIdRegex.hasMatch(value)) {
      return UpiIdValidationError.invalid;
    } else {
      return null;
    }
  }

  @override
  List<Object?> get props => [value, isPure];
}

enum UpiIdValidationError { empty, invalid }

/// Resultado de uma validação
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult.valid()
      : isValid = true,
        errorMessage = null;

  const ValidationResult.invalid(this.errorMessage) : isValid = false;

  @override
  String toString() => isValid ? 'Valid' : 'Invalid: $errorMessage';
}

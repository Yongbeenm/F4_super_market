/// Currency Formatter Utility
/// Provides consistent price formatting across the app

class CurrencyFormatter {
  /// Format price to 2 decimal places
  /// Example: 20.866999999 → "20.87"
  static String format(double amount) {
    return amount.toStringAsFixed(2);
  }

  /// Format price with dollar sign
  /// Example: 20.866999999 → "$20.87"
  static String formatWithSymbol(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  /// Parse string to double safely
  /// Returns 0.0 if parsing fails
  static double parse(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  /// Format price for display in cards/lists
  /// Includes proper rounding to prevent floating point errors
  static String formatPrice(dynamic price) {
    final amount = parse(price);
    return formatWithSymbol(amount);
  }
}

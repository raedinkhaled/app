/// Adaptative sizes.
class FontSize {
  /// Return an adaptative size for a big quote card
  /// according to the length of the string.
  static double bigCard(String str) {
    final length = str.length;

    if (length < 100) { return 35.0; }
    else if (length < 200) { return 25.0; }
    else if (length < 300) { return 20.0; }

    return 15.0;
  }
}
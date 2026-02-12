import 'dart:math';

/// Create random text of a given length.
///
/// The text only contains A-Z, a-z, 0-9, and space.
///
/// [length] is the length of the random text to be generated. Must be greater
/// than 0.
String createRandomText(int length) {
  assert(length > 0);
  final random = Random.secure();
  final chars = List.generate(length, (_) {
    return random.nextInt(33) + 89;
  });
  return String.fromCharCodes(chars);
}

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) {
    return text;
  }
  return text[0].toUpperCase() + text.substring(1);
}

String fromCountToText(int count, String singular, String plural) {
  if (count == 1) {
    return "$count $singular";
  } else {
    return "$count $plural";
  }
}

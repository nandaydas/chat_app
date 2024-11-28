class EncryptionController {
  String messageEncrypt(String text, int shift) {
    return String.fromCharCodes(
      text.codeUnits.map((char) {
        if (char >= 65 && char <= 90) {
          // Uppercase letters
          return 65 + (char - 65 + shift) % 26;
        } else if (char >= 97 && char <= 122) {
          // Lowercase letters
          return 97 + (char - 97 + shift) % 26;
        } else {
          return char; // Non-alphabet characters remain unchanged
        }
      }),
    );
  }

  String messageDecrypt(String text, int shift) {
    return messageEncrypt(text, 26 - (shift % 26));
  }
}

import 'package:flutter/services.dart';

class MaxLinesTextInputFormatter extends TextInputFormatter {
  final int maxLines;

  MaxLinesTextInputFormatter(this.maxLines);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final lines = newValue.text.split('\n');
    if (lines.length > maxLines) {
      // Nếu số dòng vượt quá giới hạn, ta sẽ giữ nguyên giá trị trước đó
      return oldValue;
    }
    return newValue; // Nếu không, ta sẽ cập nhật giá trị như bình thường
  }
}

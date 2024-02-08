// models/vocabulary.dart

class Vocabulary {
  final String id;
  final String text;
  final bool isSubmitted;

  Vocabulary({required this.id, required this.text, this.isSubmitted = false});

  Vocabulary copyWith({String? text, bool? isSubmitted}) {
    return Vocabulary(
      id: this.id,
      text: text ?? this.text,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}

import 'base_page.dart';

class VocabularyPage extends BasePage {
  @override
  _VocabularyPageState createState() => _VocabularyPageState();
}

class _VocabularyPageState extends BasePageState<VocabularyPage> {
  @override
  String get title => "Vocabulary";

  @override
  String get hintText => "Enter vocabulary here";

  @override
  String get preferenceKey => "vocabulary_items";

  @override
  String get type => 'vocabulary';
}

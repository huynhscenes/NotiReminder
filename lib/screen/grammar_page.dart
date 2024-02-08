import 'base_page.dart';

class GrammarPage extends BasePage {
  @override
  _GrammarPageState createState() => _GrammarPageState();
}

class _GrammarPageState extends BasePageState<GrammarPage> {
  @override
  String get title => "Grammar";

  @override
  String get hintText => "Enter grammar here";

  @override
  String get preferenceKey => "grammar_items";

  @override
  String get type => 'grammar';
}

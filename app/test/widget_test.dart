import 'package:escape_your_study_room/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the escape game mission screen', (tester) async {
    await tester.pumpWidget(const EscapeYourStudyRoomApp());

    expect(find.text('Escape the\nStudy Room'), findsOneWidget);

    expect(find.text('Start Mission'), findsOneWidget);

    expect(find.text('Dodge the Flying Books'), findsOneWidget);

    expect(find.text('Jump the Cables'), findsOneWidget);

    expect(find.text('Side-Step the Distractions'), findsOneWidget);
  });
}

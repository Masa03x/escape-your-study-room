import 'package:escape_your_study_room/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the dodge books challenge intro', (tester) async {
    await tester.pumpWidget(const EscapeYourStudyRoomApp());

    expect(find.text('Dodge the\nFlying Books'), findsOneWidget);
    expect(find.text('Start Challenge'), findsOneWidget);
  });
}

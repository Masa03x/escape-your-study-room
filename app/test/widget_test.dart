import 'package:escape_your_study_room/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the Escape Your Study Room intro screen', (tester) async {
    await tester.pumpWidget(const EscapeYourStudyRoomApp());

    await tester.pump();

    expect(find.text('Escape Your\nStudy Room'), findsOneWidget);

    expect(find.text('Start Active Break'), findsOneWidget);

    expect(find.text('YOUR ESCAPE ROUTE'), findsOneWidget);

    expect(find.text('SQUAT'), findsOneWidget);

    expect(find.text('JUMP'), findsOneWidget);

    expect(find.text('MOVE'), findsOneWidget);
  });

  testWidgets('opens the first challenge preview', (tester) async {
    await tester.pumpWidget(const EscapeYourStudyRoomApp());

    await tester.pump();

    await tester.tap(find.text('Start Active Break'));

    await tester.pumpAndSettle();

    expect(find.text('CHALLENGE PREVIEW'), findsOneWidget);

    expect(find.text('MISSION 1'), findsOneWidget);

    expect(find.text('Dodge the Flying Books'), findsOneWidget);

    expect(find.text('Play Mission 1'), findsOneWidget);

    expect(find.text('HOW TO MOVE'), findsOneWidget);
  });
}

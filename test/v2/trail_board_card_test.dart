// test/v2/trail_board_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetwotrail/v2/widget/three_squares.dart';

void main() {
  testWidgets('TitleThreeSquares displays header name, duration badge and footer descriptions',
      (WidgetTester tester) async {
    // Arrange: create the widget wrapped in MaterialApp to provide required
    // context (themes, media queries, etc.).
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: TitleThreeSquares(
          titleText: 'Trail Name Example',
          durationText: '4h',
          summaryTitleText: 'Trail Name Example',
          summaryBodyText: 'A short listing description for the trail.',
          mainImage: AssetImage('assets/help/empty_image.png'),
          secondaryTopImage: AssetImage('assets/help/empty_image.png'),
          secondaryBottomImage: AssetImage('assets/help/empty_image.png'),
          mainAction: (ctx) => Container(),
          padding: EdgeInsets.all(0),
        ),
      ),
    ));

    // Act: allow the widget tree to settle
    await tester.pumpAndSettle();

    // Assert: header text is shown at least once and badge text appears
    expect(find.text('Trail Name Example'), findsWidgets);
    expect(find.text('4h'), findsOneWidget);

    // Assert: footer description is visible
    expect(find.text('A short listing description for the trail.'), findsOneWidget);
  });
}

import 'package:camera_guide/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('camera guide starts with a minimal camera screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byTooltip('Choose guide image'), findsOneWidget);
    expect(find.byTooltip('Take photo'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:image_crop_compress_example/main.dart';

void main() {
  testWidgets('Example app renders', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Image Processor'), findsOneWidget);
    expect(find.text('No image selected.'), findsOneWidget);
  });
}

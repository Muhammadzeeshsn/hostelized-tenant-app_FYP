import 'package:flutter_test/flutter_test.dart';
import 'package:hostelized_tenant_app/main.dart';

void main() {
  testWidgets('app builds', (tester) async {
    await tester.pumpWidget(const App());
  });
}

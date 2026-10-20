import 'package:flutter_test/flutter_test.dart';

import 'package:ldsw_widgets_app/main.dart';

void main() {
  testWidgets('La aplicación muestra los widgets básicos', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AplicacionFlutter());

    expect(find.text('Bienvenido a Flutter'), findsOneWidget);
    expect(find.text('Elemento A'), findsOneWidget);
    expect(find.text('Elemento B'), findsOneWidget);
    expect(find.text('Hola mundo'), findsOneWidget);
  });
}

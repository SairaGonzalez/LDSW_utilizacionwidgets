import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:ldsw_widgets_app/main.dart';

void main() {
  testWidgets('La aplicación muestra los widgets básicos', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AplicacionFlutter());

    expect(find.text('Catálogo de películas'), findsOneWidget);
    expect(find.text('Hello World'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.byIcon(Icons.movie), findsOneWidget);
  });
}

import 'package:checador_express/widgets/common/metric_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MetricCard displays value and title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MetricCard(
            title: 'Empleados activos',
            value: 12,
            icon: Icons.groups_outlined,
            color: Colors.blue,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('12'), findsOneWidget);
    expect(find.text('Empleados activos'), findsOneWidget);
  });
}

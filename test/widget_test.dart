import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:cancha_movil/controllers/theme_controller.dart';
import 'package:cancha_movil/main.dart';

void main() {
  testWidgets('Carga LoginView y muestra botones clave', (WidgetTester tester) async {

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeController()),
        ],
        child: const ReservaSportsApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('ReservaSports'), findsOneWidget);
    expect(find.text('Reservar Cancha'), findsOneWidget);
    expect(find.text('Administrador'), findsOneWidget);
  });
}

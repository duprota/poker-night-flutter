import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poker_night/models/notification.dart';
import 'package:poker_night/providers/notification_provider.dart';
import 'package:poker_night/widgets/notification_badge.dart';

import '../mocks/notification_mocks.dart';

// Mock para o estado de notificação
class MockNotificationState extends Mock implements NotificationState {}

// Mock para o notifier de notificação
class MockNotificationNotifier extends Mock implements NotificationNotifier {}

void main() {
  late MockNotificationState mockNotificationState;
  late MockNotificationNotifier mockNotificationNotifier;

  setUp(() {
    mockNotificationState = MockNotificationState();
    mockNotificationNotifier = MockNotificationNotifier();

    // Configurar o mock do estado de notificação
    when(() => mockNotificationState.unreadCount).thenReturn(3);
    when(() => mockNotificationState.isLoading).thenReturn(false);
    when(() => mockNotificationState.errorMessage).thenReturn(null);
    when(() => mockNotificationState.notifications).thenReturn([]);
  });

  testWidgets('NotificationBadge deve exibir o contador de notificações não lidas', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationProvider.overrideWithValue(
            StateNotifierProvider<NotificationNotifier, NotificationState>((ref) => mockNotificationNotifier)
          ),
          notificationProvider.notifier.overrideWithValue(mockNotificationNotifier),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return NotificationBadge(
                  onTap: () {},
                );
              },
            ),
          ),
        ),
      ),
    );

    // Simular o estado atual
    when(() => mockNotificationNotifier.state).thenReturn(mockNotificationState);

    // Reconstruir o widget com o estado mockado
    await tester.pump();

    // Assert
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('NotificationBadge não deve exibir contador quando unreadCount for 0', (WidgetTester tester) async {
    // Arrange
    when(() => mockNotificationState.unreadCount).thenReturn(0);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationProvider.overrideWithValue(
            StateNotifierProvider<NotificationNotifier, NotificationState>((ref) => mockNotificationNotifier)
          ),
          notificationProvider.notifier.overrideWithValue(mockNotificationNotifier),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return NotificationBadge(
                  onTap: () {},
                );
              },
            ),
          ),
        ),
      ),
    );

    // Simular o estado atual
    when(() => mockNotificationNotifier.state).thenReturn(mockNotificationState);

    // Reconstruir o widget com o estado mockado
    await tester.pump();

    // Assert
    expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    expect(find.text('0'), findsNothing);
  });

  testWidgets('NotificationBadge deve chamar onTap quando clicado', (WidgetTester tester) async {
    // Arrange
    bool wasTapped = false;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationProvider.overrideWithValue(
            StateNotifierProvider<NotificationNotifier, NotificationState>((ref) => mockNotificationNotifier)
          ),
          notificationProvider.notifier.overrideWithValue(mockNotificationNotifier),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return NotificationBadge(
                  onTap: () {
                    wasTapped = true;
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    // Simular o estado atual
    when(() => mockNotificationNotifier.state).thenReturn(mockNotificationState);

    // Reconstruir o widget com o estado mockado
    await tester.pump();

    // Act
    await tester.tap(find.byType(NotificationBadge));

    // Assert
    expect(wasTapped, isTrue);
  });

  testWidgets('NotificationBadge deve usar o ícone personalizado quando fornecido', (WidgetTester tester) async {
    // Arrange
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationProvider.overrideWithValue(
            StateNotifierProvider<NotificationNotifier, NotificationState>((ref) => mockNotificationNotifier)
          ),
          notificationProvider.notifier.overrideWithValue(mockNotificationNotifier),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return NotificationBadge(
                  onTap: () {},
                  icon: Icons.message,
                );
              },
            ),
          ),
        ),
      ),
    );

    // Simular o estado atual
    when(() => mockNotificationNotifier.state).thenReturn(mockNotificationState);

    // Reconstruir o widget com o estado mockado
    await tester.pump();

    // Assert
    expect(find.byIcon(Icons.message), findsOneWidget);
    expect(find.byIcon(Icons.notifications_outlined), findsNothing);
  });

  testWidgets('NotificationBadge deve usar o tamanho personalizado quando fornecido', (WidgetTester tester) async {
    // Arrange
    const customSize = 32.0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationProvider.overrideWithValue(
            StateNotifierProvider<NotificationNotifier, NotificationState>((ref) => mockNotificationNotifier)
          ),
          notificationProvider.notifier.overrideWithValue(mockNotificationNotifier),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return NotificationBadge(
                  onTap: () {},
                  size: customSize,
                );
              },
            ),
          ),
        ),
      ),
    );

    // Simular o estado atual
    when(() => mockNotificationNotifier.state).thenReturn(mockNotificationState);

    // Reconstruir o widget com o estado mockado
    await tester.pump();

    // Assert
    final iconWidget = tester.widget<Icon>(find.byIcon(Icons.notifications_outlined));
    expect(iconWidget.size, equals(customSize));
  });
}

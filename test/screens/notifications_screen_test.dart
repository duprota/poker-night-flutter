import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poker_night/models/notification.dart';
import 'package:poker_night/providers/notification_provider.dart';
import 'package:poker_night/screens/notifications_screen.dart';
import 'package:poker_night/widgets/error_message.dart';
import 'package:poker_night/widgets/loading_indicator.dart';

import '../mocks/notification_mocks.dart';

// Mock para o estado de notificação
class MockNotificationState extends Mock implements NotificationState {}

// Mock para o notifier de notificação
class MockNotificationNotifier extends Mock implements NotificationNotifier {}

void main() {
  late MockNotificationState mockNotificationState;
  late MockNotificationNotifier mockNotificationNotifier;
  late List<AppNotification> sampleNotifications;

  setUp(() {
    mockNotificationState = MockNotificationState();
    mockNotificationNotifier = MockNotificationNotifier();
    sampleNotifications = NotificationTestData.getSampleNotifications();

    // Configurar o mock do notifier de notificação
    when(() => mockNotificationNotifier.loadNotifications()).thenAnswer((_) async {});
    when(() => mockNotificationNotifier.markAsRead(any())).thenAnswer((_) async {});
    when(() => mockNotificationNotifier.markAllAsRead()).thenAnswer((_) async {});
    when(() => mockNotificationNotifier.deleteNotification(any())).thenAnswer((_) async {});
  });

  testWidgets('NotificationsScreen deve exibir indicador de carregamento quando isLoading=true', (WidgetTester tester) async {
    // Arrange
    when(() => mockNotificationState.isLoading).thenReturn(true);
    when(() => mockNotificationState.notifications).thenReturn([]);
    when(() => mockNotificationState.errorMessage).thenReturn(null);
    when(() => mockNotificationState.unreadCount).thenReturn(0);
    when(() => mockNotificationNotifier.state).thenReturn(mockNotificationState);

    // Act
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationProvider.overrideWithValue(
            StateNotifierProvider<NotificationNotifier, NotificationState>((ref) => mockNotificationNotifier)
          ),
          notificationProvider.notifier.overrideWithValue(mockNotificationNotifier),
        ],
        child: const MaterialApp(
          home: NotificationsScreen(),
        ),
      ),
    );

    // Assert
    expect(find.byType(LoadingIndicator), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    expect(find.byType(ErrorMessage), findsNothing);
  });

  testWidgets('NotificationsScreen deve exibir mensagem de erro quando errorMessage não for nulo', (WidgetTester tester) async {
    // Arrange
    when(() => mockNotificationState.isLoading).thenReturn(false);
    when(() => mockNotificationState.notifications).thenReturn([]);
    when(() => mockNotificationState.errorMessage).thenReturn('Erro ao carregar notificações');
    when(() => mockNotificationState.unreadCount).thenReturn(0);
    when(() => mockNotificationNotifier.state).thenReturn(mockNotificationState);

    // Act
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationProvider.overrideWithValue(
            StateNotifierProvider<NotificationNotifier, NotificationState>((ref) => mockNotificationNotifier)
          ),
          notificationProvider.notifier.overrideWithValue(mockNotificationNotifier),
        ],
        child: const MaterialApp(
          home: NotificationsScreen(),
        ),
      ),
    );

    // Assert
    expect(find.byType(ErrorMessage), findsOneWidget);
    expect(find.text('Erro ao carregar notificações'), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    expect(find.byType(LoadingIndicator), findsNothing);
  });

  testWidgets('NotificationsScreen deve exibir lista de notificações quando carregadas com sucesso', (WidgetTester tester) async {
    // Arrange
    when(() => mockNotificationState.isLoading).thenReturn(false);
    when(() => mockNotificationState.notifications).thenReturn(sampleNotifications);
    when(() => mockNotificationState.errorMessage).thenReturn(null);
    when(() => mockNotificationState.unreadCount).thenReturn(2);
    when(() => mockNotificationNotifier.state).thenReturn(mockNotificationState);

    // Act
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationProvider.overrideWithValue(
            StateNotifierProvider<NotificationNotifier, NotificationState>((ref) => mockNotificationNotifier)
          ),
          notificationProvider.notifier.overrideWithValue(mockNotificationNotifier),
        ],
        child: const MaterialApp(
          home: NotificationsScreen(),
        ),
      ),
    );

    // Assert
    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(Dismissible), findsNWidgets(sampleNotifications.length));
    
    // Verificar se os títulos das notificações são exibidos
    for (final notification in sampleNotifications) {
      expect(find.text(notification.title), findsOneWidget);
    }
  });

  testWidgets('NotificationsScreen deve exibir mensagem quando não houver notificações', (WidgetTester tester) async {
    // Arrange
    when(() => mockNotificationState.isLoading).thenReturn(false);
    when(() => mockNotificationState.notifications).thenReturn([]);
    when(() => mockNotificationState.errorMessage).thenReturn(null);
    when(() => mockNotificationState.unreadCount).thenReturn(0);
    when(() => mockNotificationNotifier.state).thenReturn(mockNotificationState);

    // Act
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationProvider.overrideWithValue(
            StateNotifierProvider<NotificationNotifier, NotificationState>((ref) => mockNotificationNotifier)
          ),
          notificationProvider.notifier.overrideWithValue(mockNotificationNotifier),
        ],
        child: const MaterialApp(
          home: NotificationsScreen(),
        ),
      ),
    );

    // Assert
    expect(find.text('Você não tem notificações'), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
  });

  testWidgets('NotificationsScreen deve chamar markAsRead quando uma notificação for tocada', (WidgetTester tester) async {
    // Arrange
    when(() => mockNotificationState.isLoading).thenReturn(false);
    when(() => mockNotificationState.notifications).thenReturn(sampleNotifications);
    when(() => mockNotificationState.errorMessage).thenReturn(null);
    when(() => mockNotificationState.unreadCount).thenReturn(2);
    when(() => mockNotificationNotifier.state).thenReturn(mockNotificationState);

    // Act
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationProvider.overrideWithValue(
            StateNotifierProvider<NotificationNotifier, NotificationState>((ref) => mockNotificationNotifier)
          ),
          notificationProvider.notifier.overrideWithValue(mockNotificationNotifier),
        ],
        child: const MaterialApp(
          home: NotificationsScreen(),
        ),
      ),
    );

    // Tocar na primeira notificação
    await tester.tap(find.text(sampleNotifications.first.title));
    await tester.pump();

    // Assert
    verify(() => mockNotificationNotifier.markAsRead(sampleNotifications.first.id)).called(1);
  });

  testWidgets('NotificationsScreen deve chamar markAllAsRead quando o botão for pressionado', (WidgetTester tester) async {
    // Arrange
    when(() => mockNotificationState.isLoading).thenReturn(false);
    when(() => mockNotificationState.notifications).thenReturn(sampleNotifications);
    when(() => mockNotificationState.errorMessage).thenReturn(null);
    when(() => mockNotificationState.unreadCount).thenReturn(2);
    when(() => mockNotificationNotifier.state).thenReturn(mockNotificationState);

    // Act
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationProvider.overrideWithValue(
            StateNotifierProvider<NotificationNotifier, NotificationState>((ref) => mockNotificationNotifier)
          ),
          notificationProvider.notifier.overrideWithValue(mockNotificationNotifier),
        ],
        child: const MaterialApp(
          home: NotificationsScreen(),
        ),
      ),
    );

    // Encontrar e pressionar o botão "Marcar todas como lidas"
    await tester.tap(find.text('Marcar todas como lidas'));
    await tester.pump();

    // Assert
    verify(() => mockNotificationNotifier.markAllAsRead()).called(1);
  });

  testWidgets('NotificationsScreen deve chamar deleteNotification quando uma notificação for deslizada', (WidgetTester tester) async {
    // Arrange
    when(() => mockNotificationState.isLoading).thenReturn(false);
    when(() => mockNotificationState.notifications).thenReturn(sampleNotifications);
    when(() => mockNotificationState.errorMessage).thenReturn(null);
    when(() => mockNotificationState.unreadCount).thenReturn(2);
    when(() => mockNotificationNotifier.state).thenReturn(mockNotificationState);

    // Act
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationProvider.overrideWithValue(
            StateNotifierProvider<NotificationNotifier, NotificationState>((ref) => mockNotificationNotifier)
          ),
          notificationProvider.notifier.overrideWithValue(mockNotificationNotifier),
        ],
        child: const MaterialApp(
          home: NotificationsScreen(),
        ),
      ),
    );

    // Deslizar a primeira notificação para excluí-la
    await tester.drag(find.text(sampleNotifications.first.title), const Offset(-500, 0));
    await tester.pumpAndSettle();

    // Assert
    verify(() => mockNotificationNotifier.deleteNotification(sampleNotifications.first.id)).called(1);
  });

  testWidgets('NotificationsScreen deve exibir indicador de não lida para notificações não lidas', (WidgetTester tester) async {
    // Arrange
    when(() => mockNotificationState.isLoading).thenReturn(false);
    when(() => mockNotificationState.notifications).thenReturn(sampleNotifications);
    when(() => mockNotificationState.errorMessage).thenReturn(null);
    when(() => mockNotificationState.unreadCount).thenReturn(2);
    when(() => mockNotificationNotifier.state).thenReturn(mockNotificationState);

    // Act
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          notificationProvider.overrideWithValue(
            StateNotifierProvider<NotificationNotifier, NotificationState>((ref) => mockNotificationNotifier)
          ),
          notificationProvider.notifier.overrideWithValue(mockNotificationNotifier),
        ],
        child: const MaterialApp(
          home: NotificationsScreen(),
        ),
      ),
    );

    // Assert
    // Contar o número de indicadores de não lida (que são containers com cor primária)
    final unreadIndicators = find.byWidgetPredicate((widget) {
      if (widget is Container) {
        final container = widget;
        return container.decoration is BoxDecoration && 
               (container.decoration as BoxDecoration).color != null;
      }
      return false;
    });
    
    // Deve haver 2 notificações não lidas no conjunto de dados de exemplo
    expect(unreadIndicators, findsWidgets);
  });
}

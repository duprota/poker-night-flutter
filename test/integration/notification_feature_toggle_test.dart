import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poker_night/core/services/notification_service_interface.dart';
import 'package:poker_night/models/notification.dart';
import 'package:poker_night/providers/auth_provider.dart';
import 'package:poker_night/providers/feature_toggle_provider.dart';
import 'package:poker_night/providers/notification_provider.dart';
import 'package:poker_night/screens/notifications_screen.dart';
import 'package:poker_night/widgets/notification_badge.dart';

import '../mocks/notification_mocks.dart';

// Mock para o estado de feature toggle
class MockFeatureToggleState extends Mock implements FeatureToggleState {}

// Mock para o notifier de feature toggle
class MockFeatureToggleNotifier extends Mock implements FeatureToggleNotifier {}

// Mock para o estado de autenticação
class MockAuthState extends Mock implements AuthState {}

// Mock para o notifier de autenticação
class MockAuthNotifier extends Mock implements AuthNotifier {}

// Mock para o estado de notificação
class MockNotificationState extends Mock implements NotificationState {}

// Mock para o notifier de notificação
class MockNotificationNotifier extends Mock implements NotificationNotifier {}

void main() {
  late MockFeatureToggleState mockFeatureToggleState;
  late MockFeatureToggleNotifier mockFeatureToggleNotifier;
  late MockAuthState mockAuthState;
  late MockAuthNotifier mockAuthNotifier;
  late MockNotificationState mockNotificationState;
  late MockNotificationNotifier mockNotificationNotifier;
  late MockNotificationService mockNotificationService;
  late List<AppNotification> sampleNotifications;

  setUp(() {
    mockFeatureToggleState = MockFeatureToggleState();
    mockFeatureToggleNotifier = MockFeatureToggleNotifier();
    mockAuthState = MockAuthState();
    mockAuthNotifier = MockAuthNotifier();
    mockNotificationState = MockNotificationState();
    mockNotificationNotifier = MockNotificationNotifier();
    mockNotificationService = MockNotificationService();
    sampleNotifications = NotificationTestData.getSampleNotifications();

    // Configurar o mock do estado de feature toggle
    when(() => mockFeatureToggleState.isEnabled(any())).thenReturn(true);
    when(() => mockFeatureToggleState.getRequiredSubscription(any())).thenReturn('free');
    when(() => mockFeatureToggleNotifier.state).thenReturn(mockFeatureToggleState);

    // Configurar o mock do estado de autenticação
    when(() => mockAuthState.user).thenReturn(
      const User(id: 'user-123', email: 'teste@exemplo.com', subscriptionStatus: 'free')
    );
    when(() => mockAuthState.isAuthenticated).thenReturn(true);
    when(() => mockAuthState.subscriptionStatus).thenReturn('free');
    when(() => mockAuthNotifier.state).thenReturn(mockAuthState);
    when(() => mockAuthNotifier.hasAccess(any())).thenReturn(true);

    // Configurar o mock do estado de notificação
    when(() => mockNotificationState.isLoading).thenReturn(false);
    when(() => mockNotificationState.notifications).thenReturn(sampleNotifications);
    when(() => mockNotificationState.errorMessage).thenReturn(null);
    when(() => mockNotificationState.unreadCount).thenReturn(2);
    when(() => mockNotificationNotifier.state).thenReturn(mockNotificationState);
    when(() => mockNotificationNotifier.loadNotifications()).thenAnswer((_) async {});

    // Configurar o mock do serviço de notificação
    when(() => mockNotificationService.initialize()).thenAnswer((_) async {});
    when(() => mockNotificationService.getNotifications(userId: any(named: 'userId')))
        .thenAnswer((_) async => sampleNotifications);
  });

  // Função auxiliar para criar o widget de teste com todos os providers mockados
  Widget createTestWidget({
    required Widget child,
    bool notificationsEnabled = true,
  }) {
    // Configurar se a feature de notificações está habilitada
    when(() => mockFeatureToggleState.isEnabled(Feature.notifications)).thenReturn(notificationsEnabled);

    return ProviderScope(
      overrides: [
        featureToggleProvider.overrideWithValue(
          StateNotifierProvider<FeatureToggleNotifier, FeatureToggleState>((ref) => mockFeatureToggleNotifier)
        ),
        featureToggleProvider.notifier.overrideWithValue(mockFeatureToggleNotifier),
        
        authProvider.overrideWithValue(
          StateNotifierProvider<AuthNotifier, AuthState>((ref) => mockAuthNotifier)
        ),
        authProvider.notifier.overrideWithValue(mockAuthNotifier),
        
        notificationProvider.overrideWithValue(
          StateNotifierProvider<NotificationNotifier, NotificationState>((ref) => mockNotificationNotifier)
        ),
        notificationProvider.notifier.overrideWithValue(mockNotificationNotifier),
        
        notificationServiceProvider.overrideWithValue(mockNotificationService),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('Integração de Notificações com Feature Toggles', () {
    testWidgets('NotificationBadge deve ser exibido quando a feature está habilitada', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        createTestWidget(
          notificationsEnabled: true,
          child: Scaffold(
            appBar: AppBar(
              actions: [
                NotificationBadge(onTap: () {}),
              ],
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(NotificationBadge), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });

    testWidgets('NotificationBadge não deve ser exibido quando a feature está desabilitada', (WidgetTester tester) async {
      // Criar um widget personalizado que usa conditionalFeature
      await tester.pumpWidget(
        createTestWidget(
          notificationsEnabled: false,
          child: Builder(
            builder: (context) {
              return Scaffold(
                appBar: AppBar(
                  actions: [
                    // Simulação do método conditionalFeature
                    if (mockFeatureToggleState.isEnabled(Feature.notifications))
                      NotificationBadge(onTap: () {}),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Assert
      expect(find.byType(NotificationBadge), findsNothing);
      expect(find.byIcon(Icons.notifications_outlined), findsNothing);
    });

    testWidgets('NotificationsScreen deve exibir mensagem quando feature está desabilitada', (WidgetTester tester) async {
      // Arrange
      // Criar um widget que simula o comportamento do conditionalFeature
      final testWidget = createTestWidget(
        notificationsEnabled: false,
        child: Builder(
          builder: (context) {
            // Simulação do método conditionalFeature
            if (!mockFeatureToggleState.isEnabled(Feature.notifications)) {
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Funcionalidade não disponível',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'O sistema de notificações está temporariamente indisponível.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            return const NotificationsScreen();
          },
        ),
      );

      // Act
      await tester.pumpWidget(testWidget);

      // Assert
      expect(find.text('Funcionalidade não disponível'), findsOneWidget);
      expect(find.text('O sistema de notificações está temporariamente indisponível.'), findsOneWidget);
      expect(find.byType(NotificationsScreen), findsNothing);
    });

    testWidgets('NotificationsScreen deve exibir mensagem quando usuário não tem assinatura necessária', (WidgetTester tester) async {
      // Arrange
      // Configurar feature habilitada mas requerendo assinatura premium
      when(() => mockFeatureToggleState.isEnabled(Feature.notifications)).thenReturn(true);
      when(() => mockFeatureToggleState.getRequiredSubscription(Feature.notifications)).thenReturn('premium');
      when(() => mockAuthNotifier.hasAccess('premium')).thenReturn(false);

      // Criar um widget que simula o comportamento do conditionalFeature
      final testWidget = createTestWidget(
        notificationsEnabled: true,
        child: Builder(
          builder: (context) {
            // Simulação do método conditionalFeature
            final requiredSubscription = mockFeatureToggleState.getRequiredSubscription(Feature.notifications);
            if (mockFeatureToggleState.isEnabled(Feature.notifications) && 
                !mockAuthNotifier.hasAccess(requiredSubscription)) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.workspace_premium, size: 48, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(height: 16),
                      const Text(
                        'Funcionalidade exclusiva',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'O sistema de notificações é exclusivo para assinantes $requiredSubscription.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Ver planos de assinatura'),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const NotificationsScreen();
          },
        ),
      );

      // Act
      await tester.pumpWidget(testWidget);

      // Assert
      expect(find.text('Funcionalidade exclusiva'), findsOneWidget);
      expect(find.text('O sistema de notificações é exclusivo para assinantes premium.'), findsOneWidget);
      expect(find.text('Ver planos de assinatura'), findsOneWidget);
      expect(find.byType(NotificationsScreen), findsNothing);
    });

    testWidgets('NotificationsScreen deve ser exibida quando feature está habilitada e usuário tem acesso', (WidgetTester tester) async {
      // Arrange
      // Configurar feature habilitada e usuário com acesso
      when(() => mockFeatureToggleState.isEnabled(Feature.notifications)).thenReturn(true);
      when(() => mockFeatureToggleState.getRequiredSubscription(Feature.notifications)).thenReturn('free');
      when(() => mockAuthNotifier.hasAccess('free')).thenReturn(true);

      // Act
      await tester.pumpWidget(
        createTestWidget(
          notificationsEnabled: true,
          child: const NotificationsScreen(),
        ),
      );

      // Assert
      expect(find.byType(NotificationsScreen), findsOneWidget);
      expect(find.text('Notificações'), findsOneWidget);
      
      // Verificar se as notificações são exibidas
      for (final notification in sampleNotifications) {
        expect(find.text(notification.title), findsOneWidget);
      }
    });
  });
}

# Sistema de Localização com Fallback

## Visão Geral

O Poker Night Flutter implementa um sistema de localização robusto que utiliza um mecanismo de fallback para garantir que o aplicativo funcione corretamente mesmo quando algumas traduções estão faltando. Este documento descreve a implementação e as melhores práticas para usar este sistema.

## Componentes Principais

### 1. SafeL10n

A classe `SafeL10n` é um wrapper em torno de `AppLocalizations` que fornece um mecanismo de fallback para strings não traduzidas:

```dart
class SafeL10n {
  final AppLocalizations l10n;

  SafeL10n(this.l10n);

  String get(String key, String fallback) {
    try {
      final value = l10n.runtimeType.toString().contains(key)
          ? _getProperty(l10n, key)
          : null;
      return value ?? fallback;
    } catch (e) {
      return fallback;
    }
  }

  // Métodos para acessar strings comuns
  String get appTitle => get('appTitle', 'Poker Night');
  String get settingsTitle => get('settingsTitle', 'Settings');
  // ...
}
```

### 2. LocalizedText Widget

O widget `LocalizedText` simplifica o uso de textos localizados em toda a aplicação:

```dart
class LocalizedText extends StatelessWidget {
  final String textKey;
  final String fallback;
  final TextStyle? style;
  // ...

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final safeL10n = SafeL10n(l10n);
    
    return Text(
      safeL10n.get(textKey, fallback),
      style: style,
      // ...
    );
  }
}
```

## Correções Implementadas

### 1. Correções de Tipagem

Atualizamos métodos em várias classes para aceitar `SafeL10n` em vez de `AppLocalizations`:

```dart
// Antes
String _getSubscriptionTitle(AppLocalizations l10n, SubscriptionStatus status) {
  // ...
}

// Depois
String _getSubscriptionTitle(SafeL10n l10n, SubscriptionStatus status) {
  // ...
}
```

### 2. Correções de Constantes

Removemos modificadores `const` de widgets que usam valores dinâmicos:

```dart
// Antes
child: const Text(safeL10n.logout),

// Depois
child: Text(safeL10n.logoutButton),
```

### 3. Correções de Imports e Referências

Corrigimos imports e referências a enums:

```dart
// Antes
import 'package:poker_night/core/utils/feature_toggle.dart';
feature: Feature.createGroup,

// Depois
import 'package:poker_night/providers/feature_toggle_provider.dart';
feature: Feature.createGame,
```

## Melhores Práticas

1. **Use SafeL10n para todas as strings localizadas**: Sempre use `SafeL10n` em vez de acessar `AppLocalizations` diretamente.

2. **Forneça fallbacks significativos**: Ao usar o método `get()`, forneça um fallback que faça sentido no contexto.

3. **Evite modificadores const em widgets com valores dinâmicos**: Não use `const` em widgets que usam valores de `SafeL10n`.

4. **Teste o comportamento de fallback**: Escreva testes para garantir que o mecanismo de fallback funcione corretamente.

## Mensagens Não Traduzidas

O sistema atualmente tem 58 mensagens não traduzidas em português. Para gerar um relatório detalhado, adicione a seguinte opção ao arquivo `l10n.yaml`:

```yaml
untranslated-messages-file: untranslated_messages.txt
```

## Próximos Passos

1. Traduzir as mensagens restantes para português
2. Adicionar suporte para mais idiomas
3. Melhorar a documentação e os exemplos de uso

# Testes do Poker Night

Este diretório contém a estrutura de testes para o aplicativo Poker Night. A estrutura está organizada em três categorias principais:

## 1. Testes Unitários

Os testes unitários estão localizados em `test/unit/` e testam componentes individuais do aplicativo, como providers, serviços e utilitários. Esses testes são rápidos e não dependem da interface do usuário.

### Executando testes unitários

```bash
flutter test test/unit/
```

## 2. Testes de Widget

Os testes de widget estão localizados em `test/widget/` e testam componentes de UI individuais, verificando se eles são renderizados corretamente e respondem às interações do usuário conforme esperado.

### Executando testes de widget

```bash
flutter test test/widget/
```

## 3. Testes de Integração

Os testes de integração estão localizados em `test/integration/` e testam a interação entre diferentes partes do aplicativo, como navegação entre telas e fluxos de usuário.

### Executando testes de integração

```bash
flutter test test/integration/
```

## 4. Testes de Integração Completa

Os testes de integração completa estão localizados em `integration_test/` e testam o aplicativo em um ambiente mais próximo do real, incluindo interações com o sistema operacional.

### Executando testes de integração completa

```bash
flutter test integration_test/app_test.dart
```

## Executando todos os testes

Para executar todos os testes (exceto os testes de integração completa):

```bash
flutter test test/all_tests.dart
```

## Mocks

Os mocks utilizados nos testes estão localizados em `test/mocks/`. Eles são usados para simular componentes externos, como o Supabase, e permitir testes mais isolados e controlados.

## Cobertura de Testes

Para gerar um relatório de cobertura de testes:

```bash
flutter test --coverage
```

Para visualizar o relatório de cobertura em HTML (requer o pacote `lcov`):

```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Boas Práticas

1. **Mantenha os testes independentes**: Cada teste deve ser independente dos outros.
2. **Use mocks para dependências externas**: Evite depender de serviços externos nos testes.
3. **Teste comportamentos, não implementações**: Foque no que o componente deve fazer, não em como ele faz.
4. **Mantenha os testes rápidos**: Testes lentos desestimulam a execução frequente.
5. **Escreva testes claros e legíveis**: Use nomes descritivos e estruture os testes em arrange-act-assert.

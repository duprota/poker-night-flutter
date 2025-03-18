# Melhorar robustez do aplicativo para carregamento e visualização web

## Descrição

Este PR implementa várias melhorias de robustez no aplicativo Poker Night Flutter para resolver problemas de carregamento e visualização, especialmente em modo web:

### Melhorias implementadas:

1. **Tratamento de erros na inicialização do Supabase**:
   - Adicionamos try/catch para capturar e tratar erros durante a inicialização
   - Permitimos que o aplicativo continue mesmo com erros de conexão em modo web

2. **Melhorias no serviço de deep linking**:
   - Implementamos verificação para evitar processar o mesmo deep link repetidamente
   - Adicionamos filtros para reduzir logs desnecessários no console
   - Ignoramos deep links para a rota raiz em modo web

3. **Cliente Supabase mais robusto**:
   - Criamos um cliente mock para desenvolvimento quando o Supabase não está disponível
   - Adicionamos tratamento de erros em métodos críticos como `currentUser` e `isAuthenticated`

4. **Melhorias na SplashScreen**:
   - Garantimos que o redirecionamento aconteça mesmo em caso de erros
   - Adicionamos tratamento de exceções para evitar que o aplicativo trave

5. **Aplicativo principal mais robusto**:
   - Adicionamos tratamento de erros no método `build` do `PokerNightApp`
   - Isolamos a inicialização de serviços como notificações e deep links

6. **Versão simplificada para testes**:
   - Criamos uma versão simplificada do aplicativo para testes rápidos

### Testes realizados:
- Verificado o carregamento do aplicativo em modo web
- Testado o funcionamento com e sem conexão com o Supabase
- Verificado o redirecionamento correto na SplashScreen

### Próximos passos:
- Adicionar testes automatizados para verificar a robustez do aplicativo
- Implementar mecanismo de retry para reconexão com o Supabase

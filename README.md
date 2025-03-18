# Poker Night

Aplicativo de gerenciamento de jogos de Poker desenvolvido com Flutter e Supabase.

## Sobre o Projeto

Poker Night é um aplicativo multiplataforma para gerenciar suas noites de poker com amigos. Controle jogadores, partidas, fichas e muito mais com uma interface moderna e intuitiva.

## Funcionalidades

- **Autenticação de Usuários**
  - Login/Registro
  - Persistência de sessão

- **Gerenciamento de Jogos**
  - Criar novos jogos
  - Listar jogos existentes
  - Visualizar detalhes de cada jogo

- **Gerenciamento de Jogadores**
  - Adicionar/remover jogadores
  - Rastrear pontuação e fichas
  - Perfil de jogadores

## Tecnologias Utilizadas

- **Flutter** - Framework para desenvolvimento multiplataforma
- **Supabase** - Backend e autenticação
- **Riverpod** - Gerenciamento de estado
- **GoRouter** - Navegação

## Paleta de Cores

- Background: #1A1B1E
- Card backgrounds: #222222
- Primary purple: #8B5CF6
- Secondary blue: #0EA5E9
- Accent pink: #D946EF
- Destructive orange: #F97316
- Success green: #10B981
- Error red: #EF4444
- Text primary: #FFFFFF
- Text secondary: #F1F0FB

## Configuração do Projeto

### Pré-requisitos

- Flutter SDK (versão 3.x ou superior)
- Dart SDK (versão 3.x ou superior)
- Conta no Supabase

### Instalação

1. Clone o repositório
   ```
   git clone https://github.com/duprota/poker-night-flutter.git
   ```

2. Instale as dependências
   ```
   flutter pub get
   ```

3. Configure o Supabase
   - Crie um projeto no [Supabase](https://supabase.com)
   - Atualize as credenciais em `lib/core/constants/supabase_constants.dart`

4. Execute o aplicativo
   ```
   flutter run
   ```

## Estrutura do Projeto

```
lib/
├── core/
│   ├── constants/
│   ├── router/
│   ├── services/
│   └── theme/
├── features/
│   ├── auth/
│   ├── games/
│   └── players/
└── shared/
    ├── providers/
    └── widgets/
```

## Contribuição

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues e pull requests.

## Licença

Este projeto está licenciado sob a licença MIT - veja o arquivo LICENSE para mais detalhes.

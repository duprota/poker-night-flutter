# Sistema de Grupos do Poker Night

## Visão Geral

O sistema de grupos do Poker Night permite que os usuários criem e gerenciem grupos de jogadores para organizar jogos de poker. Os grupos facilitam o agendamento de jogos, o acompanhamento de estatísticas coletivas e a comunicação entre jogadores regulares.

## Modelos de Dados

### Grupo (Group)

O modelo principal que representa um grupo de jogadores.

```dart
class Group {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? avatarUrl;
  final bool isPrivate;
  
  // Construtor e métodos
}
```

### Membro do Grupo (GroupMember)

Representa a associação de um jogador a um grupo, incluindo sua função (role).

```dart
enum MemberRole { owner, admin, member }

class GroupMember {
  final String id;
  final String groupId;
  final String userId;
  final MemberRole role;
  final DateTime joinedAt;
  final DateTime? lastActive;
  
  // Construtor e métodos
}
```

### Convite para Grupo (GroupInvitation)

Representa um convite enviado a um jogador para se juntar a um grupo.

```dart
enum InvitationStatus { pending, accepted, rejected, expired }

class GroupInvitation {
  final String id;
  final String groupId;
  final String inviterId;
  final String inviteeId;
  final DateTime createdAt;
  final DateTime expiresAt;
  final InvitationStatus status;
  
  // Construtor e métodos
}
```

### Atividade do Grupo (GroupActivity)

Registra atividades importantes que ocorrem dentro de um grupo.

```dart
enum ActivityType { 
  memberJoined, 
  memberLeft, 
  gameScheduled, 
  gameCompleted, 
  groupUpdated 
}

class GroupActivity {
  final String id;
  final String groupId;
  final String actorId;
  final ActivityType type;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;
  
  // Construtor e métodos
}
```

## Fluxos de Usuário

### Criação de Grupo

1. O usuário acessa a tela de Grupos
2. Seleciona a opção "Criar Novo Grupo"
3. Preenche informações como nome, descrição e configurações de privacidade
4. Confirma a criação do grupo
5. É automaticamente definido como proprietário (owner) do grupo

### Convite de Membros

1. O proprietário ou administrador do grupo acessa os detalhes do grupo
2. Seleciona a opção "Convidar Jogadores"
3. Busca jogadores por nome de usuário ou e-mail
4. Envia convites para os jogadores selecionados
5. Os convidados recebem notificações e podem aceitar ou rejeitar o convite

### Gerenciamento de Membros

1. O proprietário ou administrador acessa a lista de membros do grupo
2. Pode promover membros a administradores
3. Pode remover membros do grupo
4. Pode transferir a propriedade do grupo para outro membro

### Agendamento de Jogos

1. Qualquer membro pode propor um novo jogo no grupo
2. Define data, hora, local e outras configurações
3. Outros membros recebem notificações e podem confirmar participação
4. O sistema registra o jogo e envia lembretes aos participantes

## Telas

### Tela de Lista de Grupos (GroupsScreen)

Exibe todos os grupos aos quais o usuário pertence, com opções para criar novos grupos ou buscar grupos existentes.

### Tela de Detalhes do Grupo (GroupDetailsScreen)

Mostra informações detalhadas sobre um grupo específico, incluindo:
- Informações básicas (nome, descrição, avatar)
- Lista de membros
- Jogos agendados
- Histórico de atividades
- Opções de gerenciamento (para proprietários e administradores)

### Tela de Convite para Grupo (GroupInvitationScreen)

Permite que usuários visualizem e respondam a convites recebidos para participar de grupos.

## Integração com o Supabase

O sistema de grupos utiliza tabelas no Supabase para armazenar e gerenciar os dados:

```sql
-- Tabela de grupos
CREATE TABLE groups (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  description TEXT,
  owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE,
  avatar_url TEXT,
  is_private BOOLEAN DEFAULT FALSE,
  
  CONSTRAINT name_length CHECK (char_length(name) >= 3 AND char_length(name) <= 50)
);

-- Tabela de membros do grupo
CREATE TABLE group_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('owner', 'admin', 'member')),
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_active TIMESTAMP WITH TIME ZONE,
  
  UNIQUE(group_id, user_id)
);

-- Tabela de convites para grupo
CREATE TABLE group_invitations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  inviter_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  invitee_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('pending', 'accepted', 'rejected', 'expired')),
  
  UNIQUE(group_id, invitee_id, status) WHERE status = 'pending'
);

-- Tabela de atividades do grupo
CREATE TABLE group_activities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
  actor_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE SET NULL,
  type TEXT NOT NULL,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  metadata JSONB
);
```

## Gerenciamento de Estado com Riverpod

O sistema utiliza o Riverpod para gerenciar o estado relacionado aos grupos:

```dart
// Estado dos grupos
class GroupState {
  final List<Group> groups;
  final bool isLoading;
  final String? error;
  
  // Construtor e métodos
}

// Notificador para gerenciar grupos
class GroupNotifier extends StateNotifier<GroupState> {
  final SupabaseClient client;
  
  GroupNotifier(this.client) : super(GroupState(groups: [], isLoading: false));
  
  // Métodos para buscar, criar, atualizar e excluir grupos
  Future<void> fetchGroups() async { /* ... */ }
  Future<void> createGroup(Group group) async { /* ... */ }
  Future<void> updateGroup(Group group) async { /* ... */ }
  Future<void> deleteGroup(String groupId) async { /* ... */ }
  
  // Métodos para gerenciar membros
  Future<void> inviteMember(String groupId, String userId) async { /* ... */ }
  Future<void> removeMember(String groupId, String userId) async { /* ... */ }
  Future<void> updateMemberRole(String groupId, String userId, MemberRole role) async { /* ... */ }
  
  // Métodos para gerenciar convites
  Future<void> respondToInvitation(String invitationId, bool accept) async { /* ... */ }
}

// Provider para o notificador de grupos
final groupProvider = StateNotifierProvider<GroupNotifier, GroupState>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return GroupNotifier(client);
});
```

## Integração com o Sistema de Localização

O sistema de grupos utiliza o sistema de localização com fallback para garantir que todas as strings sejam exibidas corretamente, mesmo quando traduções estão faltando:

```dart
// Exemplo de uso do SafeL10n na tela de grupos
class GroupsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final safeL10n = SafeL10n(AppLocalizations.of(context)!);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(safeL10n.get('groupsTitle', 'Groups')),
      ),
      body: // ...
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Lógica para criar um novo grupo
        },
        tooltip: safeL10n.get('createGroupTooltip', 'Create new group'),
        child: Icon(Icons.add),
      ),
    );
  }
}
```

## Próximos Passos

1. **Implementar notificações em tempo real**: Utilizar os canais em tempo real do Supabase para notificar os usuários sobre atividades nos grupos.
2. **Adicionar suporte a imagens de perfil de grupo**: Permitir que os usuários façam upload de imagens para personalizar seus grupos.
3. **Implementar estatísticas de grupo**: Adicionar visualizações de estatísticas agregadas para todos os jogos realizados dentro de um grupo.
4. **Melhorar a experiência de convite**: Adicionar suporte para convites via link compartilhável e códigos QR.

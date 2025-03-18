import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_night/core/utils/l10n_extensions.dart';
import 'package:poker_night/providers/group_provider.dart';
import 'package:poker_night/features/groups/domain/models/index.dart';
import 'package:poker_night/widgets/common/app_bar_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GroupDetailsScreen extends ConsumerStatefulWidget {
  final String groupId;

  const GroupDetailsScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  ConsumerState<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends ConsumerState<GroupDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Buscar dados do grupo se necessário
    Future.microtask(() {
      final groupState = ref.read(groupProvider);
      if (groupState.groups.isEmpty) {
        ref.read(groupProvider.notifier).fetchGroups();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeL10n = SafeL10n(AppLocalizations.of(context)!);
    final groupState = ref.watch(groupProvider);
    
    // Encontrar o grupo atual
    final group = groupState.groups.firstWhere(
      (g) => g.id == widget.groupId,
      orElse: () => Group(
        id: widget.groupId,
        name: safeL10n.get('loading', 'Carregando...'),
        description: '',
        ownerId: '',
        createdAt: DateTime.now(),
      ),
    );

    return Scaffold(
      appBar: AppBarWidget(
        title: group.name,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showGroupOptions(context, group, safeL10n),
          ),
        ],
      ),
      body: groupState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(group, safeL10n),
    );
  }

  Widget _buildBody(Group group, SafeL10n safeL10n) {
    return Column(
      children: [
        _buildGroupHeader(group, safeL10n),
        TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: safeL10n.get('members', 'Membros')),
            Tab(text: safeL10n.get('games', 'Jogos')),
            Tab(text: safeL10n.get('activities', 'Atividades')),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMembersTab(safeL10n),
              _buildGamesTab(safeL10n),
              _buildActivitiesTab(safeL10n),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGroupHeader(Group group, SafeL10n safeL10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                child: group.avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          group.avatarUrl!,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Text(
                            group.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      )
                    : Text(
                        group.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(fontSize: 28),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          group.isPrivate ? Icons.lock : Icons.lock_open,
                          size: 16,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          group.isPrivate
                              ? safeL10n.get('privateGroup', 'Grupo privado')
                              : safeL10n.get('publicGroup', 'Grupo público'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      safeL10n.get(
                        'groupCreatedAt',
                        'Criado em {date}',
                        args: {'date': _formatDate(group.createdAt)},
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (group.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              group.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMembersTab(SafeL10n safeL10n) {
    // Aqui seria implementada a lista de membros do grupo
    // Por enquanto, apenas um placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group,
            size: 64,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            safeL10n.get('membersTabPlaceholder', 'Lista de membros do grupo'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _showInviteMemberDialog(context, safeL10n),
            icon: const Icon(Icons.person_add),
            label: Text(safeL10n.get('inviteMember', 'Convidar membro')),
          ),
        ],
      ),
    );
  }

  Widget _buildGamesTab(SafeL10n safeL10n) {
    // Aqui seria implementada a lista de jogos do grupo
    // Por enquanto, apenas um placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.casino,
            size: 64,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            safeL10n.get('gamesTabPlaceholder', 'Jogos do grupo'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Navegação para tela de criação de jogo
            },
            icon: const Icon(Icons.add),
            label: Text(safeL10n.get('scheduleGame', 'Agendar jogo')),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitiesTab(SafeL10n safeL10n) {
    // Aqui seria implementada a lista de atividades do grupo
    // Por enquanto, apenas um placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            safeL10n.get('activitiesTabPlaceholder', 'Histórico de atividades'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  void _showGroupOptions(BuildContext context, Group group, SafeL10n safeL10n) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(safeL10n.get('editGroup', 'Editar grupo')),
              onTap: () {
                Navigator.of(context).pop();
                _showEditGroupDialog(context, group, safeL10n);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(safeL10n.get('shareGroup', 'Compartilhar grupo')),
              onTap: () {
                Navigator.of(context).pop();
                // Implementar compartilhamento
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: Text(safeL10n.get('leaveGroup', 'Sair do grupo')),
              onTap: () {
                Navigator.of(context).pop();
                _showLeaveGroupDialog(context, safeL10n);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(
                safeL10n.get('deleteGroup', 'Excluir grupo'),
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.of(context).pop();
                _showDeleteGroupDialog(context, safeL10n);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditGroupDialog(BuildContext context, Group group, SafeL10n safeL10n) {
    final nameController = TextEditingController(text: group.name);
    final descriptionController = TextEditingController(text: group.description);
    bool isPrivate = group.isPrivate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(safeL10n.get('editGroup', 'Editar Grupo')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: safeL10n.get('groupName', 'Nome do grupo'),
                  ),
                  maxLength: 50,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: safeL10n.get('groupDescription', 'Descrição'),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(safeL10n.get('privateGroup', 'Grupo privado')),
                  subtitle: Text(
                    safeL10n.get(
                      'privateGroupDescription',
                      'Apenas membros convidados podem participar',
                    ),
                  ),
                  value: isPrivate,
                  onChanged: (value) => setState(() => isPrivate = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(safeL10n.get('cancel', 'Cancelar')),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  return;
                }
                
                Navigator.of(context).pop();
                ref.read(groupProvider.notifier).updateGroup(
                      group.id,
                      name: nameController.text.trim(),
                      description: descriptionController.text.trim(),
                      isPrivate: isPrivate,
                    );
              },
              child: Text(safeL10n.get('save', 'Salvar')),
            ),
          ],
        ),
      ),
    );
  }

  void _showInviteMemberDialog(BuildContext context, SafeL10n safeL10n) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(safeL10n.get('inviteMember', 'Convidar Membro')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: safeL10n.get('memberEmail', 'E-mail do jogador'),
                  hintText: safeL10n.get(
                    'memberEmailHint',
                    'Ex: jogador@exemplo.com',
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(safeL10n.get('cancel', 'Cancelar')),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.trim().isEmpty) {
                return;
              }
              
              Navigator.of(context).pop();
              ref.read(groupProvider.notifier).inviteUser(
                    widget.groupId,
                    emailController.text.trim(),
                  );
            },
            child: Text(safeL10n.get('invite', 'Convidar')),
          ),
        ],
      ),
    );
  }

  void _showLeaveGroupDialog(BuildContext context, SafeL10n safeL10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(safeL10n.get('leaveGroup', 'Sair do Grupo')),
        content: Text(
          safeL10n.get(
            'leaveGroupConfirmation',
            'Tem certeza que deseja sair deste grupo? Você precisará de um novo convite para entrar novamente.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(safeL10n.get('cancel', 'Cancelar')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implementar lógica para sair do grupo
              Navigator.of(context).pop(); // Voltar para a tela de grupos
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(safeL10n.get('leave', 'Sair')),
          ),
        ],
      ),
    );
  }

  void _showDeleteGroupDialog(BuildContext context, SafeL10n safeL10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(safeL10n.get('deleteGroup', 'Excluir Grupo')),
        content: Text(
          safeL10n.get(
            'deleteGroupConfirmation',
            'Tem certeza que deseja excluir este grupo? Esta ação não pode ser desfeita e todos os dados do grupo serão perdidos.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(safeL10n.get('cancel', 'Cancelar')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(groupProvider.notifier).deleteGroup(widget.groupId);
              Navigator.of(context).pop(); // Voltar para a tela de grupos
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(safeL10n.get('delete', 'Excluir')),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

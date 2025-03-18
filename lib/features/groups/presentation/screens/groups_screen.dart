import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_night/core/utils/l10n_extensions.dart';
import 'package:poker_night/providers/group_provider.dart';
import 'package:poker_night/features/groups/domain/models/index.dart';
import 'package:poker_night/widgets/common/app_bar_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  @override
  void initState() {
    super.initState();
    // Buscar grupos ao iniciar a tela
    Future.microtask(() => ref.read(groupProvider.notifier).fetchGroups());
  }

  @override
  Widget build(BuildContext context) {
    final safeL10n = SafeL10n(AppLocalizations.of(context)!);
    final groupState = ref.watch(groupProvider);
    
    return Scaffold(
      appBar: AppBarWidget(
        title: safeL10n.get('groupsTitle', 'Grupos'),
      ),
      body: _buildBody(groupState, safeL10n),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateGroupDialog(context, safeL10n),
        tooltip: safeL10n.get('createGroupTooltip', 'Criar novo grupo'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(GroupState state, SafeL10n safeL10n) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              safeL10n.get('errorLoadingGroups', 'Erro ao carregar grupos'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(groupProvider.notifier).fetchGroups(),
              child: Text(safeL10n.get('tryAgain', 'Tentar novamente')),
            ),
          ],
        ),
      );
    }

    if (state.groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_off,
              size: 64,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              safeL10n.get('noGroups', 'Você ainda não participa de nenhum grupo'),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showCreateGroupDialog(context, safeL10n),
              child: Text(safeL10n.get('createFirstGroup', 'Criar meu primeiro grupo')),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.groups.length,
      itemBuilder: (context, index) {
        final group = state.groups[index];
        return _buildGroupCard(group, safeL10n);
      },
    );
  }

  Widget _buildGroupCard(Group group, SafeL10n safeL10n) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToGroupDetails(group.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    child: group.avatarUrl != null
                        ? ClipOval(
                            child: Image.network(
                              group.avatarUrl!,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Text(
                                group.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(fontSize: 20),
                              ),
                            ),
                          )
                        : Text(
                            group.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontSize: 20),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.name,
                          style: Theme.of(context).textTheme.titleMedium,
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
                  Icon(
                    group.isPrivate ? Icons.lock : Icons.lock_open,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
              if (group.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  group.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToGroupDetails(String groupId) {
    Navigator.of(context).pushNamed('/group-details', arguments: groupId);
  }

  void _showCreateGroupDialog(BuildContext context, SafeL10n safeL10n) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isPrivate = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(safeL10n.get('createGroup', 'Criar Grupo')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: safeL10n.get('groupName', 'Nome do grupo'),
                    hintText: safeL10n.get('groupNameHint', 'Ex: Poker dos Amigos'),
                  ),
                  maxLength: 50,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: safeL10n.get('groupDescription', 'Descrição'),
                    hintText: safeL10n.get(
                      'groupDescriptionHint',
                      'Ex: Grupo para nossos jogos de sexta-feira',
                    ),
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
                ref.read(groupProvider.notifier).createGroup(
                      nameController.text.trim(),
                      descriptionController.text.trim(),
                      isPrivate,
                    );
              },
              child: Text(safeL10n.get('create', 'Criar')),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

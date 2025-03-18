import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poker_night/features/groups/domain/models/index.dart';
import 'package:poker_night/providers/group_provider.dart';
import 'package:poker_night/core/utils/feature_access.dart';
import 'package:poker_night/core/utils/l10n_extensions.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poker_night/providers/feature_toggle_provider.dart';

class GroupsScreen extends ConsumerStatefulWidget {
  const GroupsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends ConsumerState<GroupsScreen> {
  @override
  void initState() {
    super.initState();
    // Carregar os grupos do usuário quando a tela for inicializada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(groupProvider.notifier).loadUserGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final safeL10n = l10n.safe;
    final groupState = ref.watch(groupProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(safeL10n.groups),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(groupProvider.notifier).loadUserGroups(),
          ),
        ],
      ),
      body: _buildBody(context, groupState),
      floatingActionButton: conditionalFeature(
        context: context,
        ref: ref,
        feature: Feature.createGame,
        child: FloatingActionButton(
          onPressed: () => _showCreateGroupDialog(context),
          child: const Icon(Icons.add),
          tooltip: safeL10n.createGroup,
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, GroupState groupState) {
    final l10n = AppLocalizations.of(context)!;
    final safeL10n = l10n.safe;
    
    if (groupState.isLoading && groupState.groups.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (groupState.errorMessage != null && groupState.groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              groupState.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(groupProvider.notifier).loadUserGroups(),
              child: Text(safeL10n.tryAgain),
            ),
          ],
        ),
      );
    }

    if (groupState.groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_off,
              size: 80,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              safeL10n.noGroups,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _showCreateGroupDialog(context),
              child: Text(safeL10n.createGroup),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(groupProvider.notifier).loadUserGroups(),
      child: ListView.builder(
        itemCount: groupState.groups.length,
        itemBuilder: (context, index) {
          final group = groupState.groups[index];
          return _buildGroupItem(context, group);
        },
      ),
    );
  }

  Widget _buildGroupItem(BuildContext context, Group group) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          backgroundImage: group.avatarUrl != null ? NetworkImage(group.avatarUrl!) : null,
          child: group.avatarUrl == null
              ? Text(group.name.substring(0, 1).toUpperCase())
              : null,
        ),
        title: Text(group.name),
        subtitle: group.description != null
            ? Text(
                group.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          ref.read(groupProvider.notifier).selectGroup(group.id);
          context.go('/groups/${group.id}');
        },
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final safeL10n = l10n.safe;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    bool isPublic = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(safeL10n.createGroup),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: safeL10n.groupName,
                    hintText: safeL10n.enterGroupName,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return safeL10n.requiredField;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: safeL10n.description,
                    hintText: safeL10n.enterGroupDescription,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: Text(safeL10n.publicGroup),
                  subtitle: Text(safeL10n.publicGroupDescription),
                  value: isPublic,
                  onChanged: (value) => setState(() => isPublic = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(safeL10n.cancel),
            ),
            Consumer(
              builder: (context, ref, child) {
                final isLoading = ref.watch(groupProvider).isLoading;
                
                return ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          if (formKey.currentState!.validate()) {
                            Navigator.of(context).pop();
                            
                            ref.read(groupProvider.notifier).createGroup(
                                  name: nameController.text.trim(),
                                  description: descriptionController.text.trim(),
                                  isPublic: isPublic,
                                );
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : Text(safeL10n.create),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

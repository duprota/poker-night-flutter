import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poker_night/core/services/supabase_service.dart';
import 'package:poker_night/core/utils/l10n_extensions.dart';
import 'package:poker_night/features/groups/domain/models/index.dart';
import 'package:poker_night/providers/group_provider.dart';
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
    
    // Carregar os detalhes do grupo quando a tela for inicializada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(groupProvider.notifier).selectGroup(widget.groupId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final safeL10n = l10n.safe;
    final groupState = ref.watch(groupProvider);
    final group = groupState.selectedGroup;
    final currentUser = SupabaseService.currentUser;
    
    final userRole = groupState.groupMembers
        .where((member) => member.userId == currentUser?.id)
        .map((member) => member.role)
        .firstOrNull ?? GroupMemberRole.player;
    
    final isAdmin = userRole == GroupMemberRole.admin;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(group?.name ?? safeL10n.groupDetails),
        actions: [
          if (isAdmin)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditGroupDialog(context, group!);
                } else if (value == 'delete') {
                  _showDeleteGroupDialog(context, group!);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit),
                      const SizedBox(width: 8),
                      Text(safeL10n.edit),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(safeL10n.delete, style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: safeL10n.members),
            Tab(text: safeL10n.games),
            Tab(text: safeL10n.activities),
          ],
        ),
      ),
      body: groupState.isLoading && group == null
          ? const Center(child: CircularProgressIndicator())
          : groupState.errorMessage != null && group == null
              ? Center(
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
                        onPressed: () => ref.read(groupProvider.notifier).selectGroup(widget.groupId),
                        child: Text(safeL10n.tryAgain),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMembersTab(context, groupState, isAdmin),
                    _buildGamesTab(context, groupState, userRole),
                    _buildActivitiesTab(context, groupState),
                  ],
                ),
      floatingActionButton: _buildFloatingActionButton(context, _tabController.index, userRole),
    );
  }

  Widget? _buildFloatingActionButton(BuildContext context, int tabIndex, GroupMemberRole userRole) {
    final safeL10n = AppLocalizations.of(context)!.safe;
    
    switch (tabIndex) {
      case 0: // Members tab
        if (userRole == GroupMemberRole.admin) {
          return FloatingActionButton(
            onPressed: () => _showInviteMemberDialog(context),
            child: const Icon(Icons.person_add),
            tooltip: safeL10n.inviteMember,
          );
        }
        return null;
      case 1: // Games tab
        if (userRole == GroupMemberRole.admin || userRole == GroupMemberRole.dealer) {
          return FloatingActionButton(
            onPressed: () => context.go('/games/create?groupId=${widget.groupId}'),
            child: const Icon(Icons.add),
            tooltip: safeL10n.createGame,
          );
        }
        return null;
      default:
        return null;
    }
  }

  Widget _buildMembersTab(BuildContext context, GroupState groupState, bool isAdmin) {
    final safeL10n = AppLocalizations.of(context)!.safe;
    final members = groupState.groupMembers;
    
    if (members.isEmpty) {
      return Center(
        child: Text(safeL10n.noMembers),
      );
    }
    
    return ListView.builder(
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return _buildMemberItem(context, member, isAdmin);
      },
    );
  }

  Widget _buildMemberItem(BuildContext context, GroupMember member, bool isAdmin) {
    final safeL10n = AppLocalizations.of(context)!.safe;
    final currentUser = SupabaseService.currentUser;
    final isCurrentUser = member.userId == currentUser?.id;

    String getRoleName(GroupMemberRole role) {
      switch (role) {
        case GroupMemberRole.admin:
          return safeL10n.admin;
        case GroupMemberRole.dealer:
          return safeL10n.dealer;
        case GroupMemberRole.player:
          return safeL10n.player;
      }
    }
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        child: Text(member.userId.substring(0, 1).toUpperCase()),
      ),
      title: Text(member.userId + (isCurrentUser ? ' (${safeL10n.you})' : '')),
      subtitle: Text(getRoleName(member.role)),
      trailing: isAdmin && !isCurrentUser
          ? PopupMenuButton<String>(
              onSelected: (value) {
                if (value.startsWith('role_')) {
                  final role = GroupMemberRole.values.firstWhere(
                    (role) => role.toString() == value.replaceFirst('role_', 'GroupMemberRole.'),
                  );
                  _showChangeRoleDialog(context, member, role);
                } else if (value == 'remove') {
                  _showRemoveMemberDialog(context, member);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'role_GroupMemberRole.admin',
                  child: Text(safeL10n.makeAdmin),
                  enabled: member.role != GroupMemberRole.admin,
                ),
                PopupMenuItem<String>(
                  value: 'role_GroupMemberRole.dealer',
                  child: Text(safeL10n.makeDealer),
                  enabled: member.role != GroupMemberRole.dealer,
                ),
                PopupMenuItem<String>(
                  value: 'role_GroupMemberRole.player',
                  child: Text(safeL10n.makePlayer),
                  enabled: member.role != GroupMemberRole.player,
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'remove',
                  child: Text(
                    safeL10n.removeMember,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            )
          : null,
    );
  }

  Widget _buildGamesTab(BuildContext context, GroupState groupState, GroupMemberRole userRole) {
    final safeL10n = AppLocalizations.of(context)!.safe;
    final canCreateGame = userRole == GroupMemberRole.admin || userRole == GroupMemberRole.dealer;
    
    // Esta parte depende da implementação do sistema de jogos
    // Por enquanto, apenas exibiremos uma mensagem de placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(safeL10n.noGames),
          if (canCreateGame) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/games/create?groupId=${widget.groupId}'),
              child: Text(safeL10n.createGame),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivitiesTab(BuildContext context, GroupState groupState) {
    final safeL10n = AppLocalizations.of(context)!.safe;
    final activities = groupState.groupActivities;
    
    if (activities.isEmpty) {
      return Center(
        child: Text(safeL10n.noActivities),
      );
    }
    
    return ListView.builder(
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        return _buildActivityItem(context, activity);
      },
    );
  }

  Widget _buildActivityItem(BuildContext context, GroupActivity activity) {
    final safeL10n = AppLocalizations.of(context)!.safe;
    
    IconData getActivityIcon(GroupActivityType type) {
      switch (type) {
        case GroupActivityType.groupCreated:
          return Icons.group_add;
        case GroupActivityType.memberAdded:
          return Icons.person_add;
        case GroupActivityType.memberRemoved:
          return Icons.person_remove;
        case GroupActivityType.roleChanged:
          return Icons.manage_accounts;
        case GroupActivityType.gameCreated:
          return Icons.casino;
        case GroupActivityType.gameUpdated:
          return Icons.edit;
        case GroupActivityType.gameDeleted:
          return Icons.delete;
        case GroupActivityType.invitationSent:
          return Icons.mail;
        case GroupActivityType.invitationAccepted:
          return Icons.mark_email_read;
      }
    }
    
    String getActivityDescription(GroupActivityType type, Map<String, dynamic>? details) {
      switch (type) {
        case GroupActivityType.groupCreated:
          return safeL10n.activityGroupCreated;
        case GroupActivityType.memberAdded:
          return safeL10n.activityMemberAdded;
        case GroupActivityType.memberRemoved:
          return safeL10n.activityMemberRemoved;
        case GroupActivityType.roleChanged:
          return safeL10n.activityRoleChanged;
        case GroupActivityType.gameCreated:
          return safeL10n.activityGameCreated;
        case GroupActivityType.gameUpdated:
          return safeL10n.activityGameUpdated;
        case GroupActivityType.gameDeleted:
          return safeL10n.activityGameDeleted;
        case GroupActivityType.invitationSent:
          return safeL10n.activityInvitationSent;
        case GroupActivityType.invitationAccepted:
          return safeL10n.activityInvitationAccepted;
      }
    }
    
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColorLight,
        child: Icon(getActivityIcon(activity.activityType)),
      ),
      title: Text(getActivityDescription(activity.activityType, activity.details)),
      subtitle: Text(
        activity.createdAt.toString(),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }

  void _showEditGroupDialog(BuildContext context, Group group) {
    final safeL10n = AppLocalizations.of(context)!.safe;
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: group.name);
    final descriptionController = TextEditingController(text: group.description ?? '');
    var isPublic = group.isPublic;
    var maxPlayers = group.maxPlayers;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(safeL10n.editGroup),
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
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: maxPlayers,
                  decoration: InputDecoration(
                    labelText: safeL10n.maxPlayers,
                  ),
                  items: [4, 6, 8, 10, 12].map((value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value ${safeL10n.players}'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => maxPlayers = value!),
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
                            
                            ref.read(groupProvider.notifier).updateGroup(
                              groupId: widget.groupId,
                              name: nameController.text.trim(),
                              description: descriptionController.text.trim(),
                              isPublic: isPublic,
                              maxPlayers: maxPlayers,
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
                      : Text(safeL10n.save),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteGroupDialog(BuildContext context, Group group) {
    final safeL10n = AppLocalizations.of(context)!.safe;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(safeL10n.deleteGroup),
        content: Text(
          safeL10n.deleteGroupConfirmation(group.name),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(safeL10n.cancel),
          ),
          Consumer(
            builder: (context, ref, child) {
              final isLoading = ref.watch(groupProvider).isLoading;
              
              return TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        ref.read(groupProvider.notifier).deleteGroup(group.id);
                        context.go('/groups');
                      },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.red,
                        ),
                      )
                    : Text(safeL10n.delete),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showInviteMemberDialog(BuildContext context) {
    final safeL10n = AppLocalizations.of(context)!.safe;
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    var selectedRole = GroupMemberRole.player;

    String getRoleName(GroupMemberRole role) {
      switch (role) {
        case GroupMemberRole.admin:
          return safeL10n.admin;
        case GroupMemberRole.dealer:
          return safeL10n.dealer;
        case GroupMemberRole.player:
          return safeL10n.player;
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(safeL10n.inviteMember),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: safeL10n.email,
                    hintText: safeL10n.enterEmailToInvite,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return safeL10n.requiredField;
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return safeL10n.invalidEmail;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<GroupMemberRole>(
                  value: selectedRole,
                  decoration: InputDecoration(
                    labelText: safeL10n.role,
                  ),
                  items: GroupMemberRole.values.map((role) {
                    return DropdownMenuItem<GroupMemberRole>(
                      value: role,
                      child: Text(getRoleName(role)),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedRole = value!),
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
                            
                            ref.read(groupProvider.notifier).inviteUserToGroup(
                              groupId: widget.groupId,
                              email: emailController.text.trim(),
                              role: selectedRole,
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
                      : Text(safeL10n.invite),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showChangeRoleDialog(BuildContext context, GroupMember member, GroupMemberRole newRole) {
    final safeL10n = AppLocalizations.of(context)!.safe;
    
    String getRoleName(GroupMemberRole role) {
      switch (role) {
        case GroupMemberRole.admin:
          return safeL10n.admin;
        case GroupMemberRole.dealer:
          return safeL10n.dealer;
        case GroupMemberRole.player:
          return safeL10n.player;
      }
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(safeL10n.changeRole),
        content: Text(
          safeL10n.changeRoleConfirmation(
            member.userId,
            getRoleName(newRole),
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
                        Navigator.of(context).pop();
                        ref.read(groupProvider.notifier).updateMemberRole(
                          memberId: member.id,
                          newRole: newRole,
                        );
                      },
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(safeL10n.confirm),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showRemoveMemberDialog(BuildContext context, GroupMember member) {
    final safeL10n = AppLocalizations.of(context)!.safe;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(safeL10n.removeMember),
        content: Text(
          safeL10n.removeMemberConfirmation(member.userId),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(safeL10n.cancel),
          ),
          Consumer(
            builder: (context, ref, child) {
              final isLoading = ref.watch(groupProvider).isLoading;
              
              return TextButton(
                onPressed: isLoading
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        ref.read(groupProvider.notifier).removeGroupMember(member.id);
                      },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.red,
                        ),
                      )
                    : Text(safeL10n.remove),
              );
            },
          ),
        ],
      ),
    );
  }
}

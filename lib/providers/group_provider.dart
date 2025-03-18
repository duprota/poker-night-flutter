import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_night/core/services/supabase_service.dart';
import 'package:poker_night/features/groups/domain/models/index.dart';
import 'package:uuid/uuid.dart';

/// Estado para o gerenciamento de grupos
class GroupState {
  final List<Group> groups;
  final Group? selectedGroup;
  final List<GroupMember> groupMembers;
  final List<GroupInvitation> groupInvitations;
  final List<GroupActivity> groupActivities;
  final bool isLoading;
  final String? errorMessage;

  const GroupState({
    this.groups = const [],
    this.selectedGroup,
    this.groupMembers = const [],
    this.groupInvitations = const [],
    this.groupActivities = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  /// Cria uma cópia do estado com os valores atualizados
  GroupState copyWith({
    List<Group>? groups,
    Group? selectedGroup,
    List<GroupMember>? groupMembers,
    List<GroupInvitation>? groupInvitations,
    List<GroupActivity>? groupActivities,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GroupState(
      groups: groups ?? this.groups,
      selectedGroup: selectedGroup ?? this.selectedGroup,
      groupMembers: groupMembers ?? this.groupMembers,
      groupInvitations: groupInvitations ?? this.groupInvitations,
      groupActivities: groupActivities ?? this.groupActivities,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// Atualiza o estado com uma mensagem de erro
  GroupState withError(String message) {
    return copyWith(
      isLoading: false,
      errorMessage: message,
    );
  }
}

/// Notifier para gerenciar o estado dos grupos
class GroupNotifier extends StateNotifier<GroupState> {
  GroupNotifier() : super(const GroupState());

  // Carregar todos os grupos do usuário
  Future<void> loadUserGroups() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        state = state.withError('Usuário não autenticado');
        return;
      }

      // Buscar grupos onde o usuário é membro
      final response = await SupabaseService.client
          .from('group_members')
          .select('group_id')
          .eq('user_id', userId);

      final List<String> groupIds = response
          .map<String>((item) => item['group_id'] as String)
          .toList();

      if (groupIds.isEmpty) {
        state = state.copyWith(
          groups: [],
          isLoading: false,
        );
        return;
      }

      // Buscar detalhes dos grupos
      final List<Group> groups = [];
      for (final groupId in groupIds) {
        final groupResponse = await SupabaseService.client
            .from('groups')
            .select()
            .eq('id', groupId);
        
        if (groupResponse.isNotEmpty) {
          groups.add(Group.fromJson(groupResponse.first));
        }
      }

      // Buscar membros dos grupos
      final List<GroupMember> members = [];
      for (final groupId in groupIds) {
        final membersResponse = await SupabaseService.client
            .from('group_members')
            .select()
            .eq('group_id', groupId);
        
        members.addAll(membersResponse
            .map<GroupMember>((json) => GroupMember.fromJson(json))
            .toList());
      }

      // Encontrar o membro atual
      final currentUserMember = members.firstWhere(
        (member) => member.userId == SupabaseService.currentUser?.id,
        orElse: () => GroupMember(
          id: '',
          groupId: '',
          userId: SupabaseService.currentUser?.id ?? '',
          role: GroupMemberRole.player,
          joinedAt: DateTime.now(),
        ),
      );

      // Buscar convites pendentes
      List<GroupInvitation> invitations = [];
      if (currentUserMember.role == GroupMemberRole.admin) {
        for (final groupId in groupIds) {
          final invitationsResponse = await SupabaseService.client
              .from('group_invitations')
              .select()
              .eq('group_id', groupId)
              .eq('status', 'pending');
          
          invitations.addAll(invitationsResponse
              .map<GroupInvitation>((json) => GroupInvitation.fromJson(json))
              .toList());
        }
      }

      // Buscar atividades recentes
      final List<GroupActivity> activities = [];
      for (final groupId in groupIds) {
        final activitiesResponse = await SupabaseService.client
            .from('group_activities')
            .select()
            .eq('group_id', groupId)
            .order('created_at', ascending: false)
            .limit(5); // Limitar a 5 por grupo para não sobrecarregar
        
        activities.addAll(activitiesResponse
            .map<GroupActivity>((json) => GroupActivity.fromJson(json))
            .toList());
      }
      
      // Ordenar atividades por data (mais recentes primeiro)
      activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      // Limitar o total de atividades a 20
      final limitedActivities = activities.length > 20 
          ? activities.sublist(0, 20) 
          : activities;

      state = state.copyWith(
        groups: groups,
        groupMembers: members,
        groupInvitations: invitations,
        groupActivities: limitedActivities,
        isLoading: false,
      );
    } catch (e) {
      state = state.withError('Erro ao carregar grupos: ${e.toString()}');
    }
  }

  // Criar um novo grupo
  Future<void> createGroup({
    required String name,
    String? description,
    int maxPlayers = 10,
    bool isPublic = false,
    String? avatarUrl,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final userId = SupabaseService.currentUser?.id;
      if (userId == null) {
        state = state.withError('Usuário não autenticado');
        return;
      }

      // Inserir o novo grupo
      final response = await SupabaseService.client
          .from('groups')
          .insert({
            'name': name,
            'description': description,
            'created_by': userId,
            'max_players': maxPlayers,
            'is_public': isPublic,
            'avatar_url': avatarUrl,
          })
          .select()
          .single();

      final group = Group.fromJson(response);

      // Adicionar o criador como admin do grupo
      await SupabaseService.client.from('group_members').insert({
        'group_id': group.id,
        'user_id': userId,
        'role': 'admin',
      });

      // Registrar atividade de criação do grupo
      await SupabaseService.client.from('group_activities').insert({
        'group_id': group.id,
        'user_id': userId,
        'activity_type': 'group_created',
        'details': 'Grupo criado',
      });

      // Atualizar a lista de grupos
      await loadUserGroups();
    } catch (e) {
      state = state.withError('Erro ao criar grupo: ${e.toString()}');
    }
  }

  // Selecionar um grupo específico
  Future<void> selectGroup(String groupId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Buscar detalhes do grupo
      final groupResponse = await SupabaseService.client
          .from('groups')
          .select()
          .eq('id', groupId)
          .single();

      final group = Group.fromJson(groupResponse);

      // Buscar membros do grupo
      final membersResponse = await SupabaseService.client
          .from('group_members')
          .select()
          .eq('group_id', groupId);

      final List<GroupMember> members = membersResponse
          .map<GroupMember>((json) => GroupMember.fromJson(json))
          .toList();

      // Verificar se o usuário atual é admin
      final isAdmin = members.any((member) => 
          member.userId == SupabaseService.currentUser?.id && 
          member.role == GroupMemberRole.admin);

      // Buscar convites pendentes (apenas para admins)
      List<GroupInvitation> invitations = [];
      if (isAdmin) {
        final invitationsResponse = await SupabaseService.client
            .from('group_invitations')
            .select()
            .eq('group_id', groupId)
            .eq('status', 'pending');

        invitations = invitationsResponse
            .map<GroupInvitation>((json) => GroupInvitation.fromJson(json))
            .toList();
      }

      // Buscar atividades do grupo
      final activitiesResponse = await SupabaseService.client
          .from('group_activities')
          .select()
          .eq('group_id', groupId)
          .order('created_at', ascending: false)
          .limit(10);

      final List<GroupActivity> activities = activitiesResponse
          .map<GroupActivity>((json) => GroupActivity.fromJson(json))
          .toList();

      state = state.copyWith(
        selectedGroup: group,
        groupMembers: members,
        groupInvitations: invitations,
        groupActivities: activities,
        isLoading: false,
      );
    } catch (e) {
      state = state.withError('Erro ao carregar grupo: ${e.toString()}');
    }
  }

  // Atualizar um grupo existente
  Future<void> updateGroup({
    required String groupId,
    String? name,
    String? description,
    int? maxPlayers,
    bool? isPublic,
    String? avatarUrl,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Verificar se o usuário é admin do grupo
      final isAdmin = state.groupMembers.any((member) => 
          member.userId == SupabaseService.currentUser?.id && 
          member.role == GroupMemberRole.admin);

      if (!isAdmin) {
        state = state.withError('Permissão negada: apenas administradores podem editar o grupo');
        return;
      }

      // Preparar dados para atualização
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (maxPlayers != null) updateData['max_players'] = maxPlayers;
      if (isPublic != null) updateData['is_public'] = isPublic;
      if (avatarUrl != null) updateData['avatar_url'] = avatarUrl;
      updateData['updated_at'] = DateTime.now().toIso8601String();

      // Atualizar o grupo
      await SupabaseService.client
          .from('groups')
          .update(updateData)
          .eq('id', groupId);

      // Registrar atividade de atualização do grupo
      await SupabaseService.client.from('group_activities').insert({
        'group_id': groupId,
        'user_id': SupabaseService.currentUser!.id,
        'activity_type': 'group_updated',
        'details': 'Grupo atualizado',
      });

      // Recarregar o grupo selecionado
      await selectGroup(groupId);
    } catch (e) {
      state = state.withError('Erro ao atualizar grupo: ${e.toString()}');
    }
  }

  // Excluir um grupo
  Future<void> deleteGroup(String groupId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Verificar se o usuário é admin do grupo
      final isAdmin = state.groupMembers.any((member) => 
          member.userId == SupabaseService.currentUser?.id && 
          member.role == GroupMemberRole.admin);

      if (!isAdmin) {
        state = state.withError('Permissão negada: apenas administradores podem excluir o grupo');
        return;
      }

      // Excluir o grupo (as tabelas relacionadas serão excluídas automaticamente devido ao CASCADE)
      await SupabaseService.client
          .from('groups')
          .delete()
          .eq('id', groupId);

      // Recarregar os grupos do usuário
      await loadUserGroups();
      
      // Limpar o grupo selecionado se for o que foi excluído
      if (state.selectedGroup?.id == groupId) {
        state = state.copyWith(selectedGroup: null);
      }
    } catch (e) {
      state = state.withError('Erro ao excluir grupo: ${e.toString()}');
    }
  }

  // Adicionar um membro ao grupo
  Future<void> addGroupMember({
    required String groupId,
    required String userId,
    required GroupMemberRole role,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Verificar se o usuário é admin do grupo
      final isAdmin = state.groupMembers.any((member) => 
          member.userId == SupabaseService.currentUser?.id && 
          member.role == GroupMemberRole.admin);

      if (!isAdmin) {
        state = state.withError('Permissão negada: apenas administradores podem adicionar membros');
        return;
      }

      // Adicionar o membro no Supabase
      final response = await SupabaseService.client
          .from('group_members')
          .insert({
            'group_id': groupId,
            'user_id': userId,
            'role': role.name,
          })
          .select()
          .single();

      final newMember = GroupMember.fromJson(response);

      // Registrar atividade de adição de membro
      await SupabaseService.client.from('group_activities').insert({
        'group_id': groupId,
        'user_id': SupabaseService.currentUser!.id,
        'activity_type': 'member_added',
        'details': 'Membro adicionado: ${newMember.userId}',
      });

      // Atualizar a lista de membros
      final updatedMembers = [...state.groupMembers, newMember];
      state = state.copyWith(
        groupMembers: updatedMembers,
        isLoading: false,
      );
    } catch (e) {
      state = state.withError('Erro ao adicionar membro: ${e.toString()}');
    }
  }

  // Atualizar o papel de um membro
  Future<void> updateMemberRole({
    required String memberId,
    required GroupMemberRole newRole,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Verificar se o usuário é admin do grupo
      final isAdmin = state.groupMembers.any((m) => 
          m.userId == SupabaseService.currentUser?.id && 
          m.role == GroupMemberRole.admin);

      if (!isAdmin) {
        state = state.withError('Permissão negada: apenas administradores podem atualizar papéis');
        return;
      }

      // Atualizar o papel do membro no Supabase
      await SupabaseService.client
          .from('group_members')
          .update({
            'role': newRole.name,
          })
          .eq('id', memberId);

      // Encontrar o membro e o grupo
      final member = state.groupMembers.firstWhere((m) => m.id == memberId);
      final groupId = member.groupId;

      // Registrar atividade de atualização de papel
      await SupabaseService.client.from('group_activities').insert({
        'group_id': groupId,
        'user_id': SupabaseService.currentUser!.id,
        'activity_type': 'member_role_updated',
        'details': 'Papel do membro atualizado: ${member.userId} -> ${newRole.name}',
      });

      // Atualizar a lista de membros
      final updatedMembers = state.groupMembers.map((m) {
        if (m.id == memberId) {
          return m.copyWith(role: newRole);
        }
        return m;
      }).toList();

      state = state.copyWith(
        groupMembers: updatedMembers,
        isLoading: false,
      );
    } catch (e) {
      state = state.withError('Erro ao atualizar papel: ${e.toString()}');
    }
  }

  // Remover um membro do grupo
  Future<void> removeGroupMember(String memberId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Verificar se o usuário é admin do grupo
      final isAdmin = state.groupMembers.any((m) => 
          m.userId == SupabaseService.currentUser?.id && 
          m.role == GroupMemberRole.admin);

      if (!isAdmin) {
        state = state.withError('Permissão negada: apenas administradores podem remover membros');
        return;
      }

      // Encontrar o membro e o grupo
      final member = state.groupMembers.firstWhere((m) => m.id == memberId);
      final groupId = member.groupId;

      // Remover o membro no Supabase
      await SupabaseService.client
          .from('group_members')
          .delete()
          .eq('id', memberId);

      // Registrar atividade de remoção de membro
      await SupabaseService.client.from('group_activities').insert({
        'group_id': groupId,
        'user_id': SupabaseService.currentUser!.id,
        'activity_type': 'member_removed',
        'details': 'Membro removido: ${member.userId}',
      });

      // Atualizar a lista de membros
      final updatedMembers = state.groupMembers
          .where((m) => m.id != memberId)
          .toList();

      state = state.copyWith(
        groupMembers: updatedMembers,
        isLoading: false,
      );
    } catch (e) {
      state = state.withError('Erro ao remover membro: ${e.toString()}');
    }
  }

  // Convidar um usuário para o grupo
  Future<void> inviteUserToGroup({
    required String groupId,
    required String email,
    required GroupMemberRole role,
  }) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Verificar se o usuário é admin do grupo
      final isAdmin = state.groupMembers.any((member) => 
          member.userId == SupabaseService.currentUser?.id && 
          member.role == GroupMemberRole.admin);

      if (!isAdmin) {
        state = state.withError('Permissão negada: apenas administradores podem convidar usuários');
        return;
      }

      // Gerar token de convite
      final token = const Uuid().v4() + '-' +
                   SupabaseService.currentUser!.id.substring(0, 8);
      
      // Criar o convite no Supabase
      final response = await SupabaseService.client
          .from('group_invitations')
          .insert({
            'group_id': groupId,
            'created_by': SupabaseService.currentUser!.id,
            'email': email,
            'token': token,
            'role': role.name,
            'status': 'pending',
            'expires_at': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          })
          .select()
          .single();

      final newInvitation = GroupInvitation.fromJson(response);

      // Registrar a atividade de envio de convite
      await SupabaseService.client.from('group_activities').insert({
        'group_id': groupId,
        'user_id': SupabaseService.currentUser!.id,
        'activity_type': 'invitation_sent',
        'details': 'Convite enviado para: $email',
      });

      // Atualizar a lista de convites
      final updatedInvitations = [...state.groupInvitations, newInvitation];
      state = state.copyWith(
        groupInvitations: updatedInvitations,
        isLoading: false,
      );
    } catch (e) {
      state = state.withError('Erro ao enviar convite: ${e.toString()}');
    }
  }

  // Aceitar um convite para um grupo
  Future<void> acceptGroupInvitation(String token) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Buscar o convite pelo token
      final response = await SupabaseService.client
          .from('group_invitations')
          .select()
          .eq('token', token)
          .single();

      final invitation = GroupInvitation.fromJson(response);

      // Verificar se o convite expirou
      if (DateTime.now().isAfter(invitation.expiresAt)) {
        // Atualizar status do convite para expirado
        await SupabaseService.client
            .from('group_invitations')
            .update({'status': 'expired'})
            .eq('id', invitation.id);
        state = state.withError('Este convite expirou');
        return;
      }

      // Verificar se o usuário já é membro do grupo
      final checkExistingMember = await SupabaseService.client
          .from('group_members')
          .select()
          .eq('group_id', invitation.groupId)
          .eq('user_id', SupabaseService.currentUser!.id);

      if (checkExistingMember.isNotEmpty) {
        // Atualizar status do convite para aceito
        await SupabaseService.client
            .from('group_invitations')
            .update({'status': 'accepted'})
            .eq('id', invitation.id);
        state = state.withError('Você já é membro deste grupo');
        return;
      }

      // Adicionar o usuário como membro do grupo
      await SupabaseService.client
          .from('group_members')
          .insert({
            'group_id': invitation.groupId,
            'user_id': SupabaseService.currentUser!.id,
            'role': invitation.role.name,
          });

      // Atualizar status do convite para aceito
      await SupabaseService.client
          .from('group_invitations')
          .update({'status': 'accepted'})
          .eq('id', invitation.id);

      // Registrar a atividade de aceitação de convite
      await SupabaseService.client
          .from('group_activities')
          .insert({
            'group_id': invitation.groupId,
            'user_id': SupabaseService.currentUser!.id,
            'activity_type': 'user_joined',
            'details': 'Usuário aceitou o convite',
          });

      // Recarregar a lista de grupos
      await loadUserGroups();

      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.withError('Erro ao aceitar convite: ${e.toString()}');
    }
  }

  // Revogar um convite
  Future<void> revokeInvitation(String invitationId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Verificar se o usuário é admin do grupo
      final invitation = state.groupInvitations.firstWhere((i) => i.id == invitationId);
      final isAdmin = state.groupMembers.any((member) => 
          member.userId == SupabaseService.currentUser?.id && 
          member.role == GroupMemberRole.admin);

      if (!isAdmin) {
        state = state.withError('Permissão negada: apenas administradores podem revogar convites');
        return;
      }

      // Excluir o convite no Supabase
      await SupabaseService.client
          .from('group_invitations')
          .delete()
          .eq('id', invitationId);

      // Atualizar a lista de convites
      final updatedInvitations = state.groupInvitations
          .where((i) => i.id != invitationId)
          .toList();

      state = state.copyWith(
        groupInvitations: updatedInvitations,
        isLoading: false,
      );
    } catch (e) {
      state = state.withError('Erro ao revogar convite: ${e.toString()}');
    }
  }

  // Carregar atividades de um grupo
  Future<void> loadGroupActivities(String groupId, {int limit = 20}) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      // Carregar as atividades do grupo
      final activitiesResponse = await SupabaseService.client
          .from('group_activities')
          .select()
          .eq('group_id', groupId)
          .order('created_at', ascending: false)
          .limit(limit);

      final List<GroupActivity> activities = activitiesResponse
          .map<GroupActivity>((json) => GroupActivity.fromJson(json))
          .toList();

      state = state.copyWith(
        groupActivities: activities,
        isLoading: false,
      );
    } catch (e) {
      state = state.withError('Erro ao carregar atividades: ${e.toString()}');
    }
  }
}

// Provider para acessar o estado dos grupos
final groupProvider = StateNotifierProvider<GroupNotifier, GroupState>((ref) {
  return GroupNotifier();
});

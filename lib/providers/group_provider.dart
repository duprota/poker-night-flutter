import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:poker_night/core/services/supabase_service.dart';
import 'package:poker_night/features/groups/domain/models/index.dart';

part 'group_provider.freezed.dart';

/// Estado para o provider de grupos
@freezed
class GroupState with _$GroupState {
  const factory GroupState({
    @Default([]) List<Group> groups,
    @Default([]) List<GroupInvitation> invitations,
    @Default(false) bool isLoading,
    String? error,
  }) = _GroupState;
}

/// Notificador para gerenciar o estado de grupos
class GroupNotifier extends StateNotifier<GroupState> {
  final SupabaseClient _client;

  GroupNotifier(this._client) : super(const GroupState());

  /// Busca todos os grupos aos quais o usuário pertence
  Future<void> fetchGroups() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Buscar IDs de grupos aos quais o usuário pertence
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Usuário não autenticado',
        );
        return;
      }

      final membershipResponse = await _client
          .from('group_members')
          .select('group_id')
          .eq('user_id', userId);

      final groupIds = (membershipResponse as List)
          .map((item) => item['group_id'] as String)
          .toList();

      if (groupIds.isEmpty) {
        state = state.copyWith(
          groups: [],
          isLoading: false,
        );
        return;
      }

      // Buscar detalhes dos grupos
      final groupsResponse = await _client
          .from('groups')
          .select()
          .in_('id', groupIds);

      final groups = (groupsResponse as List)
          .map((item) => Group.fromJson(item))
          .toList();

      state = state.copyWith(
        groups: groups,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Cria um novo grupo
  Future<void> createGroup(String name, String description, bool isPrivate) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Usuário não autenticado',
        );
        return;
      }

      // Inserir o grupo
      final groupResponse = await _client
          .from('groups')
          .insert({
            'name': name,
            'description': description,
            'owner_id': userId,
            'is_private': isPrivate,
          })
          .select()
          .single();

      final newGroup = Group.fromJson(groupResponse);

      // Adicionar o criador como membro com papel de proprietário
      await _client.from('group_members').insert({
        'group_id': newGroup.id,
        'user_id': userId,
        'role': 'owner',
      });

      // Registrar atividade de criação do grupo
      await _client.from('group_activities').insert({
        'group_id': newGroup.id,
        'actor_id': userId,
        'type': 'group_created',
        'metadata': {'group_name': name},
      });

      // Atualizar a lista de grupos
      state = state.copyWith(
        groups: [...state.groups, newGroup],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Atualiza um grupo existente
  Future<void> updateGroup(String groupId, {String? name, String? description, bool? isPrivate}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Usuário não autenticado',
        );
        return;
      }

      // Verificar se o usuário tem permissão para atualizar o grupo
      final membershipResponse = await _client
          .from('group_members')
          .select('role')
          .eq('group_id', groupId)
          .eq('user_id', userId)
          .single();

      final role = membershipResponse['role'] as String;
      if (role != 'owner' && role != 'admin') {
        state = state.copyWith(
          isLoading: false,
          error: 'Permissão negada',
        );
        return;
      }

      // Preparar dados para atualização
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (isPrivate != null) updateData['is_private'] = isPrivate;

      // Atualizar o grupo
      final groupResponse = await _client
          .from('groups')
          .update(updateData)
          .eq('id', groupId)
          .select()
          .single();

      final updatedGroup = Group.fromJson(groupResponse);

      // Registrar atividade de atualização do grupo
      await _client.from('group_activities').insert({
        'group_id': groupId,
        'actor_id': userId,
        'type': 'group_updated',
        'metadata': updateData,
      });

      // Atualizar a lista de grupos
      final updatedGroups = state.groups.map((group) {
        return group.id == groupId ? updatedGroup : group;
      }).toList();

      state = state.copyWith(
        groups: updatedGroups,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Exclui um grupo
  Future<void> deleteGroup(String groupId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Usuário não autenticado',
        );
        return;
      }

      // Verificar se o usuário é o proprietário do grupo
      final membershipResponse = await _client
          .from('group_members')
          .select('role')
          .eq('group_id', groupId)
          .eq('user_id', userId)
          .single();

      final role = membershipResponse['role'] as String;
      if (role != 'owner') {
        state = state.copyWith(
          isLoading: false,
          error: 'Apenas o proprietário pode excluir o grupo',
        );
        return;
      }

      // Excluir o grupo (as tabelas relacionadas serão excluídas em cascata)
      await _client.from('groups').delete().eq('id', groupId);

      // Atualizar a lista de grupos
      final updatedGroups = state.groups.where((group) => group.id != groupId).toList();

      state = state.copyWith(
        groups: updatedGroups,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Convida um usuário para o grupo
  Future<void> inviteUser(String groupId, String inviteeEmail) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final inviterId = _client.auth.currentUser?.id;
      if (inviterId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Usuário não autenticado',
        );
        return;
      }

      // Verificar se o usuário tem permissão para convidar
      final membershipResponse = await _client
          .from('group_members')
          .select('role')
          .eq('group_id', groupId)
          .eq('user_id', inviterId)
          .single();

      final role = membershipResponse['role'] as String;
      if (role != 'owner' && role != 'admin') {
        state = state.copyWith(
          isLoading: false,
          error: 'Permissão negada',
        );
        return;
      }

      // Buscar o ID do usuário convidado pelo e-mail
      final userResponse = await _client
          .from('users')
          .select('id')
          .eq('email', inviteeEmail)
          .single();

      final inviteeId = userResponse['id'] as String;

      // Verificar se o usuário já é membro do grupo
      final existingMemberResponse = await _client
          .from('group_members')
          .select()
          .eq('group_id', groupId)
          .eq('user_id', inviteeId);

      if ((existingMemberResponse as List).isNotEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'O usuário já é membro do grupo',
        );
        return;
      }

      // Verificar se já existe um convite pendente
      final existingInvitationResponse = await _client
          .from('group_invitations')
          .select()
          .eq('group_id', groupId)
          .eq('invitee_id', inviteeId)
          .eq('status', 'pending');

      if ((existingInvitationResponse as List).isNotEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Já existe um convite pendente para este usuário',
        );
        return;
      }

      // Criar o convite
      final expiresAt = DateTime.now().add(const Duration(days: 7));
      await _client.from('group_invitations').insert({
        'group_id': groupId,
        'inviter_id': inviterId,
        'invitee_id': inviteeId,
        'expires_at': expiresAt.toIso8601String(),
        'status': 'pending',
      });

      // Registrar atividade de convite
      await _client.from('group_activities').insert({
        'group_id': groupId,
        'actor_id': inviterId,
        'type': 'member_invited',
        'metadata': {'invitee_id': inviteeId},
      });

      // Atualizar o estado (não é necessário atualizar a lista de convites aqui)
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Busca convites pendentes para o usuário atual
  Future<void> fetchInvitations() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Usuário não autenticado',
        );
        return;
      }

      // Buscar convites pendentes
      final invitationsResponse = await _client
          .from('group_invitations')
          .select('''
            *,
            groups:group_id (
              name,
              description,
              avatar_url
            ),
            inviters:inviter_id (
              display_name,
              avatar_url
            )
          ''')
          .eq('invitee_id', userId)
          .eq('status', 'pending');

      final invitations = (invitationsResponse as List)
          .map((item) => GroupInvitation.fromJson({
                ...item,
                'group': item['groups'],
                'inviter': item['inviters'],
              }))
          .toList();

      state = state.copyWith(
        invitations: invitations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Responde a um convite (aceitar ou rejeitar)
  Future<void> respondToInvitation(String invitationId, bool accept) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Usuário não autenticado',
        );
        return;
      }

      // Buscar detalhes do convite
      final invitationResponse = await _client
          .from('group_invitations')
          .select()
          .eq('id', invitationId)
          .eq('invitee_id', userId)
          .eq('status', 'pending')
          .single();

      final invitation = GroupInvitation.fromJson(invitationResponse);

      // Atualizar o status do convite
      final newStatus = accept ? 'accepted' : 'rejected';
      await _client
          .from('group_invitations')
          .update({'status': newStatus})
          .eq('id', invitationId);

      if (accept) {
        // Adicionar o usuário como membro do grupo
        await _client.from('group_members').insert({
          'group_id': invitation.groupId,
          'user_id': userId,
          'role': 'member',
        });

        // Registrar atividade de novo membro
        await _client.from('group_activities').insert({
          'group_id': invitation.groupId,
          'actor_id': userId,
          'type': 'member_joined',
          'metadata': {},
        });

        // Buscar detalhes do grupo para adicionar à lista
        final groupResponse = await _client
            .from('groups')
            .select()
            .eq('id', invitation.groupId)
            .single();

        final newGroup = Group.fromJson(groupResponse);
        state = state.copyWith(
          groups: [...state.groups, newGroup],
        );
      }

      // Atualizar a lista de convites
      final updatedInvitations = state.invitations
          .where((inv) => inv.id != invitationId)
          .toList();

      state = state.copyWith(
        invitations: updatedInvitations,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

/// Provider para o notificador de grupos
final groupProvider = StateNotifierProvider<GroupNotifier, GroupState>((ref) {
  final client = SupabaseService.client;
  return GroupNotifier(client);
});

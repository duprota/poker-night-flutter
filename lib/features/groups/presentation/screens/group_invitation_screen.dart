import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_night/core/utils/l10n_extensions.dart';
import 'package:poker_night/providers/group_provider.dart';
import 'package:poker_night/features/groups/domain/models/index.dart';
import 'package:poker_night/widgets/common/app_bar_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GroupInvitationScreen extends ConsumerStatefulWidget {
  const GroupInvitationScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<GroupInvitationScreen> createState() => _GroupInvitationScreenState();
}

class _GroupInvitationScreenState extends ConsumerState<GroupInvitationScreen> {
  @override
  void initState() {
    super.initState();
    // Buscar convites ao iniciar a tela
    Future.microtask(() => ref.read(groupProvider.notifier).fetchInvitations());
  }

  @override
  Widget build(BuildContext context) {
    final safeL10n = SafeL10n(AppLocalizations.of(context)!);
    final groupState = ref.watch(groupProvider);
    
    return Scaffold(
      appBar: AppBarWidget(
        title: safeL10n.get('groupInvitations', 'Convites para Grupos'),
      ),
      body: _buildBody(groupState, safeL10n),
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
              safeL10n.get('errorLoadingInvitations', 'Erro ao carregar convites'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(groupProvider.notifier).fetchInvitations(),
              child: Text(safeL10n.get('tryAgain', 'Tentar novamente')),
            ),
          ],
        ),
      );
    }

    if (state.invitations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mail,
              size: 64,
              color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              safeL10n.get('noInvitations', 'Você não tem convites pendentes'),
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.invitations.length,
      itemBuilder: (context, index) {
        final invitation = state.invitations[index];
        return _buildInvitationCard(invitation, safeL10n);
      },
    );
  }

  Widget _buildInvitationCard(GroupInvitation invitation, SafeL10n safeL10n) {
    // Na implementação real, buscaríamos os detalhes do grupo e do convidador
    // Por enquanto, usaremos dados fictícios
    final groupName = "Nome do Grupo"; // Seria obtido do objeto group
    final inviterName = "Nome do Convidador"; // Seria obtido do objeto inviter

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                  child: Text(
                    groupName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        groupName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        safeL10n.get(
                          'invitedBy',
                          'Convidado por {name}',
                          args: {'name': inviterName},
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        safeL10n.get(
                          'invitationExpiresAt',
                          'Expira em {date}',
                          args: {'date': _formatDate(invitation.expiresAt)},
                        ),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => _respondToInvitation(invitation.id, false),
                  child: Text(safeL10n.get('decline', 'Recusar')),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () => _respondToInvitation(invitation.id, true),
                  child: Text(safeL10n.get('accept', 'Aceitar')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _respondToInvitation(String invitationId, bool accept) {
    ref.read(groupProvider.notifier).respondToInvitation(invitationId, accept);
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

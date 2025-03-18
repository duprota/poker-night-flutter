import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:poker_night/providers/group_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GroupInvitationScreen extends ConsumerStatefulWidget {
  final String token;

  const GroupInvitationScreen({Key? key, required this.token}) : super(key: key);

  @override
  ConsumerState<GroupInvitationScreen> createState() => _GroupInvitationScreenState();
}

class _GroupInvitationScreenState extends ConsumerState<GroupInvitationScreen> {
  bool _isLoading = false;
  String? _errorMessage;
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final groupState = ref.watch(groupProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.groupInvitation),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.group_add,
                  size: 64,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.groupInvitationTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.groupInvitationDescription,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                if (_accepted) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 48,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.invitationAccepted,
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/groups'),
                    child: Text(l10n.viewGroups),
                  ),
                ] else ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: _isLoading ? null : () => context.go('/'),
                        child: Text(l10n.cancel),
                      ),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () => _acceptInvitation(context),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(l10n.joinGroup),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _acceptInvitation(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      await ref.read(groupProvider.notifier).acceptGroupInvitation(widget.token);
      
      setState(() {
        _isLoading = false;
        _accepted = true;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }
}

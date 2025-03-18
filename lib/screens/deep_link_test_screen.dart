import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poker_night/core/services/deep_link_service_interface.dart';
import 'package:poker_night/providers/deep_link_provider.dart';
import 'package:poker_night/providers/feature_toggle_provider.dart';

/// Tela para testar a funcionalidade de deep links
class DeepLinkTestScreen extends ConsumerWidget {
  static const routeName = '/deep-link-test';

  const DeepLinkTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deepLinkState = ref.watch(deepLinkProvider);
    final deepLinkNotifier = ref.watch(deepLinkProvider.notifier);
    
    // Verificar se a feature está habilitada
    return conditionalFeature(
      context: context,
      ref: ref,
      feature: Feature.deepLinks,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Teste de Deep Links'),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Teste de Deep Links',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Status do último deep link processado
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status do Deep Link',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (deepLinkState.isProcessing)
                        const CircularProgressIndicator()
                      else if (deepLinkState.errorMessage != null)
                        Text(
                          'Erro: ${deepLinkState.errorMessage}',
                          style: const TextStyle(color: Colors.red),
                        )
                      else if (deepLinkState.lastProcessedLink != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Último link: ${deepLinkState.lastProcessedLink}'),
                            if (deepLinkState.lastProcessedData != null) ...[
                              const SizedBox(height: 8),
                              Text('Dados: ${deepLinkState.lastProcessedData}'),
                            ],
                          ],
                        )
                      else
                        const Text('Nenhum deep link processado ainda.'),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Gerador de deep links
              const Text(
                'Gerar Deep Links',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Link para jogo
              _DeepLinkGenerator(
                title: 'Link para Jogo',
                description: 'Gera um deep link para um jogo específico',
                onGenerate: () {
                  final gameId = 'game-123';
                  return deepLinkNotifier.createDeepLink(
                    path: '/game',
                    queryParameters: {'id': gameId},
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Link para jogador
              _DeepLinkGenerator(
                title: 'Link para Jogador',
                description: 'Gera um deep link para o perfil de um jogador',
                onGenerate: () {
                  final playerId = 'player-456';
                  return deepLinkNotifier.createDeepLink(
                    path: '/player',
                    queryParameters: {'id': playerId},
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Link para notificação
              _DeepLinkGenerator(
                title: 'Link para Notificação',
                description: 'Gera um deep link para uma notificação específica',
                onGenerate: () {
                  final notificationId = 'notification-789';
                  return deepLinkNotifier.createDeepLink(
                    path: '/notification',
                    queryParameters: {'id': notificationId},
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Link para convite
              _DeepLinkGenerator(
                title: 'Link para Convite',
                description: 'Gera um deep link para um convite de jogo',
                onGenerate: () {
                  final gameId = 'game-123';
                  final inviterId = 'player-456';
                  return deepLinkNotifier.createDeepLink(
                    path: '/invite',
                    queryParameters: {
                      'gameId': gameId,
                      'inviterId': inviterId,
                    },
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Instruções
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Como testar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1. Gere um deep link clicando em um dos botões acima\n'
                        '2. Copie o link gerado\n'
                        '3. Abra um navegador e cole o link\n'
                        '4. O aplicativo deve ser aberto e processar o deep link\n\n'
                        'Você também pode testar usando o comando adb no terminal:\n'
                        'adb shell am start -a android.intent.action.VIEW -d "pokernight://app/game?id=game-123"',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget para gerar e exibir deep links
class _DeepLinkGenerator extends StatefulWidget {
  final String title;
  final String description;
  final String Function() onGenerate;

  const _DeepLinkGenerator({
    Key? key,
    required this.title,
    required this.description,
    required this.onGenerate,
  }) : super(key: key);

  @override
  State<_DeepLinkGenerator> createState() => _DeepLinkGeneratorState();
}

class _DeepLinkGeneratorState extends State<_DeepLinkGenerator> {
  String? _generatedLink;
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(widget.description),
            const SizedBox(height: 8),
            if (_generatedLink != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _generatedLink!,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _copied ? Icons.check : Icons.copy,
                        color: _copied ? Colors.green : Colors.white,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _generatedLink!));
                        setState(() {
                          _copied = true;
                        });
                        
                        // Reset copy status after 2 seconds
                        Future.delayed(const Duration(seconds: 2), () {
                          if (mounted) {
                            setState(() {
                              _copied = false;
                            });
                          }
                        });
                      },
                      tooltip: 'Copiar link',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
            ElevatedButton(
              onPressed: () {
                final link = widget.onGenerate();
                setState(() {
                  _generatedLink = link;
                  _copied = false;
                });
              },
              child: Text(_generatedLink == null ? 'Gerar Link' : 'Gerar Novo Link'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poker_night/core/services/supabase_service.dart';
import 'package:poker_night/core/theme/app_theme.dart';

class GamesListScreen extends StatefulWidget {
  const GamesListScreen({super.key});

  @override
  State<GamesListScreen> createState() => _GamesListScreenState();
}

class _GamesListScreenState extends State<GamesListScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Meus Jogos'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SupabaseService.signOut();
              if (mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: _buildGamesList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/games/new'),
        backgroundColor: AppTheme.primaryPurple,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          
          if (index == 0) {
            // Already on games screen
          } else if (index == 1) {
            context.go('/players');
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.casino),
            label: 'Jogos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Jogadores',
          ),
        ],
      ),
    );
  }

  Widget _buildGamesList() {
    // TODO: Replace with actual data from Supabase
    final demoGames = [
      {
        'id': '1',
        'name': 'Poker de Sexta',
        'date': '15/03/2025',
        'location': 'Casa do Eduardo',
        'players': 6,
        'buyIn': 'R\$ 50,00',
        'status': 'Em andamento',
        'isActive': true,
      },
      {
        'id': '2',
        'name': 'Torneio Mensal',
        'date': '01/03/2025',
        'location': 'Clube de Poker',
        'players': 12,
        'buyIn': 'R\$ 100,00',
        'status': 'Concluído',
        'isActive': false,
      },
      {
        'id': '3',
        'name': 'Poker entre Amigos',
        'date': '20/02/2025',
        'location': 'Apartamento do João',
        'players': 4,
        'buyIn': 'R\$ 25,00',
        'status': 'Concluído',
        'isActive': false,
      },
    ];

    if (demoGames.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.casino_outlined,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum jogo encontrado',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toque no botão + para criar um novo jogo',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: demoGames.length,
      itemBuilder: (context, index) {
        final game = demoGames[index];
        final isActive = game['isActive'] as bool;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isActive
                ? BorderSide(color: AppTheme.primaryPurple, width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: () => context.go('/games/${game['id']}'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          game['name'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.primaryPurple.withOpacity(0.2)
                              : AppTheme.textSecondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          game['status'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: isActive
                                ? AppTheme.primaryPurple
                                : AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildInfoItem(Icons.calendar_today, game['date'] as String),
                      const SizedBox(width: 16),
                      _buildInfoItem(Icons.location_on, game['location'] as String),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoItem(Icons.people, '${game['players']} jogadores'),
                      const SizedBox(width: 16),
                      _buildInfoItem(Icons.attach_money, game['buyIn'] as String),
                    ],
                  ),
                  if (isActive) ...[
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('Adicionar Jogador'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.secondaryBlue,
                            side: BorderSide(color: AppTheme.secondaryBlue),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Continuar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryPurple,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

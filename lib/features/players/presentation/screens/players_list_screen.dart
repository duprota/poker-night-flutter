import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poker_night/core/theme/app_theme.dart';

class PlayersListScreen extends StatefulWidget {
  const PlayersListScreen({super.key});

  @override
  State<PlayersListScreen> createState() => _PlayersListScreenState();
}

class _PlayersListScreenState extends State<PlayersListScreen> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Jogadores'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: _buildPlayersList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement add player functionality
        },
        backgroundColor: AppTheme.primaryPurple,
        child: const Icon(Icons.person_add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          
          if (index == 0) {
            context.go('/games');
          } else if (index == 1) {
            // Already on players screen
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

  Widget _buildPlayersList() {
    // TODO: Replace with actual data from Supabase
    final demoPlayers = [
      {
        'id': '1',
        'name': 'Eduardo Prota',
        'email': 'eduardo@example.com',
        'gamesPlayed': 15,
        'totalWinnings': 'R\$ 750,00',
        'avatar': 'https://i.pravatar.cc/150?img=1',
      },
      {
        'id': '2',
        'name': 'João Silva',
        'email': 'joao@example.com',
        'gamesPlayed': 12,
        'totalWinnings': 'R\$ 520,00',
        'avatar': 'https://i.pravatar.cc/150?img=2',
      },
      {
        'id': '3',
        'name': 'Maria Oliveira',
        'email': 'maria@example.com',
        'gamesPlayed': 8,
        'totalWinnings': 'R\$ 320,00',
        'avatar': 'https://i.pravatar.cc/150?img=3',
      },
    ];

    if (demoPlayers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhum jogador encontrado',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Toque no botão + para adicionar um jogador',
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
      itemCount: demoPlayers.length,
      itemBuilder: (context, index) {
        final player = demoPlayers[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () => context.go('/players/${player['id']}'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(player['avatar'] as String),
                  ),
                  const SizedBox(width: 16),
                  
                  // Player info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player['name'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          player['email'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildInfoChip(
                              Icons.casino,
                              '${player['gamesPlayed']} jogos',
                            ),
                            const SizedBox(width: 8),
                            _buildInfoChip(
                              Icons.attach_money,
                              player['totalWinnings'] as String,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Arrow
                  Icon(
                    Icons.chevron_right,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade700),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

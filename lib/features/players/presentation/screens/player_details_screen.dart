import 'package:flutter/material.dart';
import 'package:poker_night/core/theme/app_theme.dart';

class PlayerDetailsScreen extends StatelessWidget {
  final String playerId;
  
  const PlayerDetailsScreen({super.key, required this.playerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Perfil do Jogador'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Perfil do jogador ID: $playerId\nEm construção...',
          style: TextStyle(color: AppTheme.textPrimary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

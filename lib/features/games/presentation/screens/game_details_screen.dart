import 'package:flutter/material.dart';
import 'package:poker_night/core/theme/app_theme.dart';

class GameDetailsScreen extends StatelessWidget {
  final String gameId;
  
  const GameDetailsScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Detalhes do Jogo'),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Detalhes do jogo ID: $gameId\nEm construção...',
          style: TextStyle(color: AppTheme.textPrimary),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

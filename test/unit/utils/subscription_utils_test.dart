import 'package:flutter_test/flutter_test.dart';
import 'package:poker_night/providers/auth_provider.dart';
import 'package:poker_night/utils/subscription_utils.dart';

void main() {
  group('SubscriptionUtils Tests', () {
    test('canCreateGame deve retornar true para usuários Premium e Pro', () {
      // Verificar para usuário Free
      expect(
        SubscriptionUtils.canCreateGame(SubscriptionStatus.free, 4), 
        true
      );
      
      // Verificar para usuário Free com limite atingido
      expect(
        SubscriptionUtils.canCreateGame(SubscriptionStatus.free, 5), 
        false
      );
      
      // Verificar para usuário Premium
      expect(
        SubscriptionUtils.canCreateGame(SubscriptionStatus.premium, 30), 
        true
      );
      
      // Verificar para usuário Premium com limite atingido
      expect(
        SubscriptionUtils.canCreateGame(SubscriptionStatus.premium, 50), 
        false
      );
      
      // Verificar para usuário Pro (sem limite)
      expect(
        SubscriptionUtils.canCreateGame(SubscriptionStatus.pro, 100), 
        true
      );
    });

    test('canAddPlayer deve retornar true se não atingiu o limite de jogadores', () {
      // Verificar para usuário Free
      expect(
        SubscriptionUtils.canAddPlayer(SubscriptionStatus.free, 7), 
        true
      );
      
      // Verificar para usuário Free com limite atingido
      expect(
        SubscriptionUtils.canAddPlayer(SubscriptionStatus.free, 8), 
        false
      );
      
      // Verificar para usuário Premium
      expect(
        SubscriptionUtils.canAddPlayer(SubscriptionStatus.premium, 19), 
        true
      );
      
      // Verificar para usuário Premium com limite atingido
      expect(
        SubscriptionUtils.canAddPlayer(SubscriptionStatus.premium, 20), 
        false
      );
      
      // Verificar para usuário Pro (sem limite)
      expect(
        SubscriptionUtils.canAddPlayer(SubscriptionStatus.pro, 50), 
        true
      );
    });

    test('canAccessStatistics deve retornar true apenas para usuários Pro', () {
      // Verificar para usuário Free
      expect(
        SubscriptionUtils.canAccessStatistics(SubscriptionStatus.free), 
        false
      );
      
      // Verificar para usuário Premium
      expect(
        SubscriptionUtils.canAccessStatistics(SubscriptionStatus.premium), 
        false
      );
      
      // Verificar para usuário Pro
      expect(
        SubscriptionUtils.canAccessStatistics(SubscriptionStatus.pro), 
        true
      );
    });

    test('canExportData deve retornar true para usuários Premium e Pro', () {
      // Verificar para usuário Free
      expect(
        SubscriptionUtils.canExportData(SubscriptionStatus.free), 
        false
      );
      
      // Verificar para usuário Premium
      expect(
        SubscriptionUtils.canExportData(SubscriptionStatus.premium), 
        true
      );
      
      // Verificar para usuário Pro
      expect(
        SubscriptionUtils.canExportData(SubscriptionStatus.pro), 
        true
      );
    });

    test('getPlayerLimit deve retornar o limite correto para cada tipo de assinatura', () {
      // Verificar para usuário Free
      expect(
        SubscriptionUtils.getPlayerLimit(SubscriptionStatus.free), 
        8
      );
      
      // Verificar para usuário Premium
      expect(
        SubscriptionUtils.getPlayerLimit(SubscriptionStatus.premium), 
        20
      );
      
      // Verificar para usuário Pro (sem limite)
      expect(
        SubscriptionUtils.getPlayerLimit(SubscriptionStatus.pro), 
        null
      );
    });

    test('getGameLimit deve retornar o limite correto para cada tipo de assinatura', () {
      // Verificar para usuário Free
      expect(
        SubscriptionUtils.getGameLimit(SubscriptionStatus.free), 
        5
      );
      
      // Verificar para usuário Premium
      expect(
        SubscriptionUtils.getGameLimit(SubscriptionStatus.premium), 
        50
      );
      
      // Verificar para usuário Pro (sem limite)
      expect(
        SubscriptionUtils.getGameLimit(SubscriptionStatus.pro), 
        null
      );
    });
  });
}

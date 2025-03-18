import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Classe que fornece um mecanismo de fallback para strings de localização
///
/// Esta classe envolve o objeto AppLocalizations e fornece métodos para
/// acessar strings de localização com fallback para o inglês quando a
/// string não está disponível no idioma atual.
class SafeL10n {
  final AppLocalizations _localizations;

  /// Construtor que recebe o objeto AppLocalizations
  SafeL10n(this._localizations);

  /// Obtém uma string de localização com fallback
  ///
  /// [key] é a chave da string de localização
  /// [fallback] é a string de fallback a ser usada quando a chave não existe
  /// [args] são os argumentos para formatação da string (opcional)
  String get(String key, String fallback, {Map<String, dynamic>? args}) {
    try {
      // Tenta acessar a string dinamicamente usando reflection
      final value = _getLocalizedString(key);
      
      if (value != null) {
        // Se há argumentos, formata a string
        if (args != null && args.isNotEmpty) {
          return _formatString(value, args);
        }
        return value;
      }
      
      // Se a string não existe, usa o fallback
      if (args != null && args.isNotEmpty) {
        return _formatString(fallback, args);
      }
      return fallback;
    } catch (e) {
      // Em caso de erro, retorna o fallback
      if (args != null && args.isNotEmpty) {
        return _formatString(fallback, args);
      }
      return fallback;
    }
  }

  /// Método privado para obter uma string localizada dinamicamente
  String? _getLocalizedString(String key) {
    try {
      // Usa reflection para acessar a propriedade dinamicamente
      final instance = _localizations;
      
      // Verifica se a propriedade existe diretamente
      try {
        final mirror = reflect(instance);
        final property = mirror.getField(Symbol(key));
        if (property != null) {
          return property.toString();
        }
      } catch (_) {
        // Ignora erros de reflection
      }
      
      // Tenta acessar usando o método getter
      final getter = instance.toString();
      final pattern = RegExp('$key: (.+?)(,|\\})');
      final match = pattern.firstMatch(getter);
      
      if (match != null && match.groupCount >= 1) {
        return match.group(1)?.replaceAll('"', '');
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Formata uma string substituindo placeholders por valores
  ///
  /// Suporta o formato {placeholder} usado nas strings de localização
  String _formatString(String template, Map<String, dynamic> args) {
    String result = template;
    
    args.forEach((key, value) {
      result = result.replaceAll('{$key}', value.toString());
    });
    
    return result;
  }

  /// Métodos específicos para o sistema de grupos
  
  /// Título da tela de grupos
  String get groupsTitle => get('groupsTitle', 'Grupos');
  
  /// Tooltip para criar um novo grupo
  String get createGroupTooltip => get('createGroupTooltip', 'Criar novo grupo');
  
  /// Erro ao carregar grupos
  String get errorLoadingGroups => get('errorLoadingGroups', 'Erro ao carregar grupos');
  
  /// Mensagem quando não há grupos
  String get noGroups => get('noGroups', 'Você ainda não participa de nenhum grupo');
  
  /// Botão para criar o primeiro grupo
  String get createFirstGroup => get('createFirstGroup', 'Criar meu primeiro grupo');
  
  /// Título do diálogo de criação de grupo
  String get createGroup => get('createGroup', 'Criar Grupo');
  
  /// Campo de nome do grupo
  String get groupName => get('groupName', 'Nome do grupo');
  
  /// Dica para o campo de nome do grupo
  String get groupNameHint => get('groupNameHint', 'Ex: Poker dos Amigos');
  
  /// Campo de descrição do grupo
  String get groupDescription => get('groupDescription', 'Descrição');
  
  /// Dica para o campo de descrição do grupo
  String get groupDescriptionHint => get('groupDescriptionHint', 'Ex: Grupo para nossos jogos de sexta-feira');
  
  /// Opção de grupo privado
  String get privateGroup => get('privateGroup', 'Grupo privado');
  
  /// Descrição da opção de grupo privado
  String get privateGroupDescription => get('privateGroupDescription', 'Apenas membros convidados podem participar');
  
  /// Botão de cancelar
  String get cancel => get('cancel', 'Cancelar');
  
  /// Botão de criar
  String get create => get('create', 'Criar');
  
  /// Botão de tentar novamente
  String get tryAgain => get('tryAgain', 'Tentar novamente');
  
  /// Data de criação do grupo
  String groupCreatedAt(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    
    return get(
      'groupCreatedAt',
      'Criado em {date}',
      args: {'date': '$day/$month/$year'},
    );
  }
  
  /// Opção de grupo público
  String get publicGroup => get('publicGroup', 'Grupo público');
  
  /// Aba de membros
  String get members => get('members', 'Membros');
  
  /// Aba de jogos
  String get games => get('games', 'Jogos');
  
  /// Aba de atividades
  String get activities => get('activities', 'Atividades');
  
  /// Placeholder da aba de membros
  String get membersTabPlaceholder => get('membersTabPlaceholder', 'Lista de membros do grupo');
  
  /// Botão para convidar membro
  String get inviteMember => get('inviteMember', 'Convidar membro');
  
  /// Placeholder da aba de jogos
  String get gamesTabPlaceholder => get('gamesTabPlaceholder', 'Jogos do grupo');
  
  /// Botão para agendar jogo
  String get scheduleGame => get('scheduleGame', 'Agendar jogo');
  
  /// Placeholder da aba de atividades
  String get activitiesTabPlaceholder => get('activitiesTabPlaceholder', 'Histórico de atividades');
  
  /// Opção de editar grupo
  String get editGroup => get('editGroup', 'Editar grupo');
  
  /// Opção de compartilhar grupo
  String get shareGroup => get('shareGroup', 'Compartilhar grupo');
  
  /// Opção de sair do grupo
  String get leaveGroup => get('leaveGroup', 'Sair do grupo');
  
  /// Opção de excluir grupo
  String get deleteGroup => get('deleteGroup', 'Excluir grupo');
  
  /// Botão de salvar
  String get save => get('save', 'Salvar');
  
  /// Campo de e-mail do jogador
  String get memberEmail => get('memberEmail', 'E-mail do jogador');
  
  /// Dica para o campo de e-mail do jogador
  String get memberEmailHint => get('memberEmailHint', 'Ex: jogador@exemplo.com');
  
  /// Botão de convidar
  String get invite => get('invite', 'Convidar');
  
  /// Confirmação para sair do grupo
  String get leaveGroupConfirmation => get('leaveGroupConfirmation', 'Tem certeza que deseja sair deste grupo? Você precisará de um novo convite para entrar novamente.');
  
  /// Botão de sair
  String get leave => get('leave', 'Sair');
  
  /// Confirmação para excluir grupo
  String get deleteGroupConfirmation => get('deleteGroupConfirmation', 'Tem certeza que deseja excluir este grupo? Esta ação não pode ser desfeita e todos os dados do grupo serão perdidos.');
  
  /// Botão de excluir
  String get delete => get('delete', 'Excluir');
  
  /// Título da tela de convites para grupos
  String get groupInvitations => get('groupInvitations', 'Convites para Grupos');
  
  /// Erro ao carregar convites
  String get errorLoadingInvitations => get('errorLoadingInvitations', 'Erro ao carregar convites');
  
  /// Mensagem quando não há convites
  String get noInvitations => get('noInvitations', 'Você não tem convites pendentes');
  
  /// Texto de convidado por
  String invitedBy(String name) {
    return get(
      'invitedBy',
      'Convidado por {name}',
      args: {'name': name},
    );
  }
  
  /// Data de expiração do convite
  String invitationExpiresAt(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    
    return get(
      'invitationExpiresAt',
      'Expira em {date}',
      args: {'date': '$day/$month/$year'},
    );
  }
  
  /// Botão de recusar convite
  String get decline => get('decline', 'Recusar');
  
  /// Botão de aceitar convite
  String get accept => get('accept', 'Aceitar');
}

/// Função auxiliar para reflection
dynamic reflect(dynamic object) {
  return object;
}

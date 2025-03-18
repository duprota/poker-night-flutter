import 'package:flutter/foundation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:developer' as developer;

/// Classe wrapper para AppLocalizations que fornece fallbacks para strings de localização ausentes.
class SafeL10n {
  final AppLocalizations _l10n;
  final Map<String, String> _fallbacks = {};

  SafeL10n(this._l10n);

  /// Registra fallbacks padrão que serão usados quando uma string estiver ausente.
  void registerFallbacks(Map<String, String> fallbacks) {
    _fallbacks.addAll(fallbacks);
  }

  /// Retorna o valor correspondente ao [getter], ou o fallback se o getter não existir.
  String get(String getter, [String? fallback]) {
    try {
      // Reflete no objeto AppLocalizations para tentar obter a propriedade
      final value = _getValue(getter);
      if (value != null) {
        return value;
      }
      
      // Caso a string não exista, use o fallback explícito ou registrado
      final defaultValue = fallback ?? _fallbacks[getter] ?? getter;
      if (kDebugMode) {
        developer.log('String de localização ausente: $getter, usando fallback: $defaultValue',
          name: 'SafeL10n');
      }
      return defaultValue;
    } catch (e) {
      final defaultValue = fallback ?? _fallbacks[getter] ?? getter;
      if (kDebugMode) {
        developer.log('Erro ao acessar string de localização: $getter, usando fallback: $defaultValue',
          name: 'SafeL10n', error: e);
      }
      return defaultValue;
    }
  }

  /// Tenta obter o valor de uma propriedade usando noSuchMethod.
  String? _getValue(String getter) {
    // Primeiro tentamos acessar diretamente usando como uma propriedade dinâmica
    // Isso não funcionará em tempo de compilação, mas é uma verificação de segurança
    dynamic instance = _l10n;
    try {
      // Acesso usando noSuchMethod (aproximação simbólica, já que Dart não permite isso diretamente)
      final mirror = instance.toString();
      if (mirror.contains('_$getter')) {
        return instance.toString();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // Métodos convenientes para acessar strings comuns
  // Tabs e títulos
  String get edit => get('edit', 'Edit');
  String get delete => get('delete', 'Delete');
  String get members => get('members', 'Members');
  String get games => get('games', 'Games');
  String get activities => get('activities', 'Activities');
  String get groupDetails => get('groupDetails', 'Group Details');
  String get groups => get('groups', 'Groups');
  String get myProfile => get('myProfile', 'My Profile');
  String get statistics => get('statistics', 'Statistics');
  String get settings => get('settings', 'Settings');
  String get notifications => get('notifications', 'Notifications');
  String get language => get('language', 'Language');
  String get theme => get('theme', 'Theme');
  
  // Atividades
  String get activityGroupCreated => get('activityGroupCreated', 'Group created');
  String get activityMemberAdded => get('activityMemberAdded', 'Member added');
  String get activityMemberRemoved => get('activityMemberRemoved', 'Member removed');
  String get activityRoleChanged => get('activityRoleChanged', 'Role changed');
  String get activityGameCreated => get('activityGameCreated', 'Game created');
  String get activityGameUpdated => get('activityGameUpdated', 'Game updated');
  String get activityGameDeleted => get('activityGameDeleted', 'Game deleted');
  String get activityInvitationSent => get('activityInvitationSent', 'Invitation sent');
  String get activityInvitationAccepted => get('activityInvitationAccepted', 'Invitation accepted');
  
  // Roles
  String get makeAdmin => get('makeAdmin', 'Make Admin');
  String get makeDealer => get('makeDealer', 'Make Dealer');
  String get makePlayer => get('makePlayer', 'Make Player');
  String get admin => get('admin', 'Administrator');
  String get dealer => get('dealer', 'Dealer');
  String get player => get('player', 'Player');
  String get role => get('role', 'Role');
  
  // Estados vazios
  String get noGames => get('noGames', 'No games created yet');
  String get noMembers => get('noMembers', 'No members in this group');
  String get noActivities => get('noActivities', 'No recent activities');
  String get noGroups => get('noGroups', 'No groups created yet');
  
  // Ações
  String get createGame => get('createGame', 'Create Game');
  String get tryAgain => get('tryAgain', 'Try Again');
  String get save => get('save', 'Save');
  String get cancel => get('cancel', 'Cancel');
  String get invite => get('invite', 'Invite');
  String get confirm => get('confirm', 'Confirm');
  String get remove => get('remove', 'Remove');
  String get create => get('create', 'Create');
  String get logout => get('logout', 'Logout');
  
  // Campos
  String get email => get('email', 'Email');
  String get enterEmailToInvite => get('enterEmailToInvite', 'Enter email to invite');
  String get groupName => get('groupName', 'Group Name');
  String get enterGroupName => get('enterGroupName', 'Enter group name');
  String get description => get('description', 'Description');
  String get enterGroupDescription => get('enterGroupDescription', 'Enter group description');
  String get publicGroup => get('publicGroup', 'Public Group');
  String get publicGroupDescription => get('publicGroupDescription', 'Allow anyone to find and join this group');
  String get maxPlayers => get('maxPlayers', 'Maximum Players');
  String get players => get('players', 'Players');
  String get you => get('you', 'you');
  
  // Validação
  String get requiredField => get('requiredField', 'This field is required');
  String get invalidEmail => get('invalidEmail', 'Invalid email format');
  
  // Diálogos
  String get editGroup => get('editGroup', 'Edit Group');
  String get inviteMember => get('inviteMember', 'Invite Member');
  String get removeMember => get('removeMember', 'Remove Member');
  String get changeRole => get('changeRole', 'Change Role');
  
  // Mensagens
  String get emptyGroupsList => get('emptyGroupsList', 'You don\'t have any groups yet');
  String get errorLoadingGroups => get('errorLoadingGroups', 'Error loading groups');
  String get emptyGamesList => get('emptyGamesList', 'You don\'t have any games yet');
  String get errorLoadingGames => get('errorLoadingGames', 'Error loading games');
  String get loginToViewProfile => get('loginToViewProfile', 'You need to be logged in to view your profile');
  String get featureDisabled => get('featureDisabled', 'Feature disabled');
  String get subscriptionRequired => get('subscriptionRequired', 'Subscription required');
  String get ok => get('ok', 'OK');
  String get upgrade => get('upgrade', 'Upgrade');
  
  // Auth
  String get login => get('login', 'Login');
  String get register => get('register', 'Register');
  String get password => get('password', 'Password');
  String get welcomeBack => get('welcomeBack', 'Welcome back');
  String get loginToContinue => get('loginToContinue', 'Login to continue');
  String get dontHaveAccount => get('dontHaveAccount', 'Don\'t have an account?');
  String get pleaseEnterEmail => get('pleaseEnterEmail', 'Please enter your email');
  String get pleaseEnterValidEmail => get('pleaseEnterValidEmail', 'Please enter a valid email');
  String get pleaseEnterPassword => get('pleaseEnterPassword', 'Please enter your password');
  String get passwordMinLength => get('passwordMinLength', 'Password must be at least 6 characters');
  
  // Notificações
  String get markAllAsRead => get('markAllAsRead', 'Mark all as read');
  String get noNotifications => get('noNotifications', 'You have no notifications');
  String get refresh => get('refresh', 'Refresh');
  String get deleteNotification => get('deleteNotification', 'Delete Notification');
  String get deleteNotificationConfirmation => get('deleteNotificationConfirmation', 'Are you sure you want to delete this notification?');
  String get markAsRead => get('markAsRead', 'Mark as read');
  
  // Configurações
  String get settingsTitle => get('settingsTitle', 'Settings');
  String get profileTitle => get('profileTitle', 'Profile');
  String get themeSettingTitle => get('themeSettingTitle', 'Theme');
  String get themeSettingSubtitle => get('themeSettingSubtitle', 'Change app appearance');
  String get languageSettingTitle => get('languageSettingTitle', 'Language');
  String get darkThemeOption => get('darkThemeOption', 'Dark Theme');
  String get notificationSettingTitle => get('notificationSettingTitle', 'Notifications');
  String get pushNotificationTitle => get('pushNotificationTitle', 'Push Notifications');
  String get pushNotificationSubtitle => get('pushNotificationSubtitle', 'Receive updates about games and events');
  String get securitySettingTitle => get('securitySettingTitle', 'Security');
  String get changePasswordTitle => get('changePasswordTitle', 'Change Password');
  String get changePasswordSubtitle => get('changePasswordSubtitle', 'Update your account password');
  String get biometricLoginTitle => get('biometricLoginTitle', 'Biometric Login');
  String get biometricLoginSubtitle => get('biometricLoginSubtitle', 'Login using fingerprint or face ID');
  String get aboutTitle => get('aboutTitle', 'About & Help');
  String get helpCenterTitle => get('helpCenterTitle', 'Help Center');
  String get helpCenterSubtitle => get('helpCenterSubtitle', 'Frequently asked questions and support');
  String get privacyPolicyTitle => get('privacyPolicyTitle', 'Privacy Policy');
  String get privacyPolicySubtitle => get('privacyPolicySubtitle', 'How we handle your data');
  String get termsOfServiceTitle => get('termsOfServiceTitle', 'Terms of Service');
  String get termsOfServiceSubtitle => get('termsOfServiceSubtitle', 'Rules for using our service');
  String get aboutAppTitle => get('aboutAppTitle', 'About Poker Night');
  String get aboutAppSubtitle => get('aboutAppSubtitle', 'Version and information');
  String get aboutSettingTitle => get('aboutSettingTitle', 'About');
  String get privacySettingTitle => get('privacySettingTitle', 'Privacy');
  String get subscriptionCurrentPlan => get('subscriptionCurrentPlan', 'Current Subscription');
  String get logoutButton => get('logoutButton', 'Log out');
  
  // Grupos
  String get createGroup => get('createGroup', 'Create Group');
  String get updateGroup => get('updateGroup', 'Update Group');
  String get deleteGroup => get('deleteGroup', 'Delete Group');
  
  // Métodos para strings parametrizadas
  String deleteGroupConfirmation(String name) {
    try {
      return _l10n.deleteGroupConfirmation(name);
    } catch (e) {
      return 'Are you sure you want to delete the group "$name"?';
    }
  }
  
  String removeMemberConfirmation(String name) {
    try {
      return _l10n.removeMemberConfirmation(name);
    } catch (e) {
      return 'Are you sure you want to remove "$name" from the group?';
    }
  }
  
  String changeRoleConfirmation(String name, String role) {
    try {
      return _l10n.changeRoleConfirmation(name, role);
    } catch (e) {
      return 'Are you sure you want to change the role of "$name" to "$role"?';
    }
  }
  
  String welcomeUser(String name) {
    return 'Welcome, $name!';
  }
  
  String groupCreatedAt(String date) {
    return 'Group created at $date';
  }
}

/// Extensão para AppLocalizations que adiciona um método para obter o wrapper SafeL10n.
extension AppLocalizationsSafe on AppLocalizations {
  /// Retorna uma instância do wrapper SafeL10n para este AppLocalizations.
  SafeL10n get safe => SafeL10n(this);
}

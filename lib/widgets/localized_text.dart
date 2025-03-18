import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poker_night/core/utils/l10n_extensions.dart';

/// Widget que facilita o uso de textos localizados com fallback para inglês
/// 
/// Este widget utiliza nossa implementação SafeL10n para garantir que textos
/// sempre serão exibidos, mesmo que faltem strings em alguns idiomas.
class LocalizedText extends StatelessWidget {
  /// A chave do texto na localização
  final String textKey;
  
  /// Parâmetros para textos que suportam formatação (opcional)
  final List<dynamic>? params;
  
  /// Style do texto (opcional)
  final TextStyle? style;
  
  /// Alinhamento do texto (opcional)
  final TextAlign? textAlign;
  
  /// Número máximo de linhas (opcional)
  final int? maxLines;
  
  /// Comportamento de overflow (opcional)
  final TextOverflow? overflow;
  
  /// TextScaler para ajustar o tamanho do texto (opcional)
  final TextScaler? textScaler;
  
  /// Valor de fallback caso a chave não seja encontrada (opcional)
  final String? fallback;

  const LocalizedText(
    this.textKey, {
    Key? key,
    this.params,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.textScaler,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final safeL10n = l10n.safe;
    
    // Se não temos parâmetros, usamos o método get diretamente
    String text = safeL10n.get(textKey, fallback);
    
    // Se temos parâmetros e a string suporta formatação, tentamos aplicar
    if (params != null && params!.isNotEmpty) {
      try {
        // Esta é uma simplificação, idealmente implementaríamos uma forma 
        // dinâmica de chamar métodos com argumentos variáveis
        if (params!.length == 1) {
          text = _getFormattedText(safeL10n, textKey, [params!.first]);
        } else if (params!.length == 2) {
          text = _getFormattedText(safeL10n, textKey, [params![0], params![1]]);
        } else if (params!.length == 3) {
          text = _getFormattedText(safeL10n, textKey, [params![0], params![1], params![2]]);
        }
      } catch (e) {
        // Em caso de erro na formatação, usamos o texto sem formato
        text = safeL10n.get(textKey, fallback);
      }
    }
    
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      textScaler: textScaler,
    );
  }
  
  /// Tenta obter o texto formatado com os parâmetros fornecidos
  String _getFormattedText(SafeL10n safeL10n, String textKey, List<dynamic> params) {
    // Aqui implementaríamos a lógica para cada método parametrizado conhecido
    // Esta é uma simplificação, o ideal seria usar reflexão ou um mapa de funções
    
    // Exemplo para algumas funções parametrizadas conhecidas
    switch (textKey) {
      case 'deleteGroupConfirmation':
        if (params.isNotEmpty && params[0] is String) {
          return safeL10n.deleteGroupConfirmation(params[0] as String);
        }
        break;
      case 'removeMemberConfirmation':
        if (params.isNotEmpty && params[0] is String) {
          return safeL10n.removeMemberConfirmation(params[0] as String);
        }
        break;
      case 'changeRoleConfirmation':
        if (params.length >= 2 && params[0] is String && params[1] is String) {
          return safeL10n.changeRoleConfirmation(
            params[0] as String, 
            params[1] as String
          );
        }
        break;
    }
    
    // Se não conhecemos o método ou temos parâmetros incorretos, retorna o texto base
    return safeL10n.get(textKey, fallback);
  }
}

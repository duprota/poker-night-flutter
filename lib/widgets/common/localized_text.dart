import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poker_night/core/utils/l10n_extensions.dart';

/// Widget para exibir textos traduzidos com fallback para inglês
class LocalizedText extends StatelessWidget {
  /// Chave de tradução (nova forma recomendada)
  final String? translationKey;
  
  /// Argumentos para formatação (nova forma recomendada)
  final Map<String, dynamic>? args;
  
  /// Função que constrói o texto traduzido (compatibilidade com código existente)
  final String Function(AppLocalizations l10n)? textBuilder;
  
  /// Estilo do texto
  final TextStyle? style;
  
  /// Alinhamento do texto
  final TextAlign? textAlign;
  
  /// Número máximo de linhas
  final int? maxLines;
  
  /// Comportamento de overflow
  final TextOverflow? overflow;
  
  /// Se o texto deve quebrar
  final bool? softWrap;

  /// Construtor para uso com textBuilder (compatibilidade)
  const LocalizedText({
    super.key,
    this.textBuilder,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : translationKey = null, args = null;
  
  /// Construtor para uso com chave de tradução (nova forma recomendada)
  const LocalizedText.key({
    super.key,
    required this.translationKey,
    this.args,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : textBuilder = null;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final safeL10n = l10n.safe;
    
    String text;
    if (textBuilder != null) {
      // Compatibilidade com código existente
      try {
        text = textBuilder!(l10n);
      } catch (e) {
        // Em caso de erro ao construir o texto, retornamos um texto genérico
        text = 'Translation error';
      }
    } else if (translationKey != null) {
      // Nova forma usando SafeL10n para obter a tradução com fallback
      try {
        // Tentamos acessar dynamicamente a propriedade pelo nome
        // Se não conseguirmos, usamos o método get com fallback
        switch (translationKey) {
          case 'appTitle':
            text = l10n.appTitle;
            break;
          case 'welcomeMessage':
            text = l10n.welcomeMessage;
            break;
          default:
            // Para qualquer outra chave, usamos o método get com fallback
            text = safeL10n.get(translationKey!, 'Missing translation');
            break;
        }
      } catch (e) {
        text = 'Translation error: $e';
      }
    } else {
      // Se não temos nem textBuilder nem translationKey, exibimos um erro
      text = 'Invalid LocalizedText configuration';
    }
    
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}

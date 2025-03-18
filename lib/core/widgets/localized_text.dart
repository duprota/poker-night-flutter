import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:poker_night/core/utils/l10n_extensions.dart';

/// Widget para exibir texto localizado com fallback
///
/// Este widget facilita o uso de strings localizadas em todo o aplicativo,
/// fornecendo um mecanismo de fallback para quando a string não está disponível
/// no idioma atual.
class LocalizedText extends StatelessWidget {
  /// A chave da string de localização
  final String textKey;
  
  /// A string de fallback a ser usada quando a chave não existe
  final String fallback;
  
  /// Os argumentos para formatação da string (opcional)
  final Map<String, dynamic>? args;
  
  /// O estilo do texto (opcional)
  final TextStyle? style;
  
  /// O alinhamento do texto (opcional)
  final TextAlign? textAlign;
  
  /// O número máximo de linhas (opcional)
  final int? maxLines;
  
  /// Se o texto deve ser truncado com elipses (opcional)
  final bool? overflow;
  
  /// Construtor
  const LocalizedText({
    super.key,
    required this.textKey,
    required this.fallback,
    this.args,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    if (localizations == null) {
      return Text(
        fallback,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow == true ? TextOverflow.ellipsis : null,
      );
    }
    
    final safeL10n = SafeL10n(localizations);
    
    return Text(
      safeL10n.get(textKey, fallback, args: args),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow == true ? TextOverflow.ellipsis : null,
    );
  }
}

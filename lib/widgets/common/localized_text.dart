import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Widget para exibir textos traduzidos
class LocalizedText extends StatelessWidget {
  /// Construtor
  const LocalizedText({
    super.key,
    required this.textBuilder,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  /// Função que constrói o texto traduzido
  final String Function(AppLocalizations l10n) textBuilder;
  
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Text(
      textBuilder(l10n),
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }
}

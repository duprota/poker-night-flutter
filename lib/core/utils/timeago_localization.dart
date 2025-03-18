import 'package:timeago/timeago.dart' as timeago;

/// Inicializa as localizações do pacote timeago
void initTimeagoLocalization() {
  // Adicionar suporte para português do Brasil
  timeago.setLocaleMessages('pt_BR', _PtBrMessages());
}

/// Classe para mensagens em português do Brasil para o pacote timeago
class _PtBrMessages implements timeago.LookupMessages {
  @override
  String prefixAgo() => 'há';
  @override
  String prefixFromNow() => 'em';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'agora';
  @override
  String aboutAMinute(int minutes) => 'um minuto';
  @override
  String minutes(int minutes) => '$minutes minutos';
  @override
  String aboutAnHour(int minutes) => 'uma hora';
  @override
  String hours(int hours) => '$hours horas';
  @override
  String aDay(int hours) => 'um dia';
  @override
  String days(int days) => '$days dias';
  @override
  String aboutAMonth(int days) => 'um mês';
  @override
  String months(int months) => '$months meses';
  @override
  String aboutAYear(int year) => 'um ano';
  @override
  String years(int years) => '$years anos';
  @override
  String wordSeparator() => ' ';
}

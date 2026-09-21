class EmergencyContacts {
  EmergencyContacts._();

  static const Map<String, Map<String, String>> byDistrict = {
    'mala': {
      'policia': '105',
      'ambulancia': '106',
      'bomberos': '116',
      'serenazgo': 'NUMERO_VERIFICADO_DE_MALA',
    },
    'villa el salvador': {
      'policia': '(01)287 3804',
      'ambulancia': '959235344',
      'bomberos': '(01)287 7423',
      'serenazgo': '(01)510 0200',
    },
  };

  static const Map<String, String> nationalFallback = {
    'policia': '105',
    'ambulancia': '106',
    'bomberos': '116',
  };
}
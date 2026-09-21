class EmergencyAiResult {
  final String service;
  final String priority;
  final double confidence;
  final String explanation;

  const EmergencyAiResult({
    required this.service,
    required this.priority,
    required this.confidence,
    required this.explanation,
  });

  factory EmergencyAiResult.fromJson(
      Map<String, dynamic> json,
      ) {
    final service = json['servicio'];
    final priority = json['prioridad'];
    final confidence = json['confianza'];
    final explanation = json['explicacion'];

    if (service is! String ||
        priority is! String ||
        confidence is! num ||
        explanation is! String) {
      throw const FormatException(
        'La respuesta de la IA tiene un formato incorrecto.',
      );
    }

    return EmergencyAiResult(
      service: service.trim().toLowerCase(),
      priority: priority.trim().toLowerCase(),
      confidence: confidence.toDouble(),
      explanation: explanation.trim(),
    );
  }
}
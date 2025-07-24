class FieldDefinition {
  final String identifier;
  final String title;
  final String? help; // ← Campo opcional
  final String type;
  final bool required;
  final bool hide; // ← Campo opcional con valor por defecto
  final Map<String, dynamic> context;

  FieldDefinition({
    required this.identifier,
    required this.title,
    this.help,
    required this.type,
    required this.required,
    this.hide = false,
    required this.context,
  });

  factory FieldDefinition.fromJson(Map<String, dynamic> json) {
    return FieldDefinition(
      identifier: json['identifier'] as String,
      title: json['title'] as String,
      help: json['help'] as String?,                        // ← Puede ser null
      type: json['type'] as String,
      required: json['required'] as bool,
      hide: json['hide'] as bool? ?? false,                 // ← Si no viene, usar false
      context: Map<String, dynamic>.from(json['context'] ?? {}),
    );
  }
}

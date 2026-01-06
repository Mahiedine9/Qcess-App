class ZoneDTO {
  final int id;
  final String name;
  final String? description;
  final String? status;

  ZoneDTO({
    required this.id,
    required this.name,
    this.description,
    this.status,
  });

  factory ZoneDTO.fromJson(Map<String, dynamic> json) {
    return ZoneDTO(
      id: (json['id'] as num).toInt(),
      name: (json['name'] as String?) ?? '',
      description: json['description'] as String?,
      status: json['status'] as String?,
    );
  }
}

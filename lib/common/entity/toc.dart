// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Toc {
  DateTime date;
  String preview;
  Toc({
    required this.date,
    required this.preview,
  });

  Toc copyWith({
    DateTime? date,
    String? preview,
  }) {
    return Toc(
      date: date ?? this.date,
      preview: preview ?? this.preview,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'date': date.millisecondsSinceEpoch,
      'preview': preview,
    };
  }

  factory Toc.fromMap(Map<String, dynamic> map) {
    return Toc(
      date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
      preview: map['preview'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Toc.fromJson(String source) =>
      Toc.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Toc(date: $date, preview: $preview)';

  @override
  bool operator ==(covariant Toc other) {
    if (identical(this, other)) return true;

    return other.date == date && other.preview == preview;
  }

  @override
  int get hashCode => date.hashCode ^ preview.hashCode;
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:flutter/material.dart';

class Mood {
  IconData icon;
  String name;
  Mood({
    required this.icon,
    required this.name,
  });

  static Mood get unknown => Mood(icon: Icons.question_mark, name: 'Unknown');

  Mood copyWith({
    IconData? icon,
    String? name,
  }) {
    return Mood(
      icon: icon ?? this.icon,
      name: name ?? this.name,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'icon': icon.codePoint,
      'name': name,
    };
  }

  factory Mood.fromMap(Map<String, dynamic> map) {
    return Mood(
      icon: IconData(map['icon'] as int, fontFamily: 'MaterialIcons'),
      name: map['name'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Mood.fromJson(String source) =>
      Mood.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Mood(icon: $icon, name: $name)';

  @override
  bool operator ==(covariant Mood other) {
    if (identical(this, other)) return true;

    return other.icon == icon && other.name == name;
  }

  @override
  int get hashCode => icon.hashCode ^ name.hashCode;
}

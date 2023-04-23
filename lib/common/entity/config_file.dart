// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'entity.dart';

/// [.config]
///
/// 1    diary name
/// 2    cover path
/// 3    description
/// 4    toc
///

enum ConfigItem { coverPath, description }

class ConfigFile {
  final List<String> _argv = [];
  String diaryName;
  String coverPath;
  String description;
  List<Toc> tocList;
  ConfigFile({
    required this.diaryName,
    required this.coverPath,
    required this.description,
    required this.tocList,
  }) {
    _argv.addAll([coverPath, description]);
  }

  bool get isHasCover => coverPath.isNotEmpty;

  factory ConfigFile.empty() {
    return ConfigFile(
        coverPath: "", diaryName: "", description: "", tocList: []);
  }
  void setArgv(ConfigItem item, String value) => _argv[item.index] = value;

  String getArgv(ConfigItem item) => _argv[item.index];

  ConfigFile copyWith({
    String? diaryName,
    String? coverPath,
    String? description,
    List<Toc>? tocList,
  }) {
    return ConfigFile(
      diaryName: diaryName ?? this.diaryName,
      coverPath: coverPath ?? this.coverPath,
      description: description ?? this.description,
      tocList: tocList ?? this.tocList,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'diaryName': diaryName,
      'coverPath': coverPath,
      'description': description,
      'tocList': tocList.map((x) => x.toMap()).toList(),
    };
  }

  factory ConfigFile.fromMap(Map<String, dynamic> map) {
    return ConfigFile(
      diaryName: map['diaryName'] as String,
      coverPath: map['coverPath'] as String,
      description: map['description'] as String,
      tocList: List<Toc>.from(
        (map['tocList'] as List<int>).map<Toc>(
          (x) => Toc.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory ConfigFile.fromJson(String source) =>
      ConfigFile.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ConfigFile(diaryName: $diaryName, coverPath: $coverPath, description: $description, tocList: $tocList)';
  }

  @override
  bool operator ==(covariant ConfigFile other) {
    if (identical(this, other)) return true;

    return other.diaryName == diaryName &&
        other.coverPath == coverPath &&
        other.description == description &&
        listEquals(other.tocList, tocList);
  }

  @override
  int get hashCode {
    return diaryName.hashCode ^
        coverPath.hashCode ^
        description.hashCode ^
        tocList.hashCode;
  }
}

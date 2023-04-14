// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

/// [.config]
///
/// 1    diary name
/// 2    cover path
/// 3    description
///

enum ConfigItem { coverPath, description }

class ConfigFile {
  final List<String> _argv = [];
  String diaryName;
  String coverPath;
  String description;
  ConfigFile({
    required this.diaryName,
    required this.coverPath,
    required this.description,
  }) {
    _argv.addAll([coverPath, description]);
  }
  void setArgv(ConfigItem item, String value) => _argv[item.index] = value;
  String getArgv(ConfigItem item) => _argv[item.index];
  factory ConfigFile.fromData(String data) {
    final List<String> argvList = data.split('\n');
    return ConfigFile(
        diaryName: argvList[0],
        coverPath: argvList[1],
        description: argvList[2]);
  }

  String toData() {
    return '$diaryName\n$coverPath\n$description\n';
  }

  ConfigFile copyWith({
    String? diaryName,
    String? coverPath,
    String? description,
  }) {
    return ConfigFile(
      diaryName: diaryName ?? this.diaryName,
      coverPath: coverPath ?? this.coverPath,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'diaryName': diaryName,
      'coverPath': coverPath,
      'description': description,
    };
  }

  factory ConfigFile.fromMap(Map<String, dynamic> map) {
    return ConfigFile(
      diaryName: map['diaryName'] as String,
      coverPath: map['coverPath'] as String,
      description: map['description'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ConfigFile.fromJson(String source) =>
      ConfigFile.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ConfigFile( diaryName: $diaryName, coverPath: $coverPath, description: $description)';
  }

  @override
  bool operator ==(covariant ConfigFile other) {
    if (identical(this, other)) return true;

    return other.diaryName == diaryName &&
        other.coverPath == coverPath &&
        other.description == description;
  }

  @override
  int get hashCode {
    return diaryName.hashCode ^ coverPath.hashCode ^ description.hashCode;
  }
}

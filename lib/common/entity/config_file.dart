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

  void updateTocList(DiaryContent diaryContent) {
    bool isNeedNew = true;
    for (var toc in tocList) {
      if (DiaryBook.timeToString(toc.date) ==
          DiaryBook.timeToString(diaryContent.targetTime)) {
        toc.preview = diaryContent.oneSentenceSummary;
        isNeedNew = false;
      }
    }
    if (isNeedNew) {
      tocList.insert(
          0,
          Toc(
              date: diaryContent.targetTime,
              preview: diaryContent.oneSentenceSummary));
    }
  }

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

  factory ConfigFile.fromMap(Map<String, dynamic> map) {
    return ConfigFile(
      diaryName: map['diaryName'] as String,
      coverPath: map['coverPath'] as String,
      description: map['description'] as String,
      tocList: List<Toc>.from(
        (map['tocList'].cast<Map<String, dynamic>>()
                as List<Map<String, dynamic>>)
            .map<Toc>(
          (x) => Toc.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }
}

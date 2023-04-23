// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:thinwrite/common/utils/utils.dart';

/// DiaryContentFile detail
///
/// 1[0] targetTime 日记记录的日期
/// 2[1] createTime 日记创建的日期
/// 3[2] modifyTime 日记最后修改的日期
/// 4[3] weather 天气
/// 5[4] mood 心情
/// 6[5] one sentence summary 一句话总结
/// 7[6]
/// 8[7] body 日记内容
///

class DiaryContent {
  DateTime targetTime;
  DateTime createTime;
  DateTime modifyTime;
  Weather weather;
  Mood mood;
  String oneSentenceSummary;
  String body;

  DiaryContent({
    required this.targetTime,
    required this.createTime,
    required this.modifyTime,
    required this.weather,
    required this.mood,
    required this.oneSentenceSummary,
    required this.body,
  });

  factory DiaryContent.empty() {
    DateTime curTime = DateTime.now();
    return DiaryContent(
        targetTime: curTime,
        createTime: curTime,
        modifyTime: curTime,
        weather: Weather.unknown,
        mood: Mood.unknown,
        oneSentenceSummary: "",
        body: "");
  }

  Future<void> loadFromFile(String filePath) async {
    File file = File(filePath);
    List<String> content = await file.readAsLines();
    int contentOffset = 0;
    targetTime = DateTime.parse(content[contentOffset++]);
    createTime = DateTime.parse(content[contentOffset++]);
    modifyTime = DateTime.parse(content[contentOffset++]);
    weather = Weather.values[
        int.tryParse(content[contentOffset++]) ?? Weather.unknown.index];
    mood = Mood.fromJson(content[contentOffset++]);
    oneSentenceSummary = content[contentOffset++];
    for (; contentOffset < content.length;) {
      body += '${content[contentOffset++]}\n';
    }
  }

  String get header {
    String ret = '''
# ${targetTime.year}年${targetTime.month}月${targetTime.day}日 ${weather.toChinese()}
### $mood
| oneSentenceSummary

---

''';

    return ret;
  }

  String toFileString() {
    String ret = "";
    ret += '$createTime\n';
    ret += '$modifyTime\n';
    ret += '${weather.index}\n';
    ret += '${mood.toJson()}\n';
    ret += '$oneSentenceSummary\n';
    ret += '$body\n';
    return ret;
  }

  DiaryContent copyWith({
    DateTime? targetTime,
    DateTime? createTime,
    DateTime? modifyTime,
    Weather? weather,
    Mood? mood,
    String? oneSentenceSummary,
    String? body,
  }) {
    return DiaryContent(
      targetTime: targetTime ?? this.targetTime,
      createTime: createTime ?? this.createTime,
      modifyTime: modifyTime ?? this.modifyTime,
      weather: weather ?? this.weather,
      mood: mood ?? this.mood,
      oneSentenceSummary: oneSentenceSummary ?? this.oneSentenceSummary,
      body: body ?? this.body,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'targetTime': targetTime.millisecondsSinceEpoch,
      'createTime': createTime.millisecondsSinceEpoch,
      'modifyTime': modifyTime.millisecondsSinceEpoch,
      'weather': weather.index,
      'mood': mood.toMap(),
      'oneSentenceSummary': oneSentenceSummary,
      'body': body,
    };
  }

  factory DiaryContent.fromMap(Map<String, dynamic> map) {
    return DiaryContent(
      targetTime: DateTime.fromMillisecondsSinceEpoch(map['targetTime'] as int),
      createTime: DateTime.fromMillisecondsSinceEpoch(map['createTime'] as int),
      modifyTime: DateTime.fromMillisecondsSinceEpoch(map['modifyTime'] as int),
      weather: Weather.values[map['weather'] as int],
      mood: Mood.fromMap(map['mood'] as Map<String, dynamic>),
      oneSentenceSummary: map['oneSentenceSummary'] as String,
      body: map['body'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DiaryContent.fromJson(String source) =>
      DiaryContent.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DiaryContent(targetTime: $targetTime, createTime: $createTime, modifyTime: $modifyTime, weather: $weather, mood: $mood, oneSentenceSummary: $oneSentenceSummary, body: $body)';
  }

  @override
  bool operator ==(covariant DiaryContent other) {
    if (identical(this, other)) return true;

    return other.targetTime == targetTime &&
        other.createTime == createTime &&
        other.modifyTime == modifyTime &&
        other.weather == weather &&
        other.mood == mood &&
        other.oneSentenceSummary == oneSentenceSummary &&
        other.body == body;
  }

  @override
  int get hashCode {
    return targetTime.hashCode ^
        createTime.hashCode ^
        modifyTime.hashCode ^
        weather.hashCode ^
        mood.hashCode ^
        oneSentenceSummary.hashCode ^
        body.hashCode;
  }
}

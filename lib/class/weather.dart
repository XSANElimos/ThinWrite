enum Weather {
  sunny,
  windy,
  raining;

  String toChinese() {
    switch (this) {
      case sunny:
        return '晴天';
      case windy:
        return '有风';
      case raining:
        return '下雨';
      default:
        return '未知天气';
    }
  }
}

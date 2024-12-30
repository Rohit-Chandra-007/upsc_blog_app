int calCulateReadingTime(String content) {
  int wordsPerMinute = 200;
  int wordCount = content.split(RegExp(r'\s+')).length;
  int readingTimeInMinutes = (wordCount / wordsPerMinute).ceil();
  return readingTimeInMinutes;
}

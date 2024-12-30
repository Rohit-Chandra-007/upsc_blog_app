String formatDateTime(DateTime dateTime) {
  // Format: DD MMM YYYY
  String day = dateTime.day.toString().padLeft(2, '0');
  List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  String month = months[dateTime.month - 1];
  String year = dateTime.year.toString();

  return '$day $month $year';
}
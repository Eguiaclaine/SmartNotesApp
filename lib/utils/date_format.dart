import 'package:intl/intl.dart';

final _displayFormat = DateFormat('MMM d, yyyy h:mm a');

String formatNoteDateTime(DateTime date) => _displayFormat.format(date.toLocal());

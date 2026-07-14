class NotificationService {

  NotificationService._();

  static final NotificationService instance = NotificationService._();



  Future<void> initialize() async {}



  Future<bool> requestPermissions() async => true;



  Future<void> scheduleNoteReminder({

    required String noteId,

    required String title,

    required String body,

    required DateTime reminderAt,

  }) async {}



  Future<void> cancelNoteReminder(String noteId) async {}

}



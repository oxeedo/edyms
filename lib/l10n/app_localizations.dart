import 'package:flutter/widgets.dart';
import 'lang_en.dart';
import 'lang_bn.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('bn'),
  ];

  // Core string tables – each language lives in its own file for easy extension.
  static const Map<String, Map<String, String>> _values =
      <String, Map<String, String>>{
        'en': kLangEn,
        'bn': kLangBn,
      };

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String _t(String key) {
    final lang = locale.languageCode;
    return _values[lang]?[key] ?? _values['en']![key] ?? key;
  }

  // Strongly-typed getters for most-used strings
  String get login => _t('login');
  String get signup => _t('signup');
  String get email => _t('email');
  String get password => _t('password');
  String get confirmPassword => _t('confirmPassword');
  String get forgotPassword => _t('forgotPassword');
  String get resetPassword => _t('resetPassword');
  String get resetPasswordTitle => _t('resetPasswordTitle');
  String get resetPasswordSubtitle => _t('resetPasswordSubtitle');
  String get sendResetLink => _t('sendResetLink');
  String get backToLogin => _t('backToLogin');
  String get otpVerification => _t('otpVerification');
  String get otpVerificationTitle => _t('otpVerificationTitle');
  String get otpVerificationSubtitle => _t('otpVerificationSubtitle');
  String get verify => _t('verify');
  String get resendCode => _t('resendCode');
  String get didntReceiveCode => _t('didntReceiveCode');
  String get createNewPasswordTitle => _t('createNewPasswordTitle');
  String get createNewPasswordSubtitle => _t('createNewPasswordSubtitle');
  String get newPassword => _t('newPassword');
  String get confirmNewPassword => _t('confirmNewPassword');
  String get updatePassword => _t('updatePassword');
  String get passwordResetSuccess => _t('passwordResetSuccess');
  String get passwordResetSuccessMessage => _t('passwordResetSuccessMessage');
  String get loginWith => _t('loginWith');
  String get continueWithGoogle => _t('continueWithGoogle');
  String get firstName => _t('firstName');
  String get lastName => _t('lastName');

  String get onbSkip => _t('onbSkip');
  String get onb1Title => _t('onb1Title');
  String get onb1Subtitle => _t('onb1Subtitle');
  String get onb2Title => _t('onb2Title');
  String get onb2Subtitle => _t('onb2Subtitle');
  String get onb3Title => _t('onb3Title');
  String get onb3Subtitle => _t('onb3Subtitle');
  String get onb4Title => _t('onb4Title');
  String get onb4Subtitle => _t('onb4Subtitle');

  // Home Screen
  String get search => _t('search');
  String get hello => _t('hello');
  String get topCategories => _t('topCategories');
  String get seeAll => _t('seeAll');
  String get popularCourses => _t('popularCourses');
  String get aiSuggestions => _t('aiSuggestions');
  String get mostRecent => _t('mostRecent');
  String get lessons => _t('lessons');
  String get reviews => _t('reviews');
  String get courses => _t('courses');
  String get home => _t('home');
  String get message => _t('message');
  String get myCourse => _t('myCourse');
  String get wishlist => _t('wishlist');
  String get events => _t('events');
  String get profile => _t('profile');

  // Filter
  String get searchFilter => _t('searchFilter');
  String get categories => _t('categories');
  String get price => _t('price');
  String get duration => _t('duration');
  String get design => _t('design');
  String get painting => _t('painting');
  String get coding => _t('coding');
  String get music => _t('music');
  String get visualIdentity => _t('visualIdentity');
  String get mathematics => _t('mathematics');
  String get hours3to8 => _t('hours3to8');
  String get hours8to14 => _t('hours8to14');
  String get hours14to20 => _t('hours14to20');
  String get hours20to24 => _t('hours20to24');
  String get hours24to30 => _t('hours24to30');
  String get complexity => _t('complexity');
  String get beginner => _t('beginner');
  String get intermediate => _t('intermediate');
  String get advanced => _t('advanced');
  String get reviewRating => _t('reviewRating');
  String get stars4Plus => _t('stars4Plus');
  String get stars3Plus => _t('stars3Plus');
  String get stars2Plus => _t('stars2Plus');
  String get stars1Plus => _t('stars1Plus');
  String get clear => _t('clear');
  String get applyFilter => _t('applyFilter');

  // Course Details
  String get courseDetails => _t('courseDetails');
  String get aboutThisCourse => _t('aboutThisCourse');
  String get readMore => _t('readMore');
  String get playlist => _t('playlist');
  String get review => _t('review');
  String get students => _t('students');
  String get enrollCourse => _t('enrollCourse');
  String get whatIsUiDesign => _t('whatIsUiDesign');
  String get courseDescription => _t('courseDescription');
  String get readLess => _t('readLess');
  String get video => _t('video');
  String get quiz => _t('quiz');
  String get assignment => _t('assignment');
  String get curriculums => _t('curriculums');
  String get instructor => _t('instructor');
  String get instructorCard => _t('instructorCard');

  // Profile
  String get settings => _t('settings');
  String get settingsSubtitle => _t('settingsSubtitle');
  String get myCourses => _t('myCourses');
  String get myCoursesSubtitle => _t('myCoursesSubtitle');
  String get wishlistSubtitle => _t('wishlistSubtitle');
  String get aiPreferences => _t('aiPreferences');
  String get aiPreferencesSubtitle => _t('aiPreferencesSubtitle');
  String get notifications => _t('notifications');
  String get notificationsSubtitle => _t('notificationsSubtitle');
  String get darkMode => _t('darkMode');
  String get darkModeSubtitle => _t('darkModeSubtitle');
  String get language => _t('language');
  String get helpSupport => _t('helpSupport');
  String get helpSupportSubtitle => _t('helpSupportSubtitle');
  String get about => _t('about');
  String get aboutSubtitle => _t('aboutSubtitle');
  String get logout => _t('logout');
  String get level => _t('level');
  String get levelValue => _t('levelValue');
  String get accountCourses => _t('accountCourses');
  String get preferences => _t('preferences');
  String get supportInfo => _t('supportInfo');

  // Chat
  String get messages => _t('messages');
  String get typeMessage => _t('typeMessage');
  String get online => _t('online');
  String get typing => _t('typing');
  String get sent => _t('sent');
  String get delivered => _t('delivered');
  String get read => _t('read');
  String get now => _t('now');
  String get minutesAgo => _t('minutesAgo');
  String get hoursAgo => _t('hoursAgo');
  String get yesterday => _t('yesterday');
  String get viewProfile => _t('viewProfile');
  String get muteNotifications => _t('muteNotifications');
  String get clearChat => _t('clearChat');
  String get blockUser => _t('blockUser');
  String get reportUser => _t('reportUser');
  String get chatHistory => _t('chatHistory');
  String get tellUsAboutYourself => _t('tellUsAboutYourself');
  String get whatAreYourInterests => _t('whatAreYourInterests');
  String get selectYourInterests => _t('selectYourInterests');
  String get whatIsYourSkillLevel => _t('whatIsYourSkillLevel');
  String get whatAreYourGoals => _t('whatAreYourGoals');
  String get getPersonalizedCourses => _t('getPersonalizedCourses');
  String get basedOnYourPreferences => _t('basedOnYourPreferences');
  String get recommendedForYou => _t('recommendedForYou');
  String get startLearning => _t('startLearning');
  String get updatePreferences => _t('updatePreferences');
  String get dashboard => _t('dashboard');
  String get payments => _t('payments');
  String get myAssignments => _t('myAssignments');
  String get myQuizAttempts => _t('myQuizAttempts');
  String get certificates => _t('certificates');
  String get continueLearning => _t('continueLearning');
  String get completed => _t('completed');
  String get confirmed => _t('confirmed');
  String get inProgress => _t('inProgress');
  String get notStarted => _t('notStarted');
  String get totalCourses => _t('totalCourses');
  String get completedCourses => _t('completedCourses');
  String get inProgressCourses => _t('inProgressCourses');
  String get totalSpent => _t('totalSpent');
  String get recentPayments => _t('recentPayments');
  String get paymentHistory => _t('paymentHistory');
  String get dueDate => _t('dueDate');
  String get submitted => _t('submitted');
  String get pending => _t('pending');
  String get graded => _t('graded');
  String get score => _t('score');
  String get attempts => _t('attempts');
  String get quizHistory => _t('quizHistory');
  String get earnedCertificates => _t('earnedCertificates');
  String get download => _t('download');
  String get view => _t('view');
  String get noCourses => _t('noCourses');
  String get noCoursesFound => _t('noCoursesFound');
  String get noOngoingCourses => _t('noOngoingCourses');
  String get noCompletedCourses => _t('noCompletedCourses');
  String get noPayments => _t('noPayments');
  String get noAssignments => _t('noAssignments');
  String get noQuizAttempts => _t('noQuizAttempts');
  String get noCertificates => _t('noCertificates');
  String get ongoing => _t('ongoing');
  String get myTicketBookings => _t('myTicketBookings');
  String get ticketBookings => _t('ticketBookings');
  String get totalTickets => _t('totalTickets');
  String get confirmedTickets => _t('confirmedTickets');
  String get noTicketBookings => _t('noTicketBookings');
  String get quantity => _t('quantity');
  String get seats => _t('seats');
  String get cancelled => _t('cancelled');
  String get learningActivity => _t('learningActivity');
  String get learningHours => _t('learningHours');
  String get totalHours => _t('totalHours');
  String get all => _t('all');
  String get assignmentDetails => _t('assignmentDetails');
  String get submittedDate => _t('submittedDate');
  String get assignmentDescription => _t('assignmentDescription');
  String get requirements => _t('requirements');
  String get submitAssignment => _t('submitAssignment');
  String get attachFiles => _t('attachFiles');
  String get addFile => _t('addFile');
  String get comments => _t('comments');
  String get addComments => _t('addComments');
  String get submit => _t('submit');
  String get assignmentSubmittedSuccessfully =>
      _t('assignmentSubmittedSuccessfully');
  String get pleaseAttachAtLeastOneFile => _t('pleaseAttachAtLeastOneFile');
  String get assignmentSubmittedSuccessMessage =>
      _t('assignmentSubmittedSuccessMessage');
  String get ok => _t('ok');
  String get invalidCouponCode => _t('invalidCouponCode');
  String get pleaseFillInAllFields => _t('pleaseFillInAllFields');
  String get passwordsDoNotMatch => _t('passwordsDoNotMatch');
  String get verificationCodeResent => _t('verificationCodeResent');
  String get quickAccess => _t('quickAccess');
  String get joinLiveClass => _t('joinLiveClass');
  String get passed => _t('passed');
  String get failed => _t('failed');
  String get recent => _t('recent');
  String get thisYear => _t('thisYear');
  String get certificate => _t('certificate');
  String get certificateOfCompletion => _t('certificateOfCompletion');
  String get thisCertificateAwarded => _t('thisCertificateAwarded');
  String get issuedDate => _t('issuedDate');
  String get certificateId => _t('certificateId');
  String get verifiedCertificate => _t('verifiedCertificate');
  String get certificateVerificationDescription =>
      _t('certificateVerificationDescription');
  String get copiedToClipboard => _t('copiedToClipboard');
  String get share => _t('share');
  String get downloading => _t('downloading');
  String get ticketDetails => _t('ticketDetails');
  String get date => _t('date');
  String get time => _t('time');
  String get venue => _t('venue');
  String get bookingInformation => _t('bookingInformation');
  String get totalPrice => _t('totalPrice');
  String get bookingId => _t('bookingId');
  String get downloadTicket => _t('downloadTicket');
  String get eTicket => _t('eTicket');
  String get scanQRCodeInstruction => _t('scanQRCodeInstruction');
  String get ticketDuration => _t('ticketDuration');
  String get passenger => _t('passenger');
  String get idNumber => _t('idNumber');
  String get passengerType => _t('passengerType');
  String get adult => _t('adult');
  String get general => _t('general');
  String get carriage => _t('carriage');
  String get noSeatAssigned => _t('noSeatAssigned');
  String get transactionDetails => _t('transactionDetails');
  String get course => _t('course');
  String get paymentMethod => _t('paymentMethod');
  String get startQuiz => _t('startQuiz');
  String get aboutEvent => _t('aboutEvent');
  String get bookTicket => _t('bookTicket');
  String get registerNow => _t('registerNow');
  String get eventDetails => _t('eventDetails');
  String get attendees => _t('attendees');
  String get category => _t('category');
  String get free => _t('free');
  String get shareEvent => _t('shareEvent');
  String get location => _t('location');
  String get aboutThisEvent => _t('aboutThisEvent');
  String get alreadyBooked => _t('alreadyBooked');
  // Rewards & Points
  String get rewardsAndPoints => _t('rewardsAndPoints');
  String get yourPoints => _t('yourPoints');
  String get pointsToNextLevel => _t('pointsToNextLevel');
  String get badges => _t('badges');
  String get leaderboard => _t('leaderboard');
  String get earnedBadges => _t('earnedBadges');
  String get topLearners => _t('topLearners');
  String get points => _t('points');
  // Affiliate
  String get affiliateProgram => _t('affiliateProgram');
  String get totalEarnings => _t('totalEarnings');
  String get referrals => _t('referrals');
  String get thisMonth => _t('thisMonth');
  String get yourAffiliateLink => _t('yourAffiliateLink');
  String get yourAffiliateCode => _t('yourAffiliateCode');
  String get linkCopiedToClipboard => _t('linkCopiedToClipboard');
  String get codeCopiedToClipboard => _t('codeCopiedToClipboard');
  String get howItWorks => _t('howItWorks');
  String get shareYourLink => _t('shareYourLink');
  String get shareYourLinkDescription => _t('shareYourLinkDescription');
  String get theyEnroll => _t('theyEnroll');
  String get theyEnrollDescription => _t('theyEnrollDescription');
  String get youEarn => _t('youEarn');
  String get youEarnDescription => _t('youEarnDescription');
  String get commissionRates => _t('commissionRates');
  String get bronze => _t('bronze');
  String get silver => _t('silver');
  String get gold => _t('gold');
  String get shareAffiliateLink => _t('shareAffiliateLink');
  // Offline Courses
  String get offlineCourses => _t('offlineCourses');
  String get noOfflineCourses => _t('noOfflineCourses');
  String get noOfflineCoursesDescription => _t('noOfflineCoursesDescription');
  // Live Courses
  String get liveCourses => _t('liveCourses');
  String get join => _t('join');
  String get joinWhenLive => _t('joinWhenLive');
  String get live => _t('live');
  String get upcoming => _t('upcoming');
  String get ended => _t('ended');
  String get today => _t('today');
  String get tomorrow => _t('tomorrow');
  String get noLiveCourses => _t('noLiveCourses');
  String get noLiveCoursesDescription => _t('noLiveCoursesDescription');
  // Live Video
  String get typeAComment => _t('typeAComment');
  String get noCommentsYet => _t('noCommentsYet');
  String get joinLiveNow => _t('joinLiveNow');
  String get classEnded => _t('classEnded');
  String get participants => _t('participants');

  // AI Course Generator
  String get aiCourseGenerator => _t('aiCourseGenerator');
  String get poweredByAi => _t('poweredByAi');
  String get courseTitle => _t('courseTitle');
  String get numberOfModules => _t('numberOfModules');
  String get lessonsPerModule => _t('lessonsPerModule');
  String get numberOfQuizzes => _t('numberOfQuizzes');
  String get numberOfAssignments => _t('numberOfAssignments');
  String get generateCourse => _t('generateCourse');
  String get generating => _t('generating');
  String get courseOutline => _t('courseOutline');
  String get aiGenerated => _t('aiGenerated');
  String get courseModules => _t('courseModules');
  String get regenerate => _t('regenerate');
  String get startWriting => _t('startWriting');
  String get modules => _t('modules');
  String get quizzes => _t('quizzes');
  String get assignments => _t('assignments');

  // AI Lesson Writer
  String get aiLessonWriter => _t('aiLessonWriter');
  String get courseStructure => _t('courseStructure');
  String get aiAssistant => _t('aiAssistant');
  String get saveDraft => _t('saveDraft');
  String get saveLesson => _t('saveLesson');
  String get enterLessonTitle => _t('enterLessonTitle');
  String get startWritingLessonContent => _t('startWritingLessonContent');

  // Lesson Saved Success
  String get lessonSaved => _t('lessonSaved');
  String get lessonSavedMessage => _t('lessonSavedMessage');
  String get goToHomepage => _t('goToHomepage');

  // AI Video Notes Extractor
  String get aiVideoNotesExtractor => _t('aiVideoNotesExtractor');
  String get videoNotes => _t('videoNotes');
  String get uploadVideo => _t('uploadVideo');
  String get tapToSelectVideo => _t('tapToSelectVideo');
  String get supportedFormats => _t('supportedFormats');
  String get videoSelected => _t('videoSelected');
  String get extractNotes => _t('extractNotes');
  String get processing => _t('processing');
  String get videoNotesInfo => _t('videoNotesInfo');
  String get keyPoints => _t('keyPoints');
  String get videoSummary => _t('videoSummary');
  String get videoQuiz => _t('videoQuiz');

  // AI Voice Tutor
  String get aiVoiceTutor => _t('aiVoiceTutor');
  String get voiceTutorSubtitle => _t('voiceTutorSubtitle');
  String get voiceTutorDescription => _t('voiceTutorDescription');
  String get doubts => _t('doubts');
  String get summaries => _t('summaries');
  String get typeYourQuestion => _t('typeYourQuestion');
  String get listening => _t('listening');
  String get voiceTranscripts => _t('voiceTranscripts');
  String get transcriptsDescription => _t('transcriptsDescription');

  // Habit Tracker
  String get habitTracker => _t('habitTracker');
  String get createHabit => _t('createHabit');
  String get habitCreationInfo => _t('habitCreationInfo');
  String get habitName => _t('habitName');
  String get habitNameHint => _t('habitNameHint');
  String get frequency => _t('frequency');
  String get bestTime => _t('bestTime');
  String get morning => _t('morning');
  String get afternoon => _t('afternoon');
  String get evening => _t('evening');
  String get daysPerWeek => _t('daysPerWeek');
  String get days => _t('days');
  String get enableReminder => _t('enableReminder');
  String get reminderDescription => _t('reminderDescription');
  String get progress => _t('progress');
  String get streaks => _t('streaks');
  String get weeklyReview => _t('weeklyReview');
  String get streakDays => _t('streakDays');
  String get completionRate => _t('completionRate');
  String get activeHabits => _t('activeHabits');
  String get weeklyProgress => _t('weeklyProgress');
  String get daysThisWeek => _t('daysThisWeek');
  String get totalStreak => _t('totalStreak');
  String get longestStreak => _t('longestStreak');
  String get activeStreaks => _t('activeStreaks');
  String get yourStreaks => _t('yourStreaks');
  String get currentStreak => _t('currentStreak');
  String get thisWeek => _t('thisWeek');
  String get completedDays => _t('completedDays');
  String get missedDays => _t('missedDays');
  String get habitsThisWeek => _t('habitsThisWeek');

  // Study Timer
  String get studyTimer => _t('studyTimer');
  String get focusProgress => _t('focusProgress');
  String get taskBreakdown => _t('taskBreakdown');
  String get focus => _t('focus');
  String get shortBreak => _t('shortBreak');
  String get longBreak => _t('longBreak');
  String get minutes => _t('minutes');
  String get start => _t('start');
  String get pause => _t('pause');
  String get resume => _t('resume');
  String get reset => _t('reset');
  String get sessionsToday => _t('sessionsToday');
  String get totalFocusTime => _t('totalFocusTime');
  String get dailyAverage => _t('dailyAverage');
  String get dayStreak => _t('dayStreak');
  String get focusHours => _t('focusHours');
  String get dailyDetails => _t('dailyDetails');
  String get hours => _t('hours');
  String get focusTime => _t('focusTime');
  String get completedTasks => _t('completedTasks');
  String get remaining => _t('remaining');
  String get allTasks => _t('allTasks');
  String get custom => _t('custom');
  String get setCustomTime => _t('setCustomTime');
  String get customTimeDescription => _t('customTimeDescription');
  String get cancel => _t('cancel');
  String get set => _t('set');

  // Community Rooms
  String get groupChatRooms => _t('groupChatRooms');
  String get searchRooms => _t('searchRooms');
  String get activeRooms => _t('activeRooms');
  String get members => _t('members');
  String get topicCommunity => _t('topicCommunity');
  String get popular => _t('popular');
  String get trending => _t('trending');
  String get posts => _t('posts');
  String get qaRoom => _t('qaRoom');
  String get unanswered => _t('unanswered');
  String get myQuestions => _t('myQuestions');
  String get answered => _t('answered');
  String get joinCommunityDiscussion => _t('joinCommunityDiscussion');
  String get exploreTopicsAndDiscussions => _t('exploreTopicsAndDiscussions');
  String get askAndAnswerQuestions => _t('askAndAnswerQuestions');
  String get roomOptions => _t('roomOptions');
  String get viewRoomInfo => _t('viewRoomInfo');
  String get viewMembers => _t('viewMembers');
  String get leaveRoom => _t('leaveRoom');
  String get question => _t('question');
  String get questionOptions => _t('questionOptions');
  String get shareQuestion => _t('shareQuestion');
  String get saveQuestion => _t('saveQuestion');
  String get reportQuestion => _t('reportQuestion');
  String get answers => _t('answers');
  String get writeAnswer => _t('writeAnswer');
  String get postAnswer => _t('postAnswer');
  String get accept => _t('accept');
  String get accepted => _t('accepted');
  String get writeComment => _t('writeComment');
  String get postComment => _t('postComment');

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales.any(
      (l) => l.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) =>
      false;
}

extension AppLocalizationsBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

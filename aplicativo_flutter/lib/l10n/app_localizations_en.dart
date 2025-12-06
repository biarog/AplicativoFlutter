// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fitness Routines';

  @override
  String get yourRoutines => 'Your Routines';

  @override
  String get options => 'Options';

  @override
  String get appSettings => 'App Settings';

  @override
  String get theme => 'Theme';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get themeColor => 'Theme color';

  @override
  String get language => 'Language';

  @override
  String get sortRoutines => 'Sort Routines';

  @override
  String get sortNotImplemented => 'Sort not implemented';

  @override
  String get deleteAllRoutines => 'Delete all routines';

  @override
  String get removeAllRoutinesDesc => 'Remove all saved routines from device and cloud';

  @override
  String get notSignedIn => 'Not signed in';

  @override
  String get deleteAllRoutinesConfirm => 'Are you sure you want to delete all saved routines? This cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get allRoutinesDeleted => 'All routines deleted';

  @override
  String failedToDeleteRoutines(String error) {
    return 'Failed to delete routines: $error';
  }

  @override
  String get filter => 'Filter';

  @override
  String get filterNotImplemented => 'Filter not implemented';

  @override
  String get noRoutinesYet => 'No routines yet. Tap Create to add your first routine.';

  @override
  String exercisesCount(int count) {
    return '$count exercises';
  }

  @override
  String duration(int seconds) {
    return '~${seconds}s';
  }

  @override
  String get play => 'Play';

  @override
  String get deleteRoutine => 'Delete routine';

  @override
  String deleteRoutineConfirm(String name) {
    return 'Delete \"$name\"? This will remove it from your device and cloud.';
  }

  @override
  String get routineDeleted => 'Routine deleted';

  @override
  String failedToDeleteRoutine(String error) {
    return 'Failed to delete routine: $error';
  }

  @override
  String get createAccount => 'Create Account';

  @override
  String get signedInAs => 'Signed in as';

  @override
  String signedIn(String user) {
    return 'Signed in: $user';
  }

  @override
  String get login => 'Login';

  @override
  String get accountSettings => 'Account settings';

  @override
  String get logOut => 'Log Out';

  @override
  String get signedOut => 'Signed out';

  @override
  String signOutFailed(String error) {
    return 'Sign out failed: $error';
  }

  @override
  String get routines => 'Routines';

  @override
  String get calendar => 'Calendar';

  @override
  String get create => 'Create';

  @override
  String routineCompleted(String name) {
    return 'Routine \"$name\" completed and marked on calendar.';
  }

  @override
  String exerciseProgress(int current, int total) {
    return 'Exercise $current of $total';
  }

  @override
  String get setsLeft => 'Sets left';

  @override
  String secondsShort(int seconds) {
    return '${seconds}s';
  }

  @override
  String reps(int count) {
    return '$count reps';
  }

  @override
  String get completeSet => 'Complete set';

  @override
  String routineCompletedMessage(Object name) {
    return 'Routine \"$name\" completed and marked on calendar.';
  }

  @override
  String get noExercisesInRoutine => 'No exercises in this routine';

  @override
  String passwordResetSent(String email) {
    return 'Password reset email sent to $email';
  }

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get nameUpdated => 'Name updated';

  @override
  String get changePassword => 'Change password';

  @override
  String get changePasswordNotImplemented => 'Password change dialog not implemented yet.';

  @override
  String get ok => 'OK';

  @override
  String get displayName => 'Display name';

  @override
  String get pleaseEnterDisplayName => 'Please enter a display name';

  @override
  String get save => 'Save';

  @override
  String get exerciseNameRequired => 'Exercise name is required';

  @override
  String get validDurationRequired => 'Please enter a valid duration in seconds';

  @override
  String get validSetsRepsRequired => 'Please enter valid sets and reps';

  @override
  String get validWeightRequired => 'Please enter a valid weight';

  @override
  String get routineNameRequired => 'Routine name is required';

  @override
  String get atLeastOneExercise => 'Please add at least one exercise to the routine';

  @override
  String get routineSaved => 'Routine saved to your account';

  @override
  String get routineSavedLocally => 'Routine saved locally';

  @override
  String failedToSaveRoutine(String error) {
    return 'Failed to save routine: $error';
  }

  @override
  String get timed => 'Timed';

  @override
  String get counting => 'Counting';

  @override
  String get useWeight => 'Use weight';

  @override
  String get addExercise => 'Add Exercise';

  @override
  String get clear => 'Clear';

  @override
  String get createRoutine => 'Create Routine';

  @override
  String get newExercise => 'New exercise';

  @override
  String get exercises => 'Exercises';

  @override
  String get noExercisesAdded => 'No exercises added yet';

  @override
  String get agenda => 'Agenda';

  @override
  String get todaysWorkout => 'Today\'s workout';

  @override
  String get emailHint => 'you@example.com';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get pleaseEnterValidEmailForReset => 'Please enter a valid email address.';

  @override
  String get userNotFound => 'No user found with this email.';

  @override
  String get wrongPassword => 'Incorrect password.';

  @override
  String get emailAlreadyInUse => 'An account already exists with this email.';

  @override
  String get weakPassword => 'Password is too weak. Use at least 6 characters.';

  @override
  String get invalidEmail => 'Invalid email address.';

  @override
  String get authenticationFailed => 'Authentication failed.';

  @override
  String get googleSignInFailed => 'Google sign-in failed.';

  @override
  String get googleSignInError => 'Google sign-in error. Please try again.';

  @override
  String get validationError => 'Validation error. Please check your input.';

  @override
  String get pleaseFixErrors => 'Please fix the errors above.';

  @override
  String get exerciseName => 'Exercise name';

  @override
  String get durationSeconds => 'Duration (seconds)';

  @override
  String get sets => 'Sets';

  @override
  String get repsPerSet => 'Reps per set';

  @override
  String get weight => 'Weight';

  @override
  String get routineName => 'Routine name';

  @override
  String get exerciseType => 'Exercise type';

  @override
  String get youtubeLinkOptional => 'YouTube link (optional)';

  @override
  String get startTimeOptional => 'Start time (seconds, optional)';

  @override
  String get repsLabel => 'Reps';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get invalidYoutubeUrl => 'Invalid YouTube URL';

  @override
  String get noWorkoutThisDay => 'No workout performed on this day';

  @override
  String get exercisesCount2 => 'exercises';

  @override
  String get min => 'min';

  @override
  String get setupAgenda => 'Setup Agenda';

  @override
  String get organizeWeekWorkouts => 'Organize your week workouts';
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Routines de Fitness';

  @override
  String get yourRoutines => 'Vos Routines';

  @override
  String get options => 'Options';

  @override
  String get appSettings => 'Paramètres de l\'App';

  @override
  String get theme => 'Thème';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get themeColor => 'Couleur du thème';

  @override
  String get language => 'Langue';

  @override
  String get deleteAllRoutines => 'Supprimer toutes les routines';

  @override
  String get removeAllRoutinesDesc => 'Supprimer toutes les routines enregistrées de l\'appareil et du cloud';

  @override
  String get deleteAllRoutinesConfirm => 'Êtes-vous sûr de vouloir supprimer toutes les routines enregistrées? Cela ne peut pas être annulé.';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get allRoutinesDeleted => 'Toutes les routines supprimées';

  @override
  String failedToDeleteRoutines(String error) {
    return 'Échec de la suppression des routines: $error';
  }

  @override
  String get noRoutinesYet => 'Pas encore de routines. Appuyez sur Créer pour ajouter votre première routine.';

  @override
  String get play => 'Lire';

  @override
  String get deleteRoutine => 'Supprimer la routine';

  @override
  String deleteRoutineConfirm(String name) {
    return 'Supprimer \"$name\"? Cela la supprimera de votre appareil et du cloud.';
  }

  @override
  String get routineDeleted => 'Routine supprimée';

  @override
  String failedToDeleteRoutine(String error) {
    return 'Échec de la suppression de la routine: $error';
  }

  @override
  String get createAccount => 'Créer un Compte';

  @override
  String get signedInAs => 'Connecté en tant que';

  @override
  String signedIn(String user) {
    return 'Connecté: $user';
  }

  @override
  String get login => 'Se Connecter';

  @override
  String get accountSettings => 'Paramètres du compte';

  @override
  String get logOut => 'Se Déconnecter';

  @override
  String get signedOut => 'Déconnecté';

  @override
  String signOutFailed(String error) {
    return 'Échec de la déconnexion: $error';
  }

  @override
  String get routines => 'Routines';

  @override
  String get calendar => 'Calendrier';

  @override
  String get create => 'Créer';

  @override
  String exerciseProgress(int current, int total) {
    return 'Exercice $current sur $total';
  }

  @override
  String get setsLeft => 'Séries restantes';

  @override
  String secondsShort(int seconds) {
    return '${seconds}s';
  }

  @override
  String reps(int count) {
    return '$count répétitions';
  }

  @override
  String get completeSet => 'Terminer la série';

  @override
  String routineCompletedMessage(Object name) {
    return 'Routine \"$name\" terminée et ajoutée au calendrier.';
  }

  @override
  String get noExercisesInRoutine => 'Aucun exercice dans cette routine';

  @override
  String passwordResetSent(String email) {
    return 'E-mail de réinitialisation de mot de passe envoyé à $email';
  }

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Mot de passe';

  @override
  String get forgotPassword => 'Mot de passe oublié?';

  @override
  String get nameUpdated => 'Nom mis à jour';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get changePasswordNotImplemented => 'Dialogue de changement de mot de passe pas encore implémenté.';

  @override
  String get displayName => 'Nom d\'affichage';

  @override
  String get pleaseEnterDisplayName => 'Veuillez entrer un nom d\'affichage';

  @override
  String get save => 'Enregistrer';

  @override
  String get exerciseNameRequired => 'Le nom de l\'exercice est requis';

  @override
  String get validDurationRequired => 'Veuillez entrer une durée valide en secondes';

  @override
  String get validSetsRepsRequired => 'Veuillez entrer des séries et répétitions valides';

  @override
  String get validWeightRequired => 'Veuillez entrer un poids valide';

  @override
  String get routineNameRequired => 'Le nom de la routine est requis';

  @override
  String get atLeastOneExercise => 'Veuillez ajouter au moins un exercice à la routine';

  @override
  String get routineSaved => 'Routine enregistrée dans votre compte';

  @override
  String get routineSavedLocally => 'Routine enregistrée localement';

  @override
  String failedToSaveRoutine(String error) {
    return 'Échec de l\'enregistrement de la routine : $error';
  }

  @override
  String get timed => 'Chronométré';

  @override
  String get counting => 'Comptage';

  @override
  String get useWeight => 'Utiliser un poids';

  @override
  String get addExercise => 'Ajouter un Exercice';

  @override
  String get clear => 'Effacer';

  @override
  String get createRoutine => 'Créer une Routine';

  @override
  String get newExercise => 'Nouvel exercice';

  @override
  String get exercises => 'Exercices';

  @override
  String get noExercisesAdded => 'Aucun exercice ajouté pour le moment';

  @override
  String get agenda => 'Agenda';

  @override
  String get todaysWorkout => 'Entraînement d\'Aujourd\'hui';

  @override
  String get name => 'Nom';

  @override
  String get nameHint => 'Nom complet (affiché publiquement)';

  @override
  String get confirmPassword => 'Confirmer le Mot de Passe';

  @override
  String get pleaseConfirmPassword => 'Veuillez confirmer votre mot de passe';

  @override
  String get passwordsDoNotMatch => 'Les mots de passe ne correspondent pas';

  @override
  String get appCredits => 'Crédits de l\'App';

  @override
  String get emailHint => 'vous@exemple.com';

  @override
  String get pleaseEnterEmail => 'Veuillez entrer votre e-mail';

  @override
  String get pleaseEnterValidEmail => 'Veuillez entrer un e-mail valide';

  @override
  String get pleaseEnterPassword => 'Veuillez entrer votre mot de passe';

  @override
  String get passwordMinLength => 'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get pleaseEnterValidEmailForReset => 'Veuillez entrer une adresse e-mail valide.';

  @override
  String get userNotFound => 'Aucun utilisateur trouvé avec cet e-mail.';

  @override
  String get wrongPassword => 'Mot de passe incorrect.';

  @override
  String get emailAlreadyInUse => 'Un compte existe déjà avec cet e-mail.';

  @override
  String get weakPassword => 'Mot de passe trop faible. Utilisez au moins 6 caractères.';

  @override
  String get invalidEmail => 'Adresse e-mail invalide.';

  @override
  String get authenticationFailed => 'Échec de l\'authentification.';

  @override
  String get googleSignInFailed => 'Échec de la connexion Google.';

  @override
  String get googleSignInError => 'Erreur de connexion Google. Veuillez réessayer.';

  @override
  String get validationError => 'Erreur de validation. Veuillez vérifier votre saisie.';

  @override
  String get pleaseFixErrors => 'Veuillez corriger les erreurs ci-dessus.';

  @override
  String get exerciseName => 'Nom de l\'exercice';

  @override
  String get durationSeconds => 'Durée (secondes)';

  @override
  String get sets => 'Séries';

  @override
  String get repsPerSet => 'Répétitions par série';

  @override
  String get weight => 'Poids';

  @override
  String get routineName => 'Nom de la routine';

  @override
  String get exerciseType => 'Type d\'exercice';

  @override
  String get youtubeLinkOptional => 'Lien YouTube (optionnel)';

  @override
  String get startTimeOptional => 'Temps de démarrage (secondes, optionnel)';

  @override
  String get repsLabel => 'Répétitions';

  @override
  String get weightKg => 'Poids (kg)';

  @override
  String get invalidYoutubeUrl => 'URL YouTube invalide';

  @override
  String get noWorkoutThisDay => 'Aucun entraînement effectué ce jour';

  @override
  String get errorLoadingRoutines => 'Erreur lors du chargement des routines: null';

  @override
  String get account => 'Compte';

  @override
  String get configureSchedule => 'Configurer l\'Agenda';

  @override
  String get selectRoutinesForEachDay => 'Sélectionnez les routines pour chaque jour de la semaine';

  @override
  String totalScheduledRoutines(int count) {
    return 'Total des routines programmées: $count';
  }

  @override
  String get loadingRoutines => 'Chargement des routines...';

  @override
  String get allRoutinesCompleted => 'Toutes les routines sont terminées!';

  @override
  String exercisesAndDuration(int exercises, int minutes) {
    return '$exercises exercices · $minutes min';
  }

  @override
  String get errorLoadingCompletedRoutines => 'Erreur lors du chargement des routines terminées';

  @override
  String get errorLoadingCalendar => 'Erreur lors du chargement du calendrier';

  @override
  String get routineTimer => 'Minuterie de Routine';

  @override
  String get routineTimerDesc => 'Affiche le temps restant pour l\'exercice actuel';

  @override
  String timeRemaining(String time) {
    return 'Temps restant : $time';
  }

  @override
  String get noRoutineSelected => 'Aucune routine sélectionnée';

  @override
  String get credits => 'Crédits';

  @override
  String get developedBy => 'Développé par';

  @override
  String get githubUrl => 'GitHub';

  @override
  String get copyToClipboard => 'URL GitHub copiée dans le presse-papiers!';

  @override
  String get thankYouMessage => 'Merci d\'utiliser notre application!';

  @override
  String get fitnessGoalsMessage => 'Nous espérons qu\'elle vous aidera à atteindre vos objectifs de fitness.';

  @override
  String get close => 'Fermer';
}

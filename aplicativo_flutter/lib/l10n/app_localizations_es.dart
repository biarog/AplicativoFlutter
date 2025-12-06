// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Rutinas de Fitness';

  @override
  String get yourRoutines => 'Tus Rutinas';

  @override
  String get options => 'Opciones';

  @override
  String get appSettings => 'Configuración de la App';

  @override
  String get theme => 'Tema';

  @override
  String get darkMode => 'Modo oscuro';

  @override
  String get themeColor => 'Color del tema';

  @override
  String get language => 'Idioma';

  @override
  String get sortRoutines => 'Ordenar Rutinas';

  @override
  String get sortNotImplemented => 'Ordenar no implementado';

  @override
  String get deleteAllRoutines => 'Eliminar todas las rutinas';

  @override
  String get removeAllRoutinesDesc => 'Eliminar todas las rutinas guardadas del dispositivo y la nube';

  @override
  String get notSignedIn => 'No has iniciado sesión';

  @override
  String get deleteAllRoutinesConfirm => '¿Estás seguro de que deseas eliminar todas las rutinas guardadas? Esto no se puede deshacer.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get allRoutinesDeleted => 'Todas las rutinas eliminadas';

  @override
  String failedToDeleteRoutines(String error) {
    return 'Error al eliminar rutinas: $error';
  }

  @override
  String get filter => 'Filtrar';

  @override
  String get filterNotImplemented => 'Filtro no implementado';

  @override
  String get noRoutinesYet => 'Aún no hay rutinas. Toca Crear para agregar tu primera rutina.';

  @override
  String exercisesCount(int count) {
    return '$count ejercicios';
  }

  @override
  String duration(int seconds) {
    return '~${seconds}s';
  }

  @override
  String get play => 'Reproducir';

  @override
  String get deleteRoutine => 'Eliminar rutina';

  @override
  String deleteRoutineConfirm(String name) {
    return '¿Eliminar \"$name\"? Esto la eliminará de tu dispositivo y la nube.';
  }

  @override
  String get routineDeleted => 'Rutina eliminada';

  @override
  String failedToDeleteRoutine(String error) {
    return 'Error al eliminar rutina: $error';
  }

  @override
  String get createAccount => 'Crear Cuenta';

  @override
  String get signedInAs => 'Conectado como';

  @override
  String signedIn(String user) {
    return 'Conectado: $user';
  }

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get accountSettings => 'Configuración de la cuenta';

  @override
  String get logOut => 'Cerrar Sesión';

  @override
  String get signedOut => 'Sesión cerrada';

  @override
  String signOutFailed(String error) {
    return 'Error al cerrar sesión: $error';
  }

  @override
  String get routines => 'Rutinas';

  @override
  String get calendar => 'Calendario';

  @override
  String get create => 'Crear';

  @override
  String routineCompleted(String name) {
    return 'Rutina \"$name\" completada y marcada en el calendario.';
  }

  @override
  String exerciseProgress(int current, int total) {
    return 'Ejercicio $current de $total';
  }

  @override
  String get setsLeft => 'Series restantes';

  @override
  String secondsShort(int seconds) {
    return '${seconds}s';
  }

  @override
  String reps(int count) {
    return '$count repeticiones';
  }

  @override
  String get completeSet => 'Completar serie';

  @override
  String routineCompletedMessage(Object name) {
    return 'Rutina \"$name\" completada y marcada en el calendario.';
  }

  @override
  String get noExercisesInRoutine => 'No hay ejercicios en esta rutina';

  @override
  String passwordResetSent(String email) {
    return 'Correo de restablecimiento de contraseña enviado a $email';
  }

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get nameUpdated => 'Nombre actualizado';

  @override
  String get changePassword => 'Cambiar contraseña';

  @override
  String get changePasswordNotImplemented => 'Diálogo de cambio de contraseña aún no implementado.';

  @override
  String get ok => 'OK';

  @override
  String get displayName => 'Nombre para mostrar';

  @override
  String get pleaseEnterDisplayName => 'Por favor, ingresa un nombre para mostrar';

  @override
  String get save => 'Guardar';

  @override
  String get exerciseNameRequired => 'El nombre del ejercicio es obligatorio';

  @override
  String get validDurationRequired => 'Por favor, ingresa una duración válida en segundos';

  @override
  String get validSetsRepsRequired => 'Por favor, ingresa series y repeticiones válidas';

  @override
  String get validWeightRequired => 'Por favor, ingresa un peso válido';

  @override
  String get routineNameRequired => 'El nombre de la rutina es obligatorio';

  @override
  String get atLeastOneExercise => 'Por favor, añade al menos un ejercicio a la rutina';

  @override
  String get routineSaved => 'Rutina guardada en tu cuenta';

  @override
  String get routineSavedLocally => 'Rutina guardada localmente';

  @override
  String failedToSaveRoutine(String error) {
    return 'Error al guardar rutina: $error';
  }

  @override
  String get timed => 'Cronometrado';

  @override
  String get counting => 'Conteo';

  @override
  String get useWeight => 'Usar peso';

  @override
  String get addExercise => 'Agregar Ejercicio';

  @override
  String get clear => 'Limpiar';

  @override
  String get createRoutine => 'Crear Rutina';

  @override
  String get newExercise => 'Nuevo ejercicio';

  @override
  String get exercises => 'Ejercicios';

  @override
  String get noExercisesAdded => 'Aún no se han agregado ejercicios';

  @override
  String get agenda => 'Agenda';

  @override
  String get todaysWorkout => 'Entrenamiento de Hoy';

  @override
  String get emailHint => 'tu@ejemplo.com';

  @override
  String get pleaseEnterEmail => 'Por favor, ingresa tu correo electrónico';

  @override
  String get pleaseEnterValidEmail => 'Por favor, ingresa un correo electrónico válido';

  @override
  String get pleaseEnterPassword => 'Por favor, ingresa tu contraseña';

  @override
  String get passwordMinLength => 'La contraseña debe tener al menos 6 caracteres';

  @override
  String get continueWithGoogle => 'Continuar con Google';

  @override
  String get pleaseEnterValidEmailForReset => 'Por favor, ingresa una dirección de correo electrónico válida.';

  @override
  String get userNotFound => 'No se encontró ningún usuario con este correo electrónico.';

  @override
  String get wrongPassword => 'Contraseña incorrecta.';

  @override
  String get emailAlreadyInUse => 'Ya existe una cuenta con este correo electrónico.';

  @override
  String get weakPassword => 'Contraseña demasiado débil. Usa al menos 6 caracteres.';

  @override
  String get invalidEmail => 'Dirección de correo electrónico inválida.';

  @override
  String get authenticationFailed => 'Error de autenticación.';

  @override
  String get googleSignInFailed => 'Error al iniciar sesión con Google.';

  @override
  String get googleSignInError => 'Error al iniciar sesión con Google. Por favor, inténtalo de nuevo.';

  @override
  String get validationError => 'Error de validación. Por favor, verifica tu entrada.';

  @override
  String get pleaseFixErrors => 'Por favor, corrige los errores anteriores.';

  @override
  String get exerciseName => 'Nombre del ejercicio';

  @override
  String get durationSeconds => 'Duración (segundos)';

  @override
  String get sets => 'Series';

  @override
  String get repsPerSet => 'Repeticiones por serie';

  @override
  String get weight => 'Peso';

  @override
  String get routineName => 'Nombre de la rutina';

  @override
  String get exerciseType => 'Tipo de ejercicio';

  @override
  String get youtubeLinkOptional => 'Enlace de YouTube (opcional)';

  @override
  String get startTimeOptional => 'Tiempo de inicio (segundos, opcional)';

  @override
  String get repsLabel => 'Repeticiones';

  @override
  String get weightKg => 'Peso (kg)';

  @override
  String get invalidYoutubeUrl => 'URL de YouTube inválida';

  @override
  String get noWorkoutThisDay => 'No se realizó entrenamiento este día';

  @override
  String get exercisesCount2 => 'ejercicios';

  @override
  String get min => 'min';

  @override
  String get setupAgenda => 'Configurar Agenda';

  @override
  String get organizeWeekWorkouts => 'Organiza tus entrenamientos de la semana';
}

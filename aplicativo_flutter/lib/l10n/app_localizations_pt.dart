// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Rotinas de Fitness';

  @override
  String get yourRoutines => 'Suas Rotinas';

  @override
  String get options => 'Opções';

  @override
  String get appSettings => 'Configurações do App';

  @override
  String get theme => 'Tema';

  @override
  String get darkMode => 'Modo escuro';

  @override
  String get themeColor => 'Cor do tema';

  @override
  String get language => 'Idioma';

  @override
  String get sortRoutines => 'Ordenar Rotinas';

  @override
  String get sortNotImplemented => 'Ordenação não implementada';

  @override
  String get deleteAllRoutines => 'Excluir todas as rotinas';

  @override
  String get removeAllRoutinesDesc => 'Remover todas as rotinas salvas do dispositivo e nuvem';

  @override
  String get notSignedIn => 'Não conectado';

  @override
  String get deleteAllRoutinesConfirm => 'Tem certeza de que deseja excluir todas as rotinas salvas? Isso não pode ser desfeito.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get allRoutinesDeleted => 'Todas as rotinas excluídas';

  @override
  String failedToDeleteRoutines(String error) {
    return 'Falha ao excluir rotinas: $error';
  }

  @override
  String get filter => 'Filtrar';

  @override
  String get filterNotImplemented => 'Filtro não implementado';

  @override
  String get noRoutinesYet => 'Nenhuma rotina ainda. Toque em Criar para adicionar sua primeira rotina.';

  @override
  String exercisesCount(int count) {
    return '$count exercícios';
  }

  @override
  String duration(int seconds) {
    return '~${seconds}s';
  }

  @override
  String get play => 'Reproduzir';

  @override
  String get deleteRoutine => 'Excluir rotina';

  @override
  String deleteRoutineConfirm(String name) {
    return 'Excluir \"$name\"? Isso irá removê-la do seu dispositivo e nuvem.';
  }

  @override
  String get routineDeleted => 'Rotina excluída';

  @override
  String failedToDeleteRoutine(String error) {
    return 'Falha ao excluir rotina: $error';
  }

  @override
  String get createAccount => 'Criar Conta';

  @override
  String get signedInAs => 'Conectado como';

  @override
  String signedIn(String user) {
    return 'Conectado: $user';
  }

  @override
  String get login => 'Entrar';

  @override
  String get accountSettings => 'Configurações da conta';

  @override
  String get logOut => 'Sair';

  @override
  String get signedOut => 'Desconectado';

  @override
  String signOutFailed(String error) {
    return 'Falha ao sair: $error';
  }

  @override
  String get routines => 'Rotinas';

  @override
  String get calendar => 'Calendário';

  @override
  String get create => 'Criar';

  @override
  String routineCompleted(String name) {
    return 'Rotina \"$name\" concluída e marcada no calendário.';
  }

  @override
  String exerciseProgress(int current, int total) {
    return 'Exercício $current de $total';
  }

  @override
  String get setsLeft => 'Séries restantes';

  @override
  String secondsShort(int seconds) {
    return '${seconds}s';
  }

  @override
  String reps(int count) {
    return '$count repetições';
  }

  @override
  String get completeSet => 'Completar série';

  @override
  String routineCompletedMessage(Object name) {
    return 'Rotina \"$name\" concluída e marcada no calendário.';
  }

  @override
  String get noExercisesInRoutine => 'Nenhum exercício nesta rotina';

  @override
  String passwordResetSent(String email) {
    return 'E-mail de redefinição de senha enviado para $email';
  }

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get forgotPassword => 'Esqueceu a senha?';

  @override
  String get nameUpdated => 'Nome atualizado';

  @override
  String get changePassword => 'Alterar senha';

  @override
  String get changePasswordNotImplemented => 'Diálogo de alteração de senha ainda não implementado.';

  @override
  String get ok => 'OK';

  @override
  String get displayName => 'Nome de exibição';

  @override
  String get pleaseEnterDisplayName => 'Por favor, insira um nome de exibição';

  @override
  String get save => 'Salvar';

  @override
  String get exerciseNameRequired => 'Nome do exercício é obrigatório';

  @override
  String get validDurationRequired => 'Por favor, insira uma duração válida em segundos';

  @override
  String get validSetsRepsRequired => 'Por favor, insira séries e repetições válidas';

  @override
  String get validWeightRequired => 'Por favor, insira um peso válido';

  @override
  String get routineNameRequired => 'Nome da rotina é obrigatório';

  @override
  String get atLeastOneExercise => 'Por favor, adicione pelo menos um exercício à rotina';

  @override
  String get routineSaved => 'Rotina salva na sua conta';

  @override
  String get routineSavedLocally => 'Rotina salva localmente';

  @override
  String failedToSaveRoutine(String error) {
    return 'Falha ao salvar rotina: $error';
  }

  @override
  String get timed => 'Cronometrado';

  @override
  String get counting => 'Contagem';

  @override
  String get useWeight => 'Usar peso';

  @override
  String get addExercise => 'Adicionar Exercício';

  @override
  String get clear => 'Limpar';

  @override
  String get createRoutine => 'Criar Rotina';

  @override
  String get newExercise => 'Novo exercício';

  @override
  String get exercises => 'Exercícios';

  @override
  String get noExercisesAdded => 'Nenhum exercício adicionado ainda';

  @override
  String get agenda => 'Agenda';

  @override
  String get todaysWorkout => 'Treino de Hoje';

  @override
  String get emailHint => 'voce@exemplo.com';

  @override
  String get pleaseEnterEmail => 'Por favor, insira seu e-mail';

  @override
  String get pleaseEnterValidEmail => 'Por favor, insira um e-mail válido';

  @override
  String get pleaseEnterPassword => 'Por favor, insira sua senha';

  @override
  String get passwordMinLength => 'A senha deve ter pelo menos 6 caracteres';

  @override
  String get continueWithGoogle => 'Continuar com Google';

  @override
  String get pleaseEnterValidEmailForReset => 'Por favor, insira um endereço de e-mail válido.';

  @override
  String get userNotFound => 'Nenhum usuário encontrado com este e-mail.';

  @override
  String get wrongPassword => 'Senha incorreta.';

  @override
  String get emailAlreadyInUse => 'Já existe uma conta com este e-mail.';

  @override
  String get weakPassword => 'Senha muito fraca. Use pelo menos 6 caracteres.';

  @override
  String get invalidEmail => 'Endereço de e-mail inválido.';

  @override
  String get authenticationFailed => 'Falha na autenticação.';

  @override
  String get googleSignInFailed => 'Falha no login com Google.';

  @override
  String get googleSignInError => 'Erro no login com Google. Por favor, tente novamente.';

  @override
  String get validationError => 'Erro de validação. Por favor, verifique sua entrada.';

  @override
  String get pleaseFixErrors => 'Por favor, corrija os erros acima.';

  @override
  String get exerciseName => 'Nome do exercício';

  @override
  String get durationSeconds => 'Duração (segundos)';

  @override
  String get sets => 'Séries';

  @override
  String get repsPerSet => 'Repetições por série';

  @override
  String get weight => 'Peso';

  @override
  String get routineName => 'Nome da rotina';

  @override
  String get exerciseType => 'Tipo de exercício';

  @override
  String get youtubeLinkOptional => 'Link do YouTube (opcional)';

  @override
  String get startTimeOptional => 'Tempo de início (segundos, opcional)';

  @override
  String get repsLabel => 'Repetições';

  @override
  String get weightKg => 'Peso (kg)';

  @override
  String get invalidYoutubeUrl => 'URL do YouTube inválida';

  @override
  String get noWorkoutThisDay => 'Nenhum treino realizado neste dia';

  @override
  String get exercisesCount2 => 'exercícios';

  @override
  String get min => 'min';

  @override
  String get setupAgenda => 'Configurar Agenda';

  @override
  String get organizeWeekWorkouts => 'Organize seus treinos da semana';
}

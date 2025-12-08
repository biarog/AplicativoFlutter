// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '健身计划';

  @override
  String get yourRoutines => '您的计划';

  @override
  String get options => '选项';

  @override
  String get appSettings => '应用设置';

  @override
  String get theme => '主题';

  @override
  String get darkMode => '深色模式';

  @override
  String get themeColor => '主题颜色';

  @override
  String get language => '语言';

  @override
  String get deleteAllRoutines => '删除所有计划';

  @override
  String get removeAllRoutinesDesc => '从设备和云端删除所有已保存的计划';

  @override
  String get deleteAllRoutinesConfirm => '您确定要删除所有已保存的计划吗？此操作无法撤消。';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get allRoutinesDeleted => '所有计划已删除';

  @override
  String failedToDeleteRoutines(String error) {
    return '删除计划失败：$error';
  }

  @override
  String get noRoutinesYet => '还没有计划。点击创建添加您的第一个计划。';

  @override
  String get play => '播放';

  @override
  String get deleteRoutine => '删除计划';

  @override
  String deleteRoutineConfirm(String name) {
    return '删除\"$name\"？这将从您的设备和云端删除它。';
  }

  @override
  String get routineDeleted => '计划已删除';

  @override
  String failedToDeleteRoutine(String error) {
    return '删除计划失败：$error';
  }

  @override
  String get createAccount => '创建账户';

  @override
  String get signedInAs => '已登录为';

  @override
  String signedIn(String user) {
    return '已登录：$user';
  }

  @override
  String get login => '登录';

  @override
  String get accountSettings => '账户设置';

  @override
  String get logOut => '退出';

  @override
  String get signedOut => '已退出';

  @override
  String signOutFailed(String error) {
    return '退出失败：$error';
  }

  @override
  String get routines => '计划';

  @override
  String get calendar => '日历';

  @override
  String get create => '创建';

  @override
  String exerciseProgress(int current, int total) {
    return '练习 $current / $total';
  }

  @override
  String get setsLeft => '剩余组数';

  @override
  String secondsShort(int seconds) {
    return '$seconds 秒';
  }

  @override
  String reps(int count) {
    return '$count 次';
  }

  @override
  String get completeSet => '完成组';

  @override
  String routineCompletedMessage(Object name) {
    return '已完成训练\"$name\"并已标记到日历。';
  }

  @override
  String get noExercisesInRoutine => '此计划中没有练习';

  @override
  String passwordResetSent(String email) {
    return '密码重置邮件已发送至 $email';
  }

  @override
  String get email => '电子邮件';

  @override
  String get password => '密码';

  @override
  String get forgotPassword => '忘记密码？';

  @override
  String get nameUpdated => '名称已更新';

  @override
  String get changePassword => '更改密码';

  @override
  String get changePasswordNotImplemented => '密码更改对话框尚未实现。';

  @override
  String get displayName => '显示名称';

  @override
  String get pleaseEnterDisplayName => '请输入显示名称';

  @override
  String get save => '保存';

  @override
  String get exerciseNameRequired => '练习名称为必填项';

  @override
  String get validDurationRequired => '请输入有效的秒数';

  @override
  String get validSetsRepsRequired => '请输入有效的组数和次数';

  @override
  String get validWeightRequired => '请输入有效的重量';

  @override
  String get routineNameRequired => '计划名称为必填项';

  @override
  String get atLeastOneExercise => '请至少添加一个练习到计划中';

  @override
  String get routineSaved => '计划已保存到您的账户';

  @override
  String get routineSavedLocally => '计划已本地保存';

  @override
  String failedToSaveRoutine(String error) {
    return '保存计划失败：$error';
  }

  @override
  String get timed => '计时';

  @override
  String get counting => '计数';

  @override
  String get useWeight => '使用重量';

  @override
  String get addExercise => '添加练习';

  @override
  String get clear => '清除';

  @override
  String get createRoutine => '创建计划';

  @override
  String get newExercise => '新练习';

  @override
  String get exercises => '练习';

  @override
  String get noExercisesAdded => '尚未添加练习';

  @override
  String get agenda => '议程';

  @override
  String get todaysWorkout => '今日训练';

  @override
  String get name => '姓名';

  @override
  String get nameHint => '全名（公开显示）';

  @override
  String get confirmPassword => '确认密码';

  @override
  String get pleaseConfirmPassword => '请确认您的密码';

  @override
  String get passwordsDoNotMatch => '密码不匹配';

  @override
  String get appCredits => '应用程序制作人员';

  @override
  String get emailHint => '你@例子.com';

  @override
  String get pleaseEnterEmail => '请输入您的电子邮件';

  @override
  String get pleaseEnterValidEmail => '请输入有效的电子邮件';

  @override
  String get pleaseEnterPassword => '请输入您的密码';

  @override
  String get passwordMinLength => '密码必须至少6个字符';

  @override
  String get continueWithGoogle => '使用Google继续';

  @override
  String get pleaseEnterValidEmailForReset => '请输入有效的电子邮件地址。';

  @override
  String get userNotFound => '未找到使用此电子邮件的用户。';

  @override
  String get wrongPassword => '密码错误。';

  @override
  String get emailAlreadyInUse => '此电子邮件已有账户存在。';

  @override
  String get weakPassword => '密码太弱。请使用至少6个字符。';

  @override
  String get invalidEmail => '无效的电子邮件地址。';

  @override
  String get authenticationFailed => '身份验证失败。';

  @override
  String get googleSignInFailed => 'Google登录失败。';

  @override
  String get googleSignInError => 'Google登录错误。请重试。';

  @override
  String get validationError => '验证错误。请检查您的输入。';

  @override
  String get pleaseFixErrors => '请修复上述错误。';

  @override
  String get exerciseName => '练习名称';

  @override
  String get durationSeconds => '持续时间（秒）';

  @override
  String get sets => '组数';

  @override
  String get repsPerSet => '每组次数';

  @override
  String get weight => '重量';

  @override
  String get routineName => '计划名称';

  @override
  String get exerciseType => '练习类型';

  @override
  String get youtubeLinkOptional => 'YouTube链接（可选）';

  @override
  String get startTimeOptional => '开始时间（秒，可选）';

  @override
  String get repsLabel => '次数';

  @override
  String get weightKg => '重量（公斤）';

  @override
  String get invalidYoutubeUrl => '无效的YouTube网址';

  @override
  String get noWorkoutThisDay => '此日期没有进行训练';

  @override
  String get errorLoadingRoutines => '加载例程时出错: null';

  @override
  String get account => '账户';

  @override
  String get configureSchedule => '配置日程';

  @override
  String get selectRoutinesForEachDay => '为每周的每一天选择例程';

  @override
  String totalScheduledRoutines(int count) {
    return '已安排的例程总数: $count';
  }

  @override
  String get loadingRoutines => '正在加载例程...';

  @override
  String get allRoutinesCompleted => '所有计划已完成！';

  @override
  String exercisesAndDuration(int exercises, int minutes) {
    return '$exercises 个练习 · $minutes 分钟';
  }

  @override
  String get errorLoadingCompletedRoutines => '加载已完成计划时出错';

  @override
  String get errorLoadingCalendar => '加载日历时出错';

  @override
  String get routineTimer => '训练计时器';

  @override
  String get routineTimerDesc => '显示当前练习的剩余时间';

  @override
  String timeRemaining(String time) {
    return '剩余时间：$time';
  }

  @override
  String get noRoutineSelected => '未选择训练计划';

  @override
  String get credits => '致谢';

  @override
  String get developedBy => '开发者';

  @override
  String get githubUrl => 'GitHub';

  @override
  String get copyToClipboard => 'GitHub链接已复制到剪贴板！';

  @override
  String get thankYouMessage => '感谢您使用我们的应用！';

  @override
  String get fitnessGoalsMessage => '我们希望它能帮助您实现您的健身目标。';

  @override
  String get close => '关闭';
}

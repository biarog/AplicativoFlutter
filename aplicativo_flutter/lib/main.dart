import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'login_firebase/firebase_options.dart';
import 'l10n/app_localizations.dart';

import 'models/auth_dto.dart';

import 'screens/routine_player_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/create_routine_screen.dart';

import 'widgets/login_dialog.dart';
import 'widgets/create_account_dialog.dart';
import 'widgets/account_settings_dialog.dart';
import 'widgets/credits_dialog.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/local_routines_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/routine_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize locale data for the `intl` package (used by CalendarWidget)
  await initializeDateFormatting('pt_BR');
  Intl.defaultLocale = 'pt_BR';
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsProvider);

    final lightScheme = ColorScheme.light(
      primary: settings.lightPrimary,
      secondary: settings.lightSecondary,
      tertiary: settings.lightTerciary,
      surface: Colors.grey[200]!,
      inverseSurface: Colors.grey[800]!,
      error: settings.lightError,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      onSurface: Colors.black,
      onInverseSurface: Colors.white,
      onError: Colors.white,
      brightness: Brightness.light
    );

    final darkScheme = ColorScheme.dark(
      primary: settings.darkPrimary,
      secondary: settings.darkSecondary,
      tertiary: settings.darkTerciary,
      surface: Colors.grey[900]!,
      inverseSurface: Colors.grey[200]!,
      error: settings.darkError,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onTertiary: Colors.black,
      onSurface: Colors.white,
      onInverseSurface: Colors.black,
      onError: Colors.white,
      brightness: Brightness.dark
    );

    final lightTheme = ThemeData(colorScheme: lightScheme, useMaterial3: true)
        .copyWith(textTheme: GoogleFonts.rubikTextTheme(ThemeData.light().textTheme));
    final darkTheme = ThemeData(colorScheme: darkScheme, useMaterial3: true)
        .copyWith(textTheme: GoogleFonts.rubikTextTheme(ThemeData.dark().textTheme));
    
    final locale = ref.watch(localeProvider);
    
    return MaterialApp(
      title: 'Fitness Routines',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: settings.isDark ? ThemeMode.dark : ThemeMode.light,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  Widget _buildRoutinesPage() {
    // Load routines from user provider (combines local + Firebase)
    final routinesAsync = ref.watch(userRoutinesProvider);
    
    return routinesAsync.when(
      data: (routines) => Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.yourRoutines, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 4),
              Container(
                height: 3,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (routines.isEmpty) ...[
            Text(AppLocalizations.of(context)!.noRoutinesYet),
          ] else ...[
            Expanded(
              child: ListView.separated(
                itemCount: routines.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final routine = routines[index];
                  return Card(
                    color: Theme.of(context).colorScheme.tertiary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.0),
                    ),
                    child: ListTile(
                      title: Text(
                        routine.name, 
                        style: TextStyle(color: Theme.of(context).colorScheme.onTertiary)
                      ),
                      subtitle: Text(
                        '${routine.exercises.length} exercises • ~${routine.totalDuration}s',
                        style: TextStyle(color: Theme.of(context).colorScheme.onTertiary),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              side: BorderSide(color: Theme.of(context).colorScheme.primary),
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                            ),
                            child: Text(AppLocalizations.of(context)!.play, style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => RoutinePlayerScreen(routine: routine),
                              ));
                            },
                          ),
                          const SizedBox(width: 8),
                          // Per-routine delete button
                          IconButton(
                            tooltip: AppLocalizations.of(context)!.deleteRoutine,
                            color: Theme.of(context).colorScheme.error,
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final l10n = AppLocalizations.of(context)!;
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(l10n.deleteRoutine),
                                  content: Text(l10n.deleteRoutineConfirm(routine.name)),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancel)),
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.delete)),
                                  ],
                                ),
                              );
                              if (confirm != true) return;

                              try {
                                // Remover do provider local (que também remove do storage)
                                await ref.read(localRoutinesProvider.notifier).removeRoutine(routine.id);
                                // Se logado, remover do Firebase também
                                final user = ref.read(authStateChangesProvider).maybeWhen(data: (u) => u, orElse: () => null);
                                if (user != null) {
                                  await ref.read(authRepositoryProvider).removeRoutineForUser(user.uid, routine.id);
                                }
                                if (!mounted) return;
                                messenger.showSnackBar(SnackBar(content: Text(l10n.routineDeleted)));
                              } catch (e) {
                                messenger.showSnackBar(SnackBar(content: Text(l10n.failedToDeleteRoutine(e.toString()))));
                              }
                            },
                            icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.primary,),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Text(AppLocalizations.of(context)!.errorLoadingRoutines),
      ),
    );
  }

  void _showOptionsModal() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        final localRef = ref;
        final presets = localRef.read(themeSettingsProvider.notifier).presets;
        final currentIsDark = localRef.read(themeSettingsProvider).isDark;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  leading: const Icon(Icons.info),
                  title: Text("App Credits"),
                  onTap: () {
                    Navigator.of(context).pop();
                    showDialog<void>(
                      context: context,
                      builder: (_) => const CreditsDialog(),
                    );
                  },
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AppLocalizations.of(context)!.theme, style: Theme.of(context).textTheme.titleMedium),
                  ),
                ),
                StatefulBuilder(builder: (context, setState) {
                  final isDark = localRef.read(themeSettingsProvider).isDark;
                  return SwitchListTile(
                    title: Text(AppLocalizations.of(context)!.darkMode),
                    value: isDark,
                    onChanged: (v) {
                      localRef.read(themeSettingsProvider.notifier).setDark(v);
                      setState(() {});
                    },
                  );
                }),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AppLocalizations.of(context)!.themeColor, style: Theme.of(context).textTheme.titleMedium),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Wrap(
                    spacing: 12,
                    children: presets.map((p) {
                      final c = currentIsDark ? p.darkPrimary : p.lightPrimary;
                      return GestureDetector(
                        onTap: () {
                          localRef.read(themeSettingsProvider.notifier).applyPresetById(p.id);
                          Navigator.of(context).pop();
                        },
                        child: CircleAvatar(
                          backgroundColor: c,
                          radius: 20,
                          child: localRef.read(themeSettingsProvider).primaryColor == c
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AppLocalizations.of(context)!.language, style: Theme.of(context).textTheme.titleMedium),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      const Locale('en'),
                      const Locale('pt'),
                      const Locale('es'),
                      const Locale('fr'),
                      const Locale('zh'),
                    ].map((l) {
                      final currentLocale = localRef.watch(localeProvider);
                      final isSelected = (currentLocale?.languageCode ?? '') == l.languageCode;
                      final localeNames = {
                        'en': 'English',
                        'pt': 'Português',
                        'es': 'Español',
                        'fr': 'Français',
                        'zh': '中文',
                      };
                      return FilterChip(
                        label: Text(localeNames[l.languageCode] ?? l.languageCode),
                        selected: isSelected,
                        onSelected: (_) {
                          localRef.read(localeProvider.notifier).setLocale(l);
                        },
                      );
                    }).toList(),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.delete_forever),
                  title: Text(AppLocalizations.of(context)!.deleteAllRoutines),
                  subtitle: Text(AppLocalizations.of(context)!.removeAllRoutinesDesc),
                  onTap: () async {
                    Navigator.of(context).pop();
                    final messenger = ScaffoldMessenger.of(context);
                    final auth = localRef.read(authStateChangesProvider);
                    final user = auth.maybeWhen(data: (u) => u, orElse: () => null);

                    final l10n = AppLocalizations.of(context)!;
                    final allDeletedMsg = l10n.allRoutinesDeleted;
                    String getFailedMsg(String err) => l10n.failedToDeleteRoutines(err);
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(l10n.deleteAllRoutines),
                        content: Text(l10n.deleteAllRoutinesConfirm),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(l10n.cancel)),
                          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(l10n.delete)),
                        ],
                      ),
                    );
                    if (confirm != true) return;

                    try {
                      // Clear local routines (always)
                      final routines = await localRef.read(localRoutinesProvider.future);
                      for (final routine in routines) {
                        await localRef.read(localRoutinesProvider.notifier).removeRoutine(routine.id);
                      }
                      
                      // If logged in, also clear from Firebase
                      if (user != null) {
                        await localRef.read(authRepositoryProvider).clearRoutinesForUser(user.uid);
                      }
                      
                      if (!mounted) return;
                      messenger.showSnackBar(SnackBar(content: Text(allDeletedMsg)));
                    } catch (e) {
                      messenger.showSnackBar(SnackBar(content: Text(getFailedMsg(e.toString()))));
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Note: `ref.listen` must be used inside the `build` method for
  // Consumer widgets. The listener is registered in `build()` below.

  // pages are built in build() so they can use current BuildContext

  @override
  Widget build(BuildContext context) {
    // Watch auth state to know whether a user is signed in.
    final authState = ref.watch(authStateChangesProvider);
    final isLoggedIn = authState.maybeWhen(data: (u) => u != null, orElse: () => false);
    // Build pages on each build so we can use context in children
    final pages = <Widget>[_buildRoutinesPage(), const CalendarScreen(), const CreateRoutineScreen()];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: AutoSizeText(
                'Fitness Routines',
                maxLines: 1,
                minFontSize: 10,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
        actions: [
                // Only show Create Account / Login when NOT signed in.
                if (!isLoggedIn) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 6.0, top: 8.0, bottom: 8.0),
                    child: FloatingActionButton.extended(
                      onPressed: () async {
                        // Capture the ScaffoldMessenger before the async gap so
                        // we don't use a BuildContext across an await.
                        final messenger = ScaffoldMessenger.of(context);
                        final l10n = AppLocalizations.of(context)!;
                        final auth = await showDialog<AuthDto?>(
                          context: context,
                          builder: (_) => CreateAccountDialog(),
                        );
                            if (!mounted) return;
                            if (auth != null) {
                              messenger.showSnackBar(SnackBar(
                                content: Text(l10n.signedIn(auth.email ?? auth.uid)),
                              ));
                            }
                      },
                      label: Text(AppLocalizations.of(context)!.createAccount),
                      heroTag: 'create_account_fab',
                      elevation: 0,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),

                  // Top-right login floating action button (placeholder)
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0, top: 8.0, bottom: 8.0),
                    child: FloatingActionButton.extended(
                      onPressed: () async {
                        // Capture messenger before awaiting the dialog.
                        final messenger = ScaffoldMessenger.of(context);
                        final l10n = AppLocalizations.of(context)!;
                          final auth = await showDialog<AuthDto?>(
                            context: context,
                            builder: (context) => const LoginDialog(),
                          );
                          if (!mounted) return;
                          if (auth != null) {
                            messenger.showSnackBar(SnackBar(
                              content: Text(l10n.signedIn(auth.email ?? auth.uid)),
                            ));
                          }
                      },
                      label: Text(AppLocalizations.of(context)!.login),
                      heroTag: 'login_fab',
                      elevation: 0,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ] else ...[
                  // When signed in, show an inline label and a Log Out button.
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Builder(builder: (context) {
                      final user = authState.maybeWhen(data: (u) => u, orElse: () => null);
                      final email = (user?.email ?? '').trim();
                      final name = (user?.displayName ?? '').trim();
                      final photo = user?.photoURL;

                      // Determine primary label to show: prefer displayName, then email, then 'Account'.
                      final displayLabel = name.isNotEmpty ? name : (email.isNotEmpty ? email : AppLocalizations.of(context)!.account);
                      final initialSource = (name.isNotEmpty ? name : (email.isNotEmpty ? email : 'U'));
                      final initial = initialSource.isNotEmpty ? initialSource[0].toUpperCase() : 'U';

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (photo != null && photo.isNotEmpty)
                            CircleAvatar(radius: 16, backgroundImage: NetworkImage(photo))
                          else
                            CircleAvatar(radius: 16, child: Text(initial)),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(AppLocalizations.of(context)!.signedInAs, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 140),
                                child: Text(
                                  displayLabel,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            tooltip: AppLocalizations.of(context)!.accountSettings,
                            onPressed: () async {
                              // Open the account settings dialog
                              await showDialog<void>(
                                context: context,
                                builder: (_) => const AccountSettingsDialog(),
                              );
                            },
                            icon: const Icon(Icons.more_vert, size: 20),
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          TextButton(
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final l10n = AppLocalizations.of(context)!;
                              try {
                                await ref.read(authRepositoryProvider).signOut();
                                messenger.showSnackBar(SnackBar(content: Text(l10n.signedOut)));
                              } catch (e) {
                                messenger.showSnackBar(SnackBar(content: Text(l10n.signOutFailed(e.toString()))));
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                            ),
                            child: Text(AppLocalizations.of(context)!.logOut),
                          ),
                          const SizedBox(width: 6),
                        ],
                      );
                    }),
                  ),
                ],
          
          // Options button - always visible
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: AppLocalizations.of(context)!.options,
            onPressed: _showOptionsModal,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) {
            setState(() => _selectedIndex = i);
          },
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
          selectedIconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.primary,
            size: 30,
          ),
          unselectedIconTheme: const IconThemeData(size: 22),
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(children: [const Icon(Icons.fitness_center), const SizedBox(height: 4), Text(AppLocalizations.of(context)!.routines)],)),
              label: ''),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(children: [const Icon(Icons.calendar_today), const SizedBox(height: 4), Text(AppLocalizations.of(context)!.calendar)],)),
              label: ''),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Column(children: [const Icon(Icons.add_circle_outline), const SizedBox(height: 4), Text(AppLocalizations.of(context)!.create)],)),
              label: ''),
          ],
      ),
    );
  }
}

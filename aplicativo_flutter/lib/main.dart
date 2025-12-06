import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'login_firebase/firebase_options.dart';

import 'models/routine.dart';
import 'models/auth_dto.dart';

import 'screens/routine_player_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/create_routine_screen.dart';

import 'widgets/login_dialog.dart';
import 'widgets/create_account_dialog.dart';
import 'widgets/account_settings_dialog.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/routine_provider.dart';
import 'providers/local_routines_provider.dart';

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
      surface: Colors.white,
      error: settings.lightError,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light
    );

    final darkScheme = ColorScheme.dark(
      primary: settings.darkPrimary,
      secondary: settings.darkSecondary,
      surface: Colors.grey[900]!,
      error: settings.darkError,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.white,
      onError: Colors.white,
      brightness: Brightness.dark
    );

    final lightTheme = ThemeData(colorScheme: lightScheme, useMaterial3: true)
        .copyWith(textTheme: GoogleFonts.rubikTextTheme(ThemeData.light().textTheme));
    final darkTheme = ThemeData(colorScheme: darkScheme, useMaterial3: true)
        .copyWith(textTheme: GoogleFonts.rubikTextTheme(ThemeData.dark().textTheme));
    
    return MaterialApp(
      title: 'Fitness Routines',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: settings.isDark ? ThemeMode.dark : ThemeMode.light,
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
    final routinesAsync = ref.watch(userRoutinesProvider);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Your Routines', style: Theme.of(context).textTheme.headlineMedium),
              ElevatedButton.icon(
                onPressed: () async {
                  await showModalBottomSheet<void>(
                    context: context,
                    builder: (context) {
                      // capture the Riverpod ref from the stateful widget scope
                      final localRef = ref;
                      // derive available colors from presets defined in theme_provider
                      final presets = localRef.read(themeSettingsProvider.notifier).presets;
                      final currentIsDark = localRef.read(themeSettingsProvider).isDark;

                      return SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.settings),
                                title: const Text('App Settings'),
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  await showDialog<void>(
                                    context: context,
                                    builder: (_) => const AccountSettingsDialog(),
                                  );
                                },
                              ),
                              const Divider(),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text('Theme', style: Theme.of(context).textTheme.titleMedium),
                                ),
                              ),
                              StatefulBuilder(builder: (context, setState) {
                                final isDark = localRef.read(themeSettingsProvider).isDark;
                                return SwitchListTile(
                                  title: const Text('Dark mode'),
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
                                  child: Text('Theme color', style: Theme.of(context).textTheme.titleMedium),
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
                              ListTile(
                                leading: const Icon(Icons.sort),
                                title: const Text('Sort Routines'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sort not implemented')));
                                },
                              ),
                              // Delete all routines option inside the options modal
                              ListTile(
                                leading: const Icon(Icons.delete_forever),
                                title: const Text('Delete all routines'),
                                subtitle: const Text('Remove all saved routines from device and cloud'),
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  final messenger = ScaffoldMessenger.of(context);
                                  final auth = localRef.read(authStateChangesProvider);
                                  final user = auth.maybeWhen(data: (u) => u, orElse: () => null);
                                  if (user == null) {
                                    messenger.showSnackBar(const SnackBar(content: Text('Not signed in')));
                                    return;
                                  }

                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete all routines'),
                                      content: const Text('Are you sure you want to delete all saved routines? This cannot be undone.'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                        TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
                                      ],
                                    ),
                                  );
                                  if (confirm != true) return;

                                  try {
                                    // Deletar do Firebase se logado
                                    await localRef.read(authRepositoryProvider).clearRoutinesForUser(user.uid);
                                    // Deletar do storage local
                                    final routines = await localRef.read(localRoutinesProvider.future);
                                    for (final routine in routines) {
                                      await localRef.read(localRoutinesProvider.notifier).removeRoutine(routine.id);
                                    }
                                    if (!mounted) return;
                                    messenger.showSnackBar(const SnackBar(content: Text('All routines deleted')));
                                  } catch (e) {
                                    messenger.showSnackBar(SnackBar(content: Text('Failed to delete routines: $e')));
                                  }
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.filter_list),
                                title: const Text('Filter'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Filter not implemented')));
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(Icons.more_vert),
                label: const Text('Options'),
                style: ElevatedButton.styleFrom(elevation: 0),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: routinesAsync.when(
              data: (routines) {
                if (routines.isEmpty) {
                  return const Center(
                    child: Text('No routines yet. Tap Create to add your first routine.'),
                  );
                }
                return ListView.separated(
                  itemCount: routines.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final routine = routines[index];
                    return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      side: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.0),
                    ),
                    child: ListTile(
                      title: Text(routine.name),
                      subtitle: Text('${routine.exercises.length} exercises • ~${routine.totalDuration}s'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              side: BorderSide(color: Theme.of(context).colorScheme.primary),
                            ),
                            child: const Text('Play'),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => RoutinePlayerScreen(routine: routine),
                              ));
                            },
                          ),
                          const SizedBox(width: 8),
                          // Per-routine delete button
                          IconButton(
                            tooltip: 'Delete routine',
                            color: Theme.of(context).colorScheme.error,
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Delete routine'),
                                  content: Text('Delete "${routine.name}"? This will remove it from your device and cloud.'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete')),
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
                                messenger.showSnackBar(const SnackBar(content: Text('Routine deleted')));
                              } catch (e) {
                                messenger.showSnackBar(SnackBar(content: Text('Failed to delete routine: $e')));
                              }
                            },
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(
                child: Text('Erro ao carregar rotinas: $err'),
              ),
            ),
          ),
        ],
      ),
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
    // The Create tab launches a modal to create a routine and returns it.
    final pages = <Widget>[_buildRoutinesPage(), const CalendarScreen(), const SizedBox.shrink()];

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
                        final auth = await showDialog<AuthDto?>(
                          context: context,
                          builder: (_) => CreateAccountDialog(),
                        );
                            if (!mounted) return;
                            if (auth != null) {
                              messenger.showSnackBar(SnackBar(
                                content: Text('Signed in: ${auth.email ?? auth.uid}'),
                              ));
                            }
                      },
                      label: const Text('Create Account'),
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
                          final auth = await showDialog<AuthDto?>(
                            context: context,
                            builder: (context) => const LoginDialog(),
                          );
                          if (!mounted) return;
                          if (auth != null) {
                            messenger.showSnackBar(SnackBar(
                              content: Text('Signed in: ${auth.email ?? auth.uid}'),
                            ));
                          }
                      },
                      label: const Text('Login'),
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
                      final displayLabel = name.isNotEmpty ? name : (email.isNotEmpty ? email : 'Account');
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
                              Text('Signed in as', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onPrimary)),
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
                            tooltip: 'Account settings',
                            onPressed: () async {
                              // Open the account settings dialog
                              await showDialog<void>(
                                context: context,
                                builder: (_) => const AccountSettingsDialog(),
                              );
                            },
                            icon: const Icon(Icons.settings, size: 20),
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          TextButton(
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              try {
                                await ref.read(authRepositoryProvider).signOut();
                                messenger.showSnackBar(const SnackBar(content: Text('Signed out')));
                              } catch (e) {
                                messenger.showSnackBar(SnackBar(content: Text('Sign out failed: $e')));
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            ),
                            child: const Text('Log Out'),
                          ),
                          const SizedBox(width: 6),
                        ],
                      );
                    }),
                  ),
                ],
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (i) async {
            if (i == 2) {
              // Open create routine screen
              await Navigator.of(context).push<Routine>(
                MaterialPageRoute(builder: (_) => const CreateRoutineScreen()),
              );
              // Voltar para tab de rotinas após criar
              setState(() => _selectedIndex = 0);
            } else {
              setState(() => _selectedIndex = i);
            }
          },
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Theme.of(context).colorScheme.onSurface.withValues(alpha:0.6),
          selectedIconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.primary,
            size: 30,
          ),
          unselectedIconTheme: const IconThemeData(size: 22),
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Column(children: [Icon(Icons.fitness_center), SizedBox(height: 4), Text('Routines')],)),
              label: ''),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Column(children: [Icon(Icons.calendar_today), SizedBox(height: 4), Text('Calendar')],)),
              label: ''),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Column(children: [Icon(Icons.add_circle_outline), SizedBox(height: 4), Text('Create')],)),
              label: ''),
          ],
      ),
    );
  }
}

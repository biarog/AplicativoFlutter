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

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Routines',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.rubikTextTheme(
          ThemeData.light().textTheme
        ),
        colorScheme: ColorScheme(
          primary: Colors.orange,
          secondary: const Color.fromARGB(255, 250, 189, 110),
          surface: Colors.white,
          error: Colors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.black,
          onError: Colors.white,
          brightness: Brightness.light
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        textTheme: GoogleFonts.rubikTextTheme(
          ThemeData.dark().textTheme
        ),
        colorScheme: ColorScheme(
          primary: Colors.deepOrange,
          secondary: const Color.fromARGB(255, 94, 55, 43),
          surface: Colors.grey[900]!,
          error: Colors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.white,
          onError: Colors.white,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
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

  // Example routine. In a full app you'd load user-created routines from
  // persistent storage or allow creating/editing them.
  Routine sampleRoutine() => Routine(
        id: 'sample-1',
        name: 'Full Body Quick',
        exercises: [
          Exercise(name: 'Jumping Jacks', seconds: 30),
          Exercise(name: 'Push Ups', seconds: 40),
          Exercise(name: 'Bodyweight Squats', seconds: 45),
          Exercise(name: 'Plank', seconds: 60),
        ],
      );

  Widget _buildRoutinesPage() {
    final routine = sampleRoutine();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your Routines', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1.5),
            ),
            child: ListTile(
              title: Text(routine.name),
              subtitle: Text('${routine.exercises.length} exercises • ~${routine.totalDuration}s'),
              trailing: ElevatedButton(
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
            ),
          ),
          const SizedBox(height: 16),
          const Text('Tip: Create and save more routines to see them here.'),
        ],
      ),
    );
  }

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
                          // Placeholder feedback — real login flow will replace this.
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
          onTap: (i) => setState(() => _selectedIndex = i),
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

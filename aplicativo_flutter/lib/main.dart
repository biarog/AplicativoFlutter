import 'package:flutter/material.dart';
import 'models/routine.dart';
import 'screens/routine_player_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/create_routine_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Routines',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
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
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
    // Build pages on each build so we can use context in children
    final pages = <Widget>[_buildRoutinesPage(), const CalendarScreen(), const CreateRoutineScreen()];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Routines'),
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

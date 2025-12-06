import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/schedule_provider.dart';
import '../providers/routine_provider.dart';
import '../providers/completed_routines_provider.dart';
import '../screens/configure_schedule_screen.dart';
import '../screens/routine_player_screen.dart';
import '../models/routine.dart';

class CalendarWidget extends ConsumerStatefulWidget {
  const CalendarWidget({super.key});

  @override
  ConsumerState<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends ConsumerState<CalendarWidget> {
  late DateTime _viewMonth;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _viewMonth = DateTime.now();
    _selectedDate = DateTime.now();
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  void _prevMonth() {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month - 1);
      _selectedDate = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _viewMonth = DateTime(_viewMonth.year, _viewMonth.month + 1);
      _selectedDate = null;
    });
  }

  List<DateTime?> _generateMonthGrid(DateTime month) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final startWeekday = first.weekday % 7; // Make Sunday=0

    final totalCells = ((startWeekday + daysInMonth) / 7).ceil() * 7;
    final List<DateTime?> cells = List.filled(totalCells, null);

    for (int i = 0; i < daysInMonth; i++) {
      final index = startWeekday + i;
      cells[index] = DateTime(month.year, month.month, i + 1);
    }

    return cells;
  }

  Widget _buildTopCard(BuildContext context, WidgetRef ref) {
    final scheduleAsync = ref.watch(scheduleProvider);
    final routinesAsync = ref.watch(userRoutinesProvider);
    final completedRoutinesAsync = ref.watch(completedRoutinesProvider);
    
    final today = DateTime.now();
    final todayDateString = DateTime(today.year, today.month, today.day).toIso8601String();

    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return scheduleAsync.when(
      data: (schedule) {
        final todayRoutineIds = schedule.getRoutineIdsForDay(today.weekday);

        return routinesAsync.when(
          data: (routines) {
            return completedRoutinesAsync.when(
              data: (completedRoutines) {
                // Filter routines that are scheduled for today but NOT completed
                final todayRoutinesNotCompleted = <Routine>[];
                
                for (final routineId in todayRoutineIds) {
                  try {
                    final routine = routines.firstWhere((r) => r.id == routineId);
                    // Check if routine was NOT completed today
                    final wasCompletedToday = completedRoutines[routineId]?.contains(todayDateString) ?? false;
                    
                    if (!wasCompletedToday) {
                      todayRoutinesNotCompleted.add(routine);
                    }
                  } catch (e) {
                    // Rotina não encontrada (foi deletada) - limpar do schedule
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ref.read(scheduleProvider.notifier).removeRoutineFromDay(today.weekday, routineId);
                    });
                  }
                }

                // Build content based on available routines
                late String title;
                late String info;

                if (todayRoutinesNotCompleted.isEmpty) {
                  title = 'Nenhum treino para hoje';
                  info = 'Todas as rotinas foram completadas!';
                } else {
                  title = '${todayRoutinesNotCompleted.length} rotina${todayRoutinesNotCompleted.length > 1 ? 's' : ''}';
                  
                  final totalExercises = todayRoutinesNotCompleted.fold<int>(
                    0,
                    (sum, routine) => sum + routine.exercises.length,
                  );
                  final totalDurationMinutes = todayRoutinesNotCompleted.fold<int>(
                    0,
                    (sum, routine) => sum + (routine.totalDuration / 60).round(),
                  );
                  
                  info = '$totalExercises exercícios · $totalDurationMinutes min';
                }

                return Card(
                  color: secondary.withAlpha((0.12 * 255).round()),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: primary.withAlpha((0.12 * 255).round()),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.fitness_center, color: primary, size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Treino de Hoje', style: TextStyle(color: primary, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 6),
                                  Text(info, style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // List of today's routines
                        if (todayRoutinesNotCompleted.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Divider(color: primary.withAlpha((0.2 * 255).round()), height: 12),
                          const SizedBox(height: 8),
                          ...todayRoutinesNotCompleted.map((routine) {
                            final exerciseCount = routine.exercises.length;
                            final durationMinutes = (routine.totalDuration / 60).round();
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(routine.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 4),
                                        Text('$exerciseCount exercícios · $durationMinutes min', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => RoutinePlayerScreen(routine: routine),
                                        ),
                                      );
                                    },
                                    icon: Icon(Icons.play_arrow, color: primary),
                                    iconSize: 24,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                );
              },
              loading: () => Card(
                color: secondary.withAlpha((0.12 * 255).round()),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, stack) => Card(
                color: secondary.withAlpha((0.12 * 255).round()),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text('Erro ao carregar rotinas completadas'),
                ),
              ),
            );
          },
          loading: () => Card(
            color: secondary.withAlpha((0.12 * 255).round()),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, stack) => Card(
            color: secondary.withAlpha((0.12 * 255).round()),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('Erro ao carregar rotinas'),
            ),
          ),
        );
      },
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text('Erro ao carregar agenda: $err'),
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.titleMedium;
    final monthYear = DateFormat.yMMMM('pt_BR').format(_viewMonth);
    final days = _generateMonthGrid(_viewMonth);
    
    // Watch completadas rotinas e schedule
    final completedRoutinesAsync = ref.watch(completedRoutinesProvider);
    final scheduleAsync = ref.watch(scheduleProvider);

    return completedRoutinesAsync.when(
      data: (completedMap) => scheduleAsync.when(
        data: (schedule) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left)),
                Text(monthYear, style: headerStyle?.copyWith(fontWeight: FontWeight.w700)),
                IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right)),
              ],
            ),
            const SizedBox(height: 8),
            // Weekday labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sáb"].map((e) => Expanded(child: Center(child: Text(e, style: TextStyle(fontWeight: FontWeight.w600))))).toList(),
            ),
            const SizedBox(height: 8),
            // Grid
            SizedBox(
              height: 320,
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 7,
                childAspectRatio: 1.1,
                children: days.map((d) {
                  if (d == null) return const SizedBox.shrink();

                  final isToday = _isToday(d);
                  final isSelected = _selectedDate != null && d.year == _selectedDate!.year && d.month == _selectedDate!.month && d.day == _selectedDate!.day;
                  
                  // Verificar se alguma rotina configurada para este dia foi completada
                  final routineIdsForDay = schedule.getRoutineIdsForDay(d.weekday);
                  final dateString = DateTime(d.year, d.month, d.day).toIso8601String();
                  
                  // Há alguma rotina completada neste dia?
                  final hasCompletedRoutine = routineIdsForDay.isNotEmpty &&
                      routineIdsForDay.any((id) => completedMap[id]?.contains(dateString) ?? false);
                  
                  // Há rotina agendada mas não completada
                  final hasScheduledRoutine = routineIdsForDay.isNotEmpty && !hasCompletedRoutine;

                Color bg = Colors.white;
                Color textColor = Colors.black;

                if (isToday) {
                  bg = Theme.of(context).colorScheme.primary;
                  textColor = Colors.white;
                } else if (isSelected) {
                  bg = Theme.of(context).colorScheme.primary.withAlpha((0.16 * 255).round());
                }

                return GestureDetector(
                  onTap: () => setState(() => _selectedDate = d),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.topCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text('${d.day}', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          // Indicador visual de rotina completada (verde)
                          if (hasCompletedRoutine)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            )
                          // Indicador visual de treino programado (não completado)
                          else if (hasScheduledRoutine)
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
        loading: () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left)),
                Text(monthYear, style: headerStyle?.copyWith(fontWeight: FontWeight.w700)),
                IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right)),
              ],
            ),
            const SizedBox(height: 16),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
        error: (err, stack) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left)),
                Text(monthYear, style: headerStyle?.copyWith(fontWeight: FontWeight.w700)),
                IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right)),
              ],
            ),
            const SizedBox(height: 16),
            const Center(child: Text('Erro ao carregar agenda')),
          ],
        ),
      ),
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left)),
              Text(monthYear, style: headerStyle?.copyWith(fontWeight: FontWeight.w700)),
              IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right)),
            ],
          ),
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
      error: (err, stack) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: _prevMonth, icon: const Icon(Icons.chevron_left)),
              Text(monthYear, style: headerStyle?.copyWith(fontWeight: FontWeight.w700)),
              IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right)),
            ],
          ),
          const SizedBox(height: 16),
          const Center(child: Text('Erro ao carregar calendário')),
        ],
      ),
    );
  }

  Widget _buildDayPanel(BuildContext context) {
    if (_selectedDate == null) return const SizedBox.shrink();

    final completedRoutinesAsync = ref.watch(completedRoutinesProvider);
    final routinesAsync = ref.watch(userRoutinesProvider);
    final dateLabel = DateFormat('d MMMM', 'pt_BR').format(_selectedDate!);
    final dateString = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day).toIso8601String();

    return Card(
      color: Theme.of(context).colorScheme.primary.withAlpha((0.06 * 255).round()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.fitness_center, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(dateLabel, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
                IconButton(onPressed: () => setState(() => _selectedDate = null), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 8),
            completedRoutinesAsync.when(
              data: (completedMap) {
                // Buscar rotinas que foram completadas nesta data
                final completedRoutineIds = completedMap.entries
                    .where((entry) => entry.value.contains(dateString))
                    .map((entry) => entry.key)
                    .toList();

                if (completedRoutineIds.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text('Nenhum treino realizado neste dia', style: Theme.of(context).textTheme.bodyMedium),
                  );
                }

                // Buscar detalhes das rotinas completadas
                return routinesAsync.when(
                  data: (routines) {
                    final completedRoutines = routines
                        .where((r) => completedRoutineIds.contains(r.id))
                        .toList();

                    return Column(
                      children: completedRoutines.map((routine) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.check_circle, color: Colors.green),
                            title: Text(routine.name),
                            subtitle: Text('${routine.exercises.length} exercícios · ${(routine.totalDuration / 60).round()} min'),
                          ),
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (err, _) => const Text('Erro ao carregar detalhes'),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => const Text('Erro ao carregar'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildFooterCard(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(8)),
          child: Icon(Icons.settings, color: Theme.of(context).colorScheme.inverseSurface),
        ),
        title: Text('Configurar Agenda', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        subtitle: Text('Organize seus treinos da semana', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ConfigureScheduleScreen(),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopCard(context, ref),
              const SizedBox(height: 12),
              _buildCalendar(context),
              const SizedBox(height: 12),
              _buildDayPanel(context),
              const SizedBox(height: 12),
              _buildFooterCard(context),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/routine.dart';
import '../providers/schedule_provider.dart';
import '../providers/routine_provider.dart';
import '../l10n/app_localizations.dart';

class ConfigureScheduleScreen extends ConsumerStatefulWidget {
  const ConfigureScheduleScreen({super.key});

  @override
  ConsumerState<ConfigureScheduleScreen> createState() => _ConfigureScheduleScreenState();
}

class _ConfigureScheduleScreenState extends ConsumerState<ConfigureScheduleScreen> {
  List<String> get weekDays {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return List.generate(7, (index) {
      final day = monday.add(Duration(days: index));
      return DateFormat.EEEE(Localizations.localeOf(context).toString()).format(day);
    });
  }

  @override
  Widget build(BuildContext context) {
    final routinesAsync = ref.watch(userRoutinesProvider);
    final scheduleAsync = ref.watch(scheduleProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.configureSchedule),
        elevation: 0,
      ),
      body: routinesAsync.when(
        data: (routines) {
          return scheduleAsync.when(
            data: (schedule) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0).copyWith(bottom: 80.0),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.selectRoutinesForEachDay,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ...List.generate(
                          7,
                          (index) => _buildDaySelector(context, routines, weekDays[index], index, schedule),
                        ),
                        const SizedBox(height: 24),
                        // Info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withAlpha((0.1 * 255).round()),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.totalScheduledRoutines(schedule.routineIdsByDay.values.fold<int>(0, (sum, list) => sum + list.length)),
                            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(AppLocalizations.of(context)!.save),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (err, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(AppLocalizations.of(context)!.errorLoadingCalendar),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.loadingRoutines),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context)!.errorLoadingRoutines),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaySelector(BuildContext context, List<Routine> routines, String dayName, int dayIndex, WeeklySchedule schedule) {
    final selectedRoutineIds = schedule.routineIdsByDay[dayIndex] ?? [];
    
    // Validar se as rotinas selecionadas ainda existem
    final validSelectedIds = selectedRoutineIds
        .where((id) => routines.any((r) => r.id == id))
        .toList();
    
    // Se detectamos rotinas inválidas, limpar do schedule
    if (validSelectedIds.length != selectedRoutineIds.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final id in selectedRoutineIds) {
          if (!routines.any((r) => r.id == id)) {
            ref.read(scheduleProvider.notifier).removeRoutineFromDay(dayIndex, id);
          }
        }
      });
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dayName,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...routines.map((routine) {
              final isSelected = validSelectedIds.contains(routine.id);
              return CheckboxListTile(
                value: isSelected,
                onChanged: (selected) {
                  if (selected == true) {
                    ref.read(scheduleProvider.notifier).addRoutineToDay(dayIndex, routine.id);
                  } else {
                    ref.read(scheduleProvider.notifier).removeRoutineFromDay(dayIndex, routine.id);
                  }
                },
                title: Text(routine.name, style: const TextStyle(fontSize: 14)),
                subtitle: Text(
                  '${routine.exercises.length} exercícios · ${(routine.totalDuration / 60).round()} min',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              );
            }),
            if (validSelectedIds.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  AppLocalizations.of(context)!.noRoutineSelected,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

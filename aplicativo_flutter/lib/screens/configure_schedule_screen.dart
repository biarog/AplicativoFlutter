import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine.dart';
import '../providers/schedule_provider.dart';
import '../providers/routine_provider.dart';

class ConfigureScheduleScreen extends ConsumerStatefulWidget {
  const ConfigureScheduleScreen({super.key});

  @override
  ConsumerState<ConfigureScheduleScreen> createState() => _ConfigureScheduleScreenState();
}

class _ConfigureScheduleScreenState extends ConsumerState<ConfigureScheduleScreen> {
  final List<String> weekDays = ['Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado', 'Domingo'];

  @override
  Widget build(BuildContext context) {
    final routinesAsync = ref.watch(userRoutinesProvider);
    final schedule = ref.watch(scheduleProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Agenda'),
        elevation: 0,
      ),
      body: routinesAsync.when(
        data: (routines) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0).copyWith(bottom: 80.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Selecione uma rotina para cada dia da semana',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ...List.generate(
                      7,
                      (index) => _buildDaySelector(context, routines, weekDays[index], index, schedule),
                    ),
                    const SizedBox(height: 24),
                    // Debug info - mostrar estado atual
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha((0.1 * 255).round()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Configurações salvas: ${schedule.routineIdsByDay.values.where((v) => v != null).length} rotinas',
                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Concluído'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Carregando rotinas...'),
            ],
          ),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Erro ao carregar rotinas'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDaySelector(BuildContext context, List<Routine> routines, String dayName, int dayIndex, WeeklySchedule schedule) {
    final selectedRoutineId = schedule.routineIdsByDay[dayIndex];
    
    // Validar se a rotina selecionada ainda existe
    final isValidSelection = selectedRoutineId == null || 
        routines.any((r) => r.id == selectedRoutineId);
    
    // Se a rotina não existe mais, limpar a seleção
    final validSelectedId = isValidSelection ? selectedRoutineId : null;
    
    // Se detectamos uma rotina inválida, limpar do schedule
    if (!isValidSelection) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(scheduleProvider.notifier).setRoutineForDay(dayIndex, null);
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
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButton<String?>(
                value: validSelectedId,
                isExpanded: true,
                underline: const SizedBox(), // Remove default underline
                hint: const Text('Selecione uma rotina'),
                onChanged: (value) {
                  debugPrint('Selecionado para $dayName (índice $dayIndex): $value');
                  ref.read(scheduleProvider.notifier).setRoutineForDay(dayIndex, value);
                },
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Nenhuma rotina'),
                  ),
                  ...routines.map(
                    (routine) => DropdownMenuItem(
                      value: routine.id,
                      child: Text(routine.name),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

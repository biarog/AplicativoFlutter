import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Workout {
  final String title;
  final String time; // HH:mm
  final int exercises;
  final int minutes;
  final Color color;

  Workout({
    required this.title,
    required this.time,
    required this.exercises,
    required this.minutes,
    required this.color,
  });
}

class CalendarWidget extends StatefulWidget {
  const CalendarWidget({super.key});

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _viewMonth = DateTime.now();
  DateTime? _selectedDate;

  // Mock data: YYYY-MM-DD -> list of workouts
  late final Map<String, List<Workout>> _workoutsByDate = _buildMockData();

  static Map<String, List<Workout>> _buildMockData() {
    return {
      '2024-11-15': [
        Workout(title: 'Treino de Peito', time: '08:00', exercises: 8, minutes: 45, color: Colors.orange),
        Workout(title: 'Cardio', time: '18:00', exercises: 1, minutes: 30, color: Colors.red),
      ],
      '2024-11-14': [Workout(title: 'Treino de Costas', time: '07:00', exercises: 7, minutes: 40, color: Colors.blue)],
      '2024-11-12': [Workout(title: 'Treino de Pernas', time: '06:30', exercises: 6, minutes: 50, color: Colors.green)],
      '2024-11-10': [Workout(title: 'Treino de Braços', time: '19:00', exercises: 5, minutes: 35, color: Colors.purple)],
      '2024-11-08': [Workout(title: 'Treino de Ombros', time: '17:00', exercises: 6, minutes: 30, color: Colors.teal)],
      '2024-11-05': [Workout(title: 'HIIT Cardio', time: '12:00', exercises: 1, minutes: 20, color: Colors.redAccent)],
    };
  }

  String _formatKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  bool _hasWorkouts(DateTime d) => _workoutsByDate.containsKey(_formatKey(d));

  List<Workout> _workoutsFor(DateTime d) => _workoutsByDate[_formatKey(d)] ?? [];

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

  Widget _buildTopCard(BuildContext context) {
    // pick today's workouts if any or a sample routine
    final todayKey = _formatKey(DateTime.now());
    final todays = _workoutsByDate[todayKey] ?? [];

    final title = todays.isNotEmpty ? todays.first.title : 'Treino de Hoje';
    final time = todays.isNotEmpty ? todays.first.time : '08:00';
    final info = todays.isNotEmpty ? '${todays.first.exercises} exercícios · ${todays.first.minutes} min' : 'Nenhum treino hoje';

    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;

    return Card(
      color: secondary.withAlpha((0.12 * 255).round()),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
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
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(time, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 12),
                    Text(info, style: Theme.of(context).textTheme.bodySmall),
                  ])
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.play_arrow, color: primary),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    final headerStyle = Theme.of(context).textTheme.titleMedium;
    final monthYear = DateFormat.yMMMM('pt_BR').format(_viewMonth);
    final days = _generateMonthGrid(_viewMonth);

    return Column(
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
              final hasWorkout = _hasWorkouts(d);

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
                        if (hasWorkout)
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
    );
  }

  Widget _buildDayPanel(BuildContext context) {
    if (_selectedDate == null) return const SizedBox.shrink();

    final list = _workoutsFor(_selectedDate!);
    final dateLabel = DateFormat('d MMMM', 'pt_BR').format(_selectedDate!);

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
            if (list.isEmpty)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('Nenhum treino realizado neste dia', style: Theme.of(context).textTheme.bodyMedium),
              )
            else
              Column(
                children: list.map((w) => _buildWorkoutCard(context, w)).toList(),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, Workout w) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: w.color, child: const Icon(Icons.fitness_center, color: Colors.white)),
        title: Text(w.title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${w.time} · ${w.exercises} exercícios · ${w.minutes} min'),
        trailing: IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right)),
      ),
    );
  }

  Widget _buildFooterCard(BuildContext context) {
    return Card(
      color: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.settings, color: Colors.black54),
        ),
        title: Text('Configurar Agenda', style: TextStyle(color: Theme.of(context).colorScheme.surface)),
        subtitle: Text('Organize seus treinos da semana', style: TextStyle(color: Theme.of(context).colorScheme.surface)),
        onTap: () {},
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
              _buildTopCard(context),
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

import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

/// Screen for creating and editing habits.
///
/// This focuses on functionality: quick templates, categories, and flexible
/// frequencies (daily, weekly, specific days). Visual polish can come later.
class HabitManagementScreen extends StatefulWidget {
  const HabitManagementScreen({super.key});

  @override
  State<HabitManagementScreen> createState() => _HabitManagementScreenState();
}

class _HabitManagementScreenState extends State<HabitManagementScreen> {
  List<Habit> _habits = const [];

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _habits = habitService.getAllHabits();
    });
  }

  Future<void> _openEditor({Habit? habit}) async {
    final changed = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => HabitEditPage(existing: habit)));
    if (changed == true) {
      _refresh();
    }
  }

  void _deleteHabit(Habit habit) {
    habitService.deleteHabit(habit.id);
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Habits')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF1D1B4C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF22D3EE), Color(0xFF6366F1)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF22D3EE).withOpacity(0.45),
                            blurRadius: 24,
                            spreadRadius: -10,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.auto_awesome, size: 20, color: Colors.black),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your habit library',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Create, reorder and tune habits that power your day.',
                            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.75)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _habits.isEmpty
                      ? const _EmptyHabitsState()
                      : ListView.builder(
                          itemCount: _habits.length,
                          itemBuilder: (context, index) {
                            final habit = _habits[index];
                            return _HabitCard(
                              habit: habit,
                              onTap: () => _openEditor(habit: habit),
                              onDelete: () => _deleteHabit(habit),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Add habit'),
      ),
    );
  }
}

class _EmptyHabitsState extends StatelessWidget {
  const _EmptyHabitsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: [Color(0xFF22D3EE), Color(0xFF6366F1)]),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22D3EE).withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: -12,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: const Icon(Icons.bolt_rounded, size: 30, color: Colors.black),
          ),
          const SizedBox(height: 16),
          const Text('No habits yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(
            'Start by adding a few glow-up habits.\nWe\'ll track streaks and insights for you.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({required this.habit, required this.onTap, required this.onDelete});

  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  Color _categoryColor(HabitCategory category) {
    switch (category) {
      case HabitCategory.health:
        return const Color(0xFF22C55E);
      case HabitCategory.learning:
        return const Color(0xFF0EA5E9);
      case HabitCategory.fitness:
        return const Color(0xFFFB923C);
      case HabitCategory.work:
        return const Color(0xFFF97316);
      case HabitCategory.spiritual:
        return const Color(0xFFA855F7);
      case HabitCategory.finance:
        return const Color(0xFFFACC15);
      case HabitCategory.other:
        return const Color(0xFF9CA3AF);
    }
  }

  String get _typeLabel {
    switch (habit.type) {
      case HabitType.boolean:
        return 'Yes / No';
      case HabitType.count:
        return 'Counter';
      case HabitType.duration:
        return 'Timer';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _categoryColor(habit.category);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.03),
          border: Border.all(color: color.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 24,
              spreadRadius: -12,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [color, color.withOpacity(0.7)]),
              ),
              child: const Icon(Icons.check_rounded, size: 18, color: Colors.black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          habit.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: Colors.black.withOpacity(0.35),
                        ),
                        child: Text(
                          habit.category.name,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    habit.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: Colors.white.withOpacity(0.06),
                          border: Border.all(color: Colors.white.withOpacity(0.14)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bolt_rounded, size: 13, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              _typeLabel,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (habit.dailyTarget != null)
                        Text(
                          habit.type == HabitType.count
                              ? 'Target: ${habit.dailyTarget} / day'
                              : 'Target: ${habit.dailyTarget} min',
                          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              color: Colors.white.withOpacity(0.9),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

/// Form page for creating or editing a single habit.
class HabitEditPage extends StatefulWidget {
  const HabitEditPage({super.key, this.existing});

  final Habit? existing;

  @override
  State<HabitEditPage> createState() => _HabitEditPageState();
}

class _HabitEditPageState extends State<HabitEditPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _targetController;
  late final TextEditingController _timesPerWeekController;

  HabitCategory _category = HabitCategory.health;
  HabitType _habitType = HabitType.boolean;
  HabitFrequencyType _frequencyType = HabitFrequencyType.daily;
  Set<int> _specificDays = <int>{};

  @override
  void initState() {
    super.initState();

    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _descriptionController = TextEditingController(text: existing?.description ?? '');
    _targetController = TextEditingController(
      text: existing?.dailyTarget != null ? '${existing!.dailyTarget}' : '',
    );
    _timesPerWeekController = TextEditingController();

    if (existing != null) {
      _category = existing.category;
      _habitType = existing.type;
      final schedule = existing.schedule;
      _frequencyType = schedule.type;
      if (schedule.type == HabitFrequencyType.weeklyTimes && schedule.timesPerWeek != null) {
        _timesPerWeekController.text = '${schedule.timesPerWeek}';
      } else if (schedule.type == HabitFrequencyType.specificDays && schedule.daysOfWeek != null) {
        _specificDays = Set<int>.from(schedule.daysOfWeek!);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    _timesPerWeekController.dispose();
    super.dispose();
  }

  void _applyTemplate(HabitTemplate template) {
    setState(() {
      _nameController.text = template.name;
      _descriptionController.text = template.description;
      _habitType = template.type;
      _category = template.category;
      _targetController.text = template.dailyTarget?.toString() ?? '';

      final schedule = template.schedule;
      _frequencyType = schedule.type;
      if (schedule.type == HabitFrequencyType.weeklyTimes && schedule.timesPerWeek != null) {
        _timesPerWeekController.text = '${schedule.timesPerWeek}';
      } else if (schedule.type == HabitFrequencyType.specificDays && schedule.daysOfWeek != null) {
        _specificDays = Set<int>.from(schedule.daysOfWeek!);
      } else {
        _timesPerWeekController.text = '';
        _specificDays = <int>{};
      }
    });
  }

  HabitSchedule _buildSchedule() {
    switch (_frequencyType) {
      case HabitFrequencyType.daily:
        return const HabitSchedule.daily();
      case HabitFrequencyType.weeklyTimes:
        final raw = int.tryParse(_timesPerWeekController.text) ?? 1;
        final clamped = raw.clamp(1, 7);
        return HabitSchedule.weeklyTimes(clamped);
      case HabitFrequencyType.specificDays:
        final days = _specificDays.isEmpty ? <int>{DateTime.now().weekday} : _specificDays;
        return HabitSchedule.specificDays(days);
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Name is required.')));
      return;
    }

    int? target;
    if (_habitType != HabitType.boolean) {
      target = int.tryParse(_targetController.text);
      if (target == null || target <= 0) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please enter a positive target value.')));
        return;
      }
    }

    final schedule = _buildSchedule();
    final existing = widget.existing;

    if (existing == null) {
      habitService.createHabit(
        name: name,
        description: description,
        type: _habitType,
        dailyTarget: target,
        category: _category,
        schedule: schedule,
      );
    } else {
      habitService.updateHabit(
        Habit(
          id: existing.id,
          name: name,
          description: description,
          type: _habitType,
          dailyTarget: target,
          category: _category,
          schedule: schedule,
        ),
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit habit' : 'New habit')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF020617), Color(0xFF0F172A), Color(0xFF1D1B4C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF22D3EE), Color(0xFF6366F1)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF22D3EE).withOpacity(0.4),
                          blurRadius: 24,
                          spreadRadius: -10,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.edit_rounded, size: 18, color: Colors.black),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing ? 'Tweak your habit' : 'Create a new habit',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Give it a clear name, target and schedule so insights stay accurate.',
                          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.03),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Start from a template',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tpl in defaultHabitTemplates)
                          ChoiceChip(
                            label: Text(tpl.name),
                            selected: _nameController.text == tpl.name,
                            onSelected: (_) => _applyTemplate(tpl),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.03),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Habit name',
                        hintText: 'e.g. Drink water, Meditate',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Short sentence about what success looks like',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<HabitCategory>(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: HabitCategory.values
                          .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _category = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<HabitType>(
                      initialValue: _habitType,
                      decoration: const InputDecoration(labelText: 'Habit type'),
                      items: HabitType.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(switch (t) {
                                HabitType.boolean => 'Yes / No',
                                HabitType.count => 'Counter (times per day)',
                                HabitType.duration => 'Timer (minutes)',
                              }),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _habitType = value);
                      },
                    ),
                    const SizedBox(height: 8),
                    if (_habitType != HabitType.boolean)
                      TextField(
                        controller: _targetController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: _habitType == HabitType.count
                              ? 'Daily target (count)'
                              : 'Daily target (minutes)',
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withOpacity(0.03),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Frequency', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    RadioListTile<HabitFrequencyType>(
                      title: const Text('Every day'),
                      value: HabitFrequencyType.daily,
                      groupValue: _frequencyType,
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _frequencyType = v);
                      },
                    ),
                    RadioListTile<HabitFrequencyType>(
                      title: const Text('Times per week'),
                      value: HabitFrequencyType.weeklyTimes,
                      groupValue: _frequencyType,
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _frequencyType = v);
                      },
                      subtitle: _frequencyType == HabitFrequencyType.weeklyTimes
                          ? TextField(
                              controller: _timesPerWeekController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Target times per week (1-7)',
                              ),
                            )
                          : null,
                    ),
                    RadioListTile<HabitFrequencyType>(
                      title: const Text('Specific days of week'),
                      value: HabitFrequencyType.specificDays,
                      groupValue: _frequencyType,
                      onChanged: (v) {
                        if (v == null) return;
                        setState(() => _frequencyType = v);
                      },
                    ),
                    if (_frequencyType == HabitFrequencyType.specificDays)
                      Wrap(
                        spacing: 4,
                        children: List<Widget>.generate(7, (index) {
                          final dayIndex = index + 1; // 1 = Monday
                          final labels = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          final selected = _specificDays.contains(dayIndex);
                          return FilterChip(
                            label: Text(labels[index]),
                            selected: selected,
                            onSelected: (value) {
                              setState(() {
                                if (value) {
                                  _specificDays.add(dayIndex);
                                } else {
                                  _specificDays.remove(dayIndex);
                                }
                              });
                            },
                          );
                        }),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(isEditing ? 'Save changes' : 'Create habit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

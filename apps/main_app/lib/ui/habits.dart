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
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => HabitEditPage(existing: habit),
      ),
    );
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
      appBar: AppBar(
        title: const Text('Manage Habits'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _habits.length,
        itemBuilder: (context, index) {
          final habit = _habits[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(habit.name),
              subtitle: Text(
                '${habit.description}\n'
                'Category: ${habit.category.name} · '
                'Type: ${habit.type.name}',
              ),
              isThreeLine: true,
              onTap: () => _openEditor(habit: habit),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteHabit(habit),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('Add habit'),
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
    _targetController =
        TextEditingController(text: existing?.dailyTarget != null ? '${existing!.dailyTarget}' : '');
    _timesPerWeekController = TextEditingController();

    if (existing != null) {
      _category = existing.category;
      _habitType = existing.type;
      final schedule = existing.schedule;
      _frequencyType = schedule.type;
      if (schedule.type == HabitFrequencyType.weeklyTimes && schedule.timesPerWeek != null) {
        _timesPerWeekController.text = '${schedule.timesPerWeek}';
      } else if (schedule.type == HabitFrequencyType.specificDays &&
          schedule.daysOfWeek != null) {
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
      } else if (schedule.type == HabitFrequencyType.specificDays &&
          schedule.daysOfWeek != null) {
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
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Name is required.')));
      return;
    }

    int? target;
    if (_habitType != HabitType.boolean) {
      target = int.tryParse(_targetController.text);
      if (target == null || target <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a positive target value.')),
        );
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
      appBar: AppBar(
        title: Text(isEditing ? 'Edit habit' : 'New habit'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  ActionChip(
                    label: Text(tpl.name),
                    onPressed: () => _applyTemplate(tpl),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Habit name',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<HabitCategory>(
              value: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: HabitCategory.values
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(c.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _category = value);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<HabitType>(
              value: _habitType,
              decoration: const InputDecoration(labelText: 'Habit type'),
              items: HabitType.values
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(
                        switch (t) {
                          HabitType.boolean => 'Yes / No',
                          HabitType.count => 'Counter (times per day)',
                          HabitType.duration => 'Timer (minutes)',
                        },
                      ),
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
            const SizedBox(height: 16),
            const Text(
              'Frequency',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Column(
              children: [
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: Text(isEditing ? 'Save changes' : 'Create habit'),
            ),
          ],
        ),
      ),
    );
  }
}



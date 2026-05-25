import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_bell/database/hive_service.dart';
import 'package:task_bell/localization/app_strings.dart';
import 'package:task_bell/models/future_idea.dart';
import 'package:task_bell/services/future_idea_service.dart';
import 'package:task_bell/theme/app_theme.dart';

class IdeasScreen extends StatefulWidget {
  const IdeasScreen({super.key});

  @override
  State<IdeasScreen> createState() => _IdeasScreenState();
}

class _IdeasScreenState extends State<IdeasScreen> {
  final _service = FutureIdeaService();
  int? _categoryFilter;
  bool? _doneFilter;

  IconData _categoryIcon(int category) {
    switch (category) {
      case IdeaCategory.movies:
        return Icons.movie_outlined;
      case IdeaCategory.music:
        return Icons.music_note_outlined;
      case IdeaCategory.creative:
        return Icons.palette_outlined;
      default:
        return Icons.lightbulb_outline;
    }
  }

  Color _categoryColor(int category) {
    switch (category) {
      case IdeaCategory.movies:
        return const Color(0xFF5C6BC0);
      case IdeaCategory.music:
        return const Color(0xFF26A69A);
      case IdeaCategory.creative:
        return const Color(0xFFAB47BC);
      default:
        return const Color(0xFF78909C);
    }
  }

  Future<void> _showIdeaDialog({FutureIdea? existing}) async {
    final s = AppStrings.of(context);
    final titleController = TextEditingController(text: existing?.title ?? '');
    final noteController = TextEditingController(text: existing?.note ?? '');
    int category = existing?.category ?? IdeaCategory.other;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(existing == null ? s.addIdea : s.editIdea),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: s.ideaTitleHint,
                        hintText: s.subjectHint,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      autofocus: existing == null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      s.description,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _CategoryChip(
                          label: s.categoryMovies,
                          icon: Icons.movie_outlined,
                          selected: category == IdeaCategory.movies,
                          color: _categoryColor(IdeaCategory.movies),
                          onTap: () =>
                              setDialogState(() => category = IdeaCategory.movies),
                        ),
                        _CategoryChip(
                          label: s.categoryMusic,
                          icon: Icons.music_note_outlined,
                          selected: category == IdeaCategory.music,
                          color: _categoryColor(IdeaCategory.music),
                          onTap: () =>
                              setDialogState(() => category = IdeaCategory.music),
                        ),
                        _CategoryChip(
                          label: s.categoryCreative,
                          icon: Icons.palette_outlined,
                          selected: category == IdeaCategory.creative,
                          color: _categoryColor(IdeaCategory.creative),
                          onTap: () => setDialogState(
                            () => category = IdeaCategory.creative,
                          ),
                        ),
                        _CategoryChip(
                          label: s.categoryOther,
                          icon: Icons.lightbulb_outline,
                          selected: category == IdeaCategory.other,
                          color: _categoryColor(IdeaCategory.other),
                          onTap: () =>
                              setDialogState(() => category = IdeaCategory.other),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: s.ideaNoteHint,
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(s.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) return;
                    Navigator.of(dialogContext).pop(true);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(s.save),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved != true || !mounted) return;

    final title = titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.enterIdeaTitle)),
      );
      return;
    }

    final note = noteController.text.trim();
    if (existing != null) {
      await _service.update(
        existing.copyWith(
          title: title,
          note: note,
          category: category,
        ),
      );
    } else {
      await _service.add(
        FutureIdea(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          note: note,
          category: category,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          s.ideasAndPlans,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              s.ideasSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                FilterChip(
                  label: Text(s.filterAll),
                  selected: _categoryFilter == null && _doneFilter == null,
                  onSelected: (_) => setState(() {
                    _categoryFilter = null;
                    _doneFilter = null;
                  }),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(s.filterActive),
                  selected: _doneFilter == false,
                  onSelected: (_) => setState(() {
                    _doneFilter = false;
                    _categoryFilter = null;
                  }),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(s.filterDone),
                  selected: _doneFilter == true,
                  onSelected: (_) => setState(() {
                    _doneFilter = true;
                    _categoryFilter = null;
                  }),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(s.categoryMovies),
                  selected: _categoryFilter == IdeaCategory.movies,
                  onSelected: (_) => setState(() {
                    _categoryFilter = IdeaCategory.movies;
                    _doneFilter = null;
                  }),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(s.categoryMusic),
                  selected: _categoryFilter == IdeaCategory.music,
                  onSelected: (_) => setState(() {
                    _categoryFilter = IdeaCategory.music;
                    _doneFilter = null;
                  }),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Text(s.categoryCreative),
                  selected: _categoryFilter == IdeaCategory.creative,
                  onSelected: (_) => setState(() {
                    _categoryFilter = IdeaCategory.creative;
                    _doneFilter = null;
                  }),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: HiveService.ideasBox.listenable(),
              builder: (context, _) {
                final ideas = _service.getAll(
                  categoryFilter: _categoryFilter,
                  doneOnly: _doneFilter,
                );

                if (ideas.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        s.ideasEmptyHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 88),
                  itemCount: ideas.length,
                  itemBuilder: (context, index) {
                    final idea = ideas[index];
                    final color = _categoryColor(idea.category);
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.15),
                          child: Icon(
                            _categoryIcon(idea.category),
                            color: color,
                          ),
                        ),
                        title: Text(
                          idea.title,
                          style: TextStyle(
                            decoration: idea.isDone
                                ? TextDecoration.lineThrough
                                : null,
                            color: idea.isDone
                                ? theme.colorScheme.onSurfaceVariant
                                : null,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              s.ideaCategoryLabel(idea.category),
                              style: TextStyle(
                                fontSize: 12,
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (idea.note.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(idea.note),
                            ],
                          ],
                        ),
                        isThreeLine: idea.note.isNotEmpty,
                        onTap: () => _showIdeaDialog(existing: idea),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) async {
                            switch (value) {
                              case 'toggle':
                                await _service.toggleDone(idea);
                              case 'delete':
                                await _service.delete(idea.id);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'toggle',
                              child: Text(
                                idea.isDone ? s.markActive : s.markDone,
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text(s.delete),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showIdeaDialog(),
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(s.addIdea, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: selected ? Colors.white : color),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: selected,
      selectedColor: color,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : null,
      ),
      onSelected: (_) => onTap(),
    );
  }
}

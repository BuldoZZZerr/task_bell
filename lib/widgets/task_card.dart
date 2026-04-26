import 'package:flutter/material.dart';
import 'package:task_bell/theme/app_theme.dart';
import 'package:task_bell/localization/app_strings.dart';

class TaskCard extends StatefulWidget {
  final String subject;
  final String description;
  final String homework;
  final bool isDone;
  final VoidCallback onToggleDone;
  final String? timeText;
  final ValueChanged<String>? onHomeworkChanged;
  final VoidCallback? onEdit;
  final EdgeInsetsGeometry? margin;

  const TaskCard({
    super.key,
    required this.subject,
    required this.description,
    this.homework = '',
    required this.isDone,
    required this.onToggleDone,
    this.timeText,
    this.onHomeworkChanged,
    this.onEdit,
    this.margin,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isExpanded = false;
  late TextEditingController _homeworkController;
  late FocusNode _homeworkFocusNode;

  @override
  void initState() {
    super.initState();
    _homeworkController = TextEditingController(text: widget.homework);
    _homeworkFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(TaskCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.homework != widget.homework) {
      _homeworkController.text = widget.homework;
    }
  }

  @override
  void dispose() {
    _homeworkController.dispose();
    _homeworkFocusNode.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    if (_isExpanded) {
      _homeworkFocusNode.unfocus();
      final text = _homeworkController.text.trim();
      if (text != widget.homework && widget.onHomeworkChanged != null) {
        widget.onHomeworkChanged!(text);
      }
    }
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor =
        widget.isDone ? AppTheme.cardPeach : AppTheme.cardBlue;

    return Container(
      margin: widget.margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: _toggleExpanded,
            behavior: HitTestBehavior.opaque,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (widget.timeText != null) ...[
                            Text(
                              widget.timeText!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: Text(
                              widget.subject,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (!_isExpanded && widget.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.description,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.onEdit != null)
                      GestureDetector(
                        onTap: widget.onEdit,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 20,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ),
                    GestureDetector(
                      onTap: widget.onToggleDone,
                      child: Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: widget.isDone
                            ? const Icon(
                                Icons.check,
                                size: 18,
                                color: AppTheme.primaryGreen,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ...(_isExpanded
              ? [
                  const SizedBox(height: 12),
                  TextField(
                    controller: _homeworkController,
                    focusNode: _homeworkFocusNode,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: AppStrings.of(context).taskNotesHint,
                      hintStyle:
                          TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    onSubmitted: (_) => _toggleExpanded(),
                  ),
                ]
              : []),
        ],
      ),
    );
  }
}

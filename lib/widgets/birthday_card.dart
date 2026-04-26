import 'package:flutter/material.dart';
import 'package:task_bell/localization/app_strings.dart';

class BirthdayCard extends StatefulWidget {
  final String name;
  final String? note;
  final VoidCallback onHide;
  final ValueChanged<String>? onNoteChanged;

  const BirthdayCard({
    super.key,
    required this.name,
    this.note,
    required this.onHide,
    this.onNoteChanged,
  });

  @override
  State<BirthdayCard> createState() => _BirthdayCardState();
}

class _BirthdayCardState extends State<BirthdayCard> {
  bool _isExpanded = false;
  late TextEditingController _noteController;
  late FocusNode _noteFocusNode;

  static final Color _cardColor = Colors.red.shade400;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.note ?? '');
    _noteFocusNode = FocusNode();
  }

  @override
  void didUpdateWidget(BirthdayCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.note != widget.note) {
      _noteController.text = widget.note ?? '';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    if (_isExpanded) {
      _noteFocusNode.unfocus();
      final text = _noteController.text.trim();
      if (text != (widget.note ?? '') && widget.onNoteChanged != null) {
        widget.onNoteChanged!(text);
      }
    }
    setState(() => _isExpanded = !_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _cardColor;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _toggleExpanded,
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.of(context).birthdayLabel(widget.name),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (!_isExpanded &&
                          widget.note != null &&
                          widget.note!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.note!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: widget.onHide,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
              focusNode: _noteFocusNode,
              maxLines: 4,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: AppStrings.of(context).taskNotesHint,
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
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
          ],
        ],
      ),
    );
  }
}

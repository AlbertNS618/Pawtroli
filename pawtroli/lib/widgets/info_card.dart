import 'package:flutter/material.dart';

class InfoCard extends StatefulWidget {
  final String label;
  final String value;
  final VoidCallback? onEdit;
  final ValueChanged<String>? onConfirm;
  const InfoCard({
    super.key,
    required this.label,
    required this.value,
    this.onEdit,
    this.onConfirm,
  });

  @override
  _InfoCardState createState() => _InfoCardState();
}

class _InfoCardState extends State<InfoCard> {
  bool _editing = false;
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(covariant InfoCard old) {
    super.didUpdateWidget(old);
    if (!_editing) _ctrl.text = widget.value;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    if (_editing) {
      widget.onConfirm?.call(_ctrl.text);
    } else {
      widget.onEdit?.call();
    }
    setState(() => _editing = !_editing);
  }

  @override
  Widget build(BuildContext context) {
    final editable = widget.onEdit != null || widget.onConfirm != null;

    return Container(
      // reduce overall padding
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: editable
        //––– EDITABLE MODE –––
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.label,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _editing ? Icons.check : Icons.edit,
                      size: 18,
                      color: Colors.grey[600]!.withOpacity(0.5),
                    ),
                    onPressed: _toggle,
                    padding: const EdgeInsets.all(2),
                    constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                  ), 
                ],
              ),
              // shrink gap
              const SizedBox(height: 2),
              _editing
                // cap TextField even further
                ? SizedBox(
                    height: 28,
                    child: TextField(
                      controller: _ctrl,
                      maxLines: 1,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  )
                : Text(
                    widget.value,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
            ],
          )
        //––– NON-EDITABLE MODE –––
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                widget.value,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ],
          ),
    );
  }
}
import 'package:flutter/material.dart';

class ListTileOrdersWidget extends StatefulWidget {
  final Map<String, String>? order;
  final VoidCallback? onTap;
  const ListTileOrdersWidget({required this.order, this.onTap, super.key});

  @override
  State<ListTileOrdersWidget> createState() => _ListTileOrdersWidgetState();
}

class _ListTileOrdersWidgetState extends State<ListTileOrdersWidget> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            'Pedido #${widget.order?['number'] ?? "0"}',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total: ${widget.order?['total'] ?? "0"}',
              style: TextStyle(color: colorScheme.primary, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              widget.order?['client'] ?? "",
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ],
        ),
        trailing: Text(
          widget.order?['date'] ?? "00/00/00",
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        onTap: widget.onTap,
      ),
    );
  }
}

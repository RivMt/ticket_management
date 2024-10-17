import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_management/models/ticket.dart';
import 'package:ticket_management/provider.dart' as provider;
import 'package:ticket_management/cards/ticket_card.dart';

final _tickets = Provider<List<Ticket>>((ref) {
  final data = ref.watch(provider.ticketsRaw);
  data.sort((a, b) {
    return a.issued.compareTo(b.issued) * -1;
  });
  return data;
});

class TicketList extends ConsumerStatefulWidget {
  const TicketList({
    super.key,
    this.onItemTap,
  });

  final Function(Ticket)? onItemTap;

  @override
  ConsumerState createState() => _TicketListState();
}

class _TicketListState extends ConsumerState<TicketList> {

  @override
  Widget build(BuildContext context) {
    final tickets = ref.watch(_tickets);
    if (tickets.isEmpty) {
      return const Icon(Icons.disabled_by_default_outlined);
    }
    return ListView.builder(
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final item = tickets[index];
        return TicketCard(
          ticket: item,
          onTap: (widget.onItemTap == null || item.canceled) ? null : () {
            widget.onItemTap!(item);
          },
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_management/models/schedule.dart';
import 'package:ticket_management/models/ticket.dart';
import 'package:ticket_management/provider.dart' as provider;
import 'package:ticket_management/cards/schedule_card.dart';

class ScheduleList extends ConsumerStatefulWidget {
  const ScheduleList({
    super.key,
    this.onItemTap,
  });

  final Function(Schedule, int)? onItemTap;

  @override
  ConsumerState createState() => _ScheduleListState();
}

class _ScheduleListState extends ConsumerState<ScheduleList> {

  @override
  Widget build(BuildContext context) {
    final schedules = ref.watch(provider.schedules);
    final tickets = ref.watch(provider.tickets);
    if (schedules.isEmpty) {
      return const Icon(Icons.disabled_visible_outlined);
    }
    return ListView.builder(
      itemCount: schedules.length,
      itemBuilder: (context, index) {
        final item = schedules[index];
        final left = provider.getLeftSeats(ref, item.uid);
        return ScheduleCard(
          datetime: item.datetime,
          maxSeats: item.seats,
          leftSeats: left,
          onTap: (widget.onItemTap == null || left <= 0) ? null : () {
            widget.onItemTap!(item, left);
          },
        );
      },
    );
  }
}
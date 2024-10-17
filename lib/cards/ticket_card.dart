import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_management/generated/locale_keys.g.dart';
import 'package:ticket_management/models/schedule.dart';
import 'package:ticket_management/models/ticket.dart';
import 'package:ticket_management/provider.dart' as provider;

class TicketCard extends ConsumerWidget {

  const TicketCard({
    super.key,
    required this.ticket,
    this.onTap,
    this.onLongPress,
  });

  final Ticket ticket;

  final Function()? onTap;

  final Function()? onLongPress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedule = ref.watch(provider.schedules).firstWhere((item) {
      return item.uid == ticket.scheduleUid;
    }, orElse: () => Schedule.unknown());
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ListTile(
          leading: Text(
            DateFormat(LocaleKeys.format_Hm.tr()).format(schedule.datetime),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          title: Text(DateFormat(LocaleKeys.format_MMMMd.tr()).format(schedule.datetime)),
          subtitle: Text(LocaleKeys.format_name.tr(args: [ticket.name])),
          trailing: SizedBox(
            width: 64,
            child: IndexedStack(
              index: ticket.canceled ? 1 : 0,
              children: [
                // 0: Valid
                Wrap(
                  children: [
                    Text(
                      ticket.seats.toString(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(LocaleKeys.format_seatUnit.tr(),),
                  ],
                ),
                // 1: Canceled
                Column(
                  children: [
                    const Icon(Icons.cancel_outlined, color: Colors.red,),
                    Text(
                      LocaleKeys.ticket_canceled.tr(),
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          onTap: onTap,
          onLongPress: onLongPress,
        ),
      ),
    );
  }
}
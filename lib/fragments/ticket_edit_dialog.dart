import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ticket_management/generated/locale_keys.g.dart';
import 'package:ticket_management/models/schedule.dart';
import 'package:ticket_management/models/ticket.dart';

class TicketEditDialog extends StatefulWidget {
  const TicketEditDialog({
    super.key,
    required this.schedule,
    this.ticket,
    required this.maxSeats,
  });

  final Schedule schedule;

  final Ticket? ticket;

  final int maxSeats;

  @override
  State createState() => _TicketEditDialogState();
}

class _TicketEditDialogState extends State<TicketEditDialog> {

  final TextEditingController seatsController = TextEditingController();

  final TextEditingController nameController = TextEditingController();

  late final Ticket editing;

  bool get removable => widget.ticket != null;

  void changeSeats(int value) {
    setState(() {
      seatsController.text = value.toString();
      editing.seats = value;
    });
  }

  void onSeatAddPressed() => changeSeats(math.min(editing.seats+1, widget.maxSeats));

  void onSeatRemovePressed() => changeSeats(math.max(editing.seats-1, Schedule.seatsMin));

  void onSeatsChanged(String string) {
    try {
      final value = int.parse(string);
      editing.seats = value;
    } catch (e, s) {
      debugPrint(e.toString());
      debugPrintStack(stackTrace: s);
    }
  }

  void onNameChanged(String string) => editing.name = string;

  void onConfirm() {
    final item = Ticket.fromMap(editing.map);
    Navigator.pop(context, item);
  }

  void onClose() {
    Navigator.pop(context);
  }

  void onCancel() {
    if (!removable) return;
    final item = Ticket.fromMap(widget.ticket!.map);
    item.canceled = true;
    Navigator.pop(context, item);
  }

  @override
  void initState() {
    super.initState();
    editing = Ticket.fromMap(widget.ticket?.map ?? {});
    editing.scheduleUid = widget.schedule.uid;
    seatsController.text = editing.seats.toString();
    nameController.text = editing.name;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.ticket?.code ?? LocaleKeys.dashboard_actIssueTicket.tr()),
      content: SingleChildScrollView(
        child: Column(
          children: [
            // Datetime
            Text(DateFormat(LocaleKeys.format_datetime.tr()).format(widget.schedule.datetime)),
            // Seats
            TextField(
              controller: seatsController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                prefix: IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: onSeatRemovePressed,
                ),
                suffix: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: onSeatAddPressed,
                ),
                labelText: LocaleKeys.ticket_seats.tr(),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                signed: false,
                decimal: false,
              ),
              inputFormatters: [
                FilteringTextInputFormatter(r"[0-9]{0,3}", allow: true),
              ],
              onChanged: onSeatsChanged,
            ),
            // Name
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: LocaleKeys.ticket_name.tr(),
              ),
              onChanged: onNameChanged,
            ),
          ],
        ),
      ),
      actions: [
        if (removable)
          TextButton(
            onPressed: onCancel,
            child: Text(
              LocaleKeys.action_cancel.tr(),
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        TextButton(
          onPressed: onClose,
          child: Text(LocaleKeys.action_close.tr()),
        ),
        TextButton(
          onPressed: onConfirm,
          child: Text(LocaleKeys.action_confirm.tr()),
        ),
      ],
    );
  }
}
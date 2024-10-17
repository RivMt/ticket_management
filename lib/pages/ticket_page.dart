import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_management/printer.dart';
import 'package:ticket_management/provider.dart' as provider;

class TicketPage extends ConsumerStatefulWidget {
  const TicketPage({
    super.key,
    required this.uid,
  });

  final String uid;

  @override
  ConsumerState createState() => _TicketPageState();
}

class _TicketPageState extends ConsumerState<TicketPage> {

  @override
  Widget build(BuildContext context) {
    final tickets = ref.watch(provider.ticketsRaw);
    final ticket = tickets.firstWhere((item) => item.uid == widget.uid);
    final schedule = provider.getSchedule(ref, ticket.scheduleUid);
    final future = Printer().previewTicket(schedule, ticket);
    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AspectRatio(
            aspectRatio: Printer().preferences.width / Printer().preferences.height,
            child: FutureBuilder(
              future: future,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text("");
                }
                return Container(
                  width: Printer().pixelWidth.toDouble(),
                  height: Printer().pixelHeight.toDouble(),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.black,
                      width: 8,
                    ),
                  ),
                  child: Image.memory(
                    snapshot.data!,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
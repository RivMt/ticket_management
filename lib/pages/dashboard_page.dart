import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_management/fragments/schedule_edit_dialog.dart';
import 'package:ticket_management/fragments/ticket_edit_dialog.dart';
import 'package:ticket_management/generated/locale_keys.g.dart';
import 'package:ticket_management/lists/schedule_list.dart';
import 'package:ticket_management/lists/ticket_list.dart';
import 'package:ticket_management/models/schedule.dart';
import 'package:ticket_management/models/ticket.dart';
import 'package:ticket_management/pages/printer_page.dart';
import 'package:ticket_management/pages/ticket_page.dart';
import 'package:ticket_management/provider.dart' as provider;

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({
    super.key,
  });

  @override
  ConsumerState createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> with TickerProviderStateMixin {

  static const indexSchedule = 0;

  static const indexTicket = 1;

  late final TabController tabController;

  final PageController pageController = PageController(
    initialPage: indexSchedule,
  );

  int get currentPage => tabController.index;

  Future<Schedule?> showScheduleEditDialog([Schedule? schedule]) async {
    return await showDialog<Schedule>(
        context: context,
        builder: (context) {
          return ScheduleEditDialog(
            schedule: schedule,
          );
        }
    );
  }

  Future<Ticket?> showTicketEditDialog(Schedule schedule, int maxSeats, [Ticket? ticket]) async {
    return await showDialog<Ticket>(
        context: context,
        builder: (context) {
          return TicketEditDialog(
            schedule: schedule,
            ticket: ticket,
            maxSeats: maxSeats,
          );
        }
    );
  }

  void onPrinterPressed() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const PrinterPage();
    }));
  }

  void onActionPressed() async {
    final user = ref.watch(provider.user);
    if (user.isEditor) {
      // Logout
      await provider.signOut(ref);
    } else {
      // Login
      await provider.signIn(ref);
    }
  }

  void onSchedulePressed(Schedule schedule, int left) async {
    final result = await showTicketEditDialog(schedule, left);
    if (result == null) return;
    // Issue ticket
    provider.setTicket(ref, result);
  }

  void onScheduleLongPressed(Schedule schedule) async {
    final result = await showScheduleEditDialog(schedule);
    if (result == null) {
      // Remove
      provider.deleteSchedule(ref, schedule.uid);
      return;
    }
    // Edit
    provider.updateSchedule(ref, schedule);
  }

  void onTicketPressed(Ticket ticket) async {
    final schedule = provider.getSchedule(ref, ticket.scheduleUid);
    final left = provider.getLeftSeats(ref, schedule.uid);
    final result = await showTicketEditDialog(schedule, left + ticket.seats, ticket);
    if (result == null) return;
    // Update ticket
    provider.updateTicket(ref, result);
  }

  void onTicketLongPressed(Ticket ticket) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TicketPage(
        uid: ticket.uid,
      );
    }));
  }

  /// On tab page changed
  void onTabChanged(int index) {
    pageController.animateToPage(
      index,
      duration: tabController.animationDuration,
      curve: Curves.ease,
    );
  }

  void onFabPressed() async {
    if (currentPage == indexSchedule) {
      // Schedule
      final result = await showScheduleEditDialog();
      if (result == null) {
        return;
      }
      // Create
      provider.setSchedule(ref, result);
    } else {
    }
  }

  @override
  void initState() {
    super.initState();
    // Tab controller
    tabController = TabController(
      length: 2,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(provider.user);
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.dashboard_title.tr()),
        actions: [
          if (user.isEditor)
            IconButton(
              icon: const Icon(Icons.print_outlined),
              onPressed: onPrinterPressed,
            ),
          IconButton(
            icon: user.isEditor
                ? const Icon(Icons.verified_sharp)
                : const Icon(Icons.account_circle_outlined),
            onPressed: onActionPressed,
          )
        ],
        bottom: TabBar(
          controller: tabController,
          tabs: [
            Tab(text: LocaleKeys.dashboard_tabSchedules.tr(),),
            Tab(text: LocaleKeys.dashboard_tabTickets.tr(),),
          ],
          onTap: onTabChanged,
        ),
      ),
      body: IndexedStack(
        index: user.isEditor ? 1 : 0,
        children: [
          // 0: Need login
          Text(LocaleKeys.dashboard_msgNeedLogin.tr()),
          // 1: Tools
          PageView(
            controller: pageController,
            children: [
              // 0: Schedules
              ScheduleList(
                onItemTap: onSchedulePressed,
              ),
              // 1: Tickets
              TicketList(
                onItemTap: onTicketPressed,
                onItemLongPress: onTicketLongPressed,
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: user.isEditor ? FloatingActionButton(
        onPressed: onFabPressed,
        child: const Icon(Icons.add),
      ) : null,
    );
  }
}
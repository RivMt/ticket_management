import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_management/firebase.dart';
import 'package:ticket_management/models/printer_preferences.dart';
import 'package:ticket_management/models/schedule.dart';
import 'package:ticket_management/models/ticket.dart';
import 'package:ticket_management/models/state.dart';
import 'package:ticket_management/models/user.dart';
import 'package:ticket_management/printer.dart';

void refresh(WidgetRef ref) {
  final sec = ref.watch(section);
  final nsp = ref.watch(namespace);
  ref.watch(ticketsRaw.notifier).get(sec, nsp);
  ref.watch(schedulesRaw.notifier).get(sec, nsp);
  ref.watch(printer.notifier).get(sec, nsp, PrinterPreferences.baseUid);
  Printer().set(ref.watch(printer));
}

void clear(WidgetRef ref) {
  ref.watch(ticketsRaw.notifier).clear();
  ref.watch(schedulesRaw.notifier).clear();
}

int getLeftSeats(WidgetRef ref, String uid) {
  final schedule = getSchedule(ref, uid);
  final tks = ref.watch(tickets);
  final reserved = tks[uid]!.fold<int>(0, (prev, t) {
    return prev + t.seats * (t.canceled ? 0 : 1);
  });
  return schedule.seats - reserved;
}

final section = StateNotifierProvider<ObjectState<String>, String>((ref) {
  return ObjectState<String>(ref, FirebaseHelper.sectionPlanetarium);
});

final namespace = StateNotifierProvider<ObjectState<String>, String>((ref) {
  return ObjectState<String>(ref, kDebugMode
      ? FirebaseHelper.namespaceTest
      : FirebaseHelper.namespaceProduction
  );
});

final ticketsRaw = StateNotifierProvider<ModelsState<Ticket>, List<Ticket>>((ref) {
  return ModelsState<Ticket>(ref, (map) => Ticket.fromMap(map));
});

final tickets = Provider<Map<String, List<Ticket>>>((ref) {
  final Map<String, List<Ticket>> map = {};
  final scs = ref.watch(schedules);
  for(Schedule s in scs) {
    map[s.uid] = <Ticket>[];
  }
  final tks = ref.watch(ticketsRaw);
  for(Ticket item in tks) {
    map[item.scheduleUid]!.add(item);
  }
  return map;
});

void setTicket(WidgetRef ref, Ticket ticket) {
  // TODO: Verify left seats
  ref.watch(ticketsRaw.notifier).set(
      ref.watch(section),
      ref.watch(namespace),
      ticket
  );
}

void updateTicket(WidgetRef ref, Ticket ticket) {
  // TODO: Verify left seats
  ref.watch(ticketsRaw.notifier).update(
      ref.watch(section),
      ref.watch(namespace),
      ticket
  );
}

void deleteTicket(WidgetRef ref, String uid) {
  ref.watch(ticketsRaw.notifier).delete(
      ref.watch(section),
      ref.watch(namespace),
      uid,
  );
}

final schedulesRaw = StateNotifierProvider<ModelsState<Schedule>, List<Schedule>>((ref) {
  return ModelsState<Schedule>(ref, (map) => Schedule.fromMap(map));
});

final schedules = Provider<List<Schedule>>((ref) {
  final data = ref.watch(schedulesRaw);
  data.sort((a, b) {
    return a.datetime.compareTo(b.datetime);
  });
  return data;
});

Schedule getSchedule(WidgetRef ref, String uid) {
  final scs = ref.watch(schedules);
  return scs.firstWhere((item) => item.uid == uid);
}

void setSchedule(WidgetRef ref, Schedule schedule) {
  ref.watch(schedulesRaw.notifier).set(
      ref.watch(section),
      ref.watch(namespace),
      schedule
  );
}

void updateSchedule(WidgetRef ref, Schedule schedule) {
  ref.watch(schedulesRaw.notifier).update(
      ref.watch(section),
      ref.watch(namespace),
      schedule
  );
}

void deleteSchedule(WidgetRef ref, String uid) {
  ref.watch(schedulesRaw.notifier).delete(
    ref.watch(section),
    ref.watch(namespace),
    uid,
  );
}

final user = StateNotifierProvider<ModelState<User>, User>((ref) {
  return ModelState<User>(ref, User.anonymous(), (map) => User.fromMap(map));
});

Future<bool> signIn(WidgetRef ref) async {
  final auth.UserCredential credential = await FirebaseHelper().signInWithGoogle();
  if (credential.user == null) {
    return false;
  }
  final User data = User.fromFirebase(credential.user!);
  ref.watch(user.notifier).update(
      FirebaseHelper.sectionGlobal,
      FirebaseHelper.namespaceIam,
      data
  );
  refresh(ref);
  return true;
}

Future<void> signOut(WidgetRef ref) async  {
  ref.watch(user.notifier).clear();
  clear(ref);
}

void signAnonymous(WidgetRef ref) {
  final User data = User.anonymous();
  ref.watch(user.notifier).inject(data);
}

final printer = StateNotifierProvider<ModelState<PrinterPreferences>, PrinterPreferences>((ref) {
  return ModelState<PrinterPreferences>(ref, PrinterPreferences.simple(), (map) => PrinterPreferences.fromMap(map));
});

void setPrinter(WidgetRef ref, PrinterPreferences pref) {
  ref.watch(printer.notifier).set(
    FirebaseHelper.sectionGlobal,
    FirebaseHelper.namespaceIam,
    pref,
  );
  Printer().set(pref);
}
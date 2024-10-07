import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_management/firebase.dart';
import 'package:ticket_management/models/schedule.dart';
import 'package:ticket_management/models/ticket.dart';
import 'package:ticket_management/models/state.dart';
import 'package:ticket_management/models/user.dart';

final tickets = StateNotifierProvider<ModelsState<Ticket>, List<Ticket>>((ref) {
  return ModelsState<Ticket>(ref, (map) => Ticket.fromMap(map));
});

final schedules = StateNotifierProvider<ModelsState<Schedule>, List<Schedule>>((ref) {
  return ModelsState<Schedule>(ref, (map) => Schedule.fromMap(map));
});

final user = StateNotifierProvider<ModelState<User>, User>((ref) {
  return ModelState<User>(ref, User(), (map) => User.fromMap(map));
});

void refresh(WidgetRef ref, String section, String namespace) {
  ref.watch(tickets.notifier).get(section, namespace);
  ref.watch(schedules.notifier).get(section, namespace);
}

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
  return true;
}

void signAnonymous(WidgetRef ref) {
  final User data = User.anonymous();
  ref.watch(user.notifier).inject(data);
}
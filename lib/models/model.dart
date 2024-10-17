import 'package:flutter/material.dart';
import 'package:ticket_management/models/printer_preferences.dart';
import 'package:ticket_management/models/schedule.dart';
import 'package:ticket_management/models/ticket.dart';
import 'package:ticket_management/models/user.dart';
import 'package:uuid/uuid.dart';

class Model {

  static const String keyUid = "uid";

  static String getParam<T>() {
    if (T == Model) {
      return "models";
    } else if (T == Ticket) {
      return "tickets";
    } else if (T == Schedule) {
      return "schedules";
    } else if (T == User) {
      return "users";
    } else if (T == PrinterPreferences) {
      return "printers";
    }
    throw UnimplementedError();
  }

  Model();

  Model.fromMap(Map<String, dynamic> map) {
    _map = map;
  }

  Map<String, dynamic> get map => _map;

  Map<String, dynamic> _map = {};

  bool get isValid => map.length > 1;

  String get code => throw UnimplementedError();

  String get uid {
    final value = getValue<String>(keyUid);
    if (value == null) {
      final uid = const Uuid().v4();
      setValue<String>(keyUid, uid);
      return uid;
    }
    return value;
  }

  T? getValue<T>(String key) {
    if (!map.containsKey(key)) {
      return null;
    }
    return map[key]!;
  }

  DateTime? getDateTime(String key) {
    final raw = getValue<String>(key);
    if (raw == null) {
      return null;
    }
    return DateTime.parse(raw).toLocal();
  }

  void setValue<T>(String key, T value) {
    map[key] = value;
  }

  void setDateTime(String key, DateTime value) {
    setValue<String>(key, value.toUtc().toIso8601String());
  }

  void setDate(String key, DateTime date) {
    final value = getDateTime(key);
    if (value == null) return;
    setDateTime(key, value.copyWith(
      year: date.year,
      month: date.month,
      day: date.day,
    ));
  }

  void setTime(String key, TimeOfDay tod) {
    final value = getDateTime(key);
    if (value == null) return;
    setDateTime(key, value.copyWith(
      hour: tod.hour,
      minute: tod.minute,
    ));
  }

}
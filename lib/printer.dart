import 'dart:ui';
//@ignore
import 'dart:html';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ticket_management/generated/locale_keys.g.dart';
import 'package:ticket_management/models/printer_preferences.dart';
import 'package:ticket_management/models/schedule.dart';
import 'package:ticket_management/models/ticket.dart';

class Printer {

  static final Printer _instance = Printer._();

  factory Printer() => _instance;

  Printer._();

  int get pixelWidth => (preferences.width / 25.4 * preferences.dpi).toInt();

  int get pixelHeight => (preferences.height / 25.4 * preferences.dpi).toInt();

  PrinterPreferences preferences = PrinterPreferences.simple();

  void set(PrinterPreferences pref) {
    preferences = PrinterPreferences.fromMap(pref.map);
  }

  Future<Image> generateTicket(Schedule schedule, Ticket ticket) async {
    final builder = ParagraphBuilder(ParagraphStyle(fontStyle: FontStyle.normal));
    // Size
    final w = pixelWidth;
    final h = pixelHeight;
    final head = 28.0;
    final body = 14.0;
    // Header
    builder.pushStyle(TextStyle(fontSize: head));
    builder.addText("${preferences.title}\n");
    builder.pushStyle(TextStyle(fontSize: body));
    builder.addText("${preferences.subtitle}\n");
    builder.addText("\n");
    // Content
    builder.pushStyle(TextStyle(fontSize: body));
    builder.addText("${DateFormat(LocaleKeys.format_datetime.tr()).format(schedule.datetime)}\n");
    builder.addText("${ticket.uid}\n");
    builder.addText("\n");
    builder.addText("${ticket.name}\n");
    builder.addText("${ticket.seats} ${LocaleKeys.format_seatUnit.tr()}\n");
    builder.addText(List.generate((w/body).toInt(), (_) => "-").join(""));
    // TODO: Append ticket status
    // Convert
    final paragraph = builder.build();
    paragraph.layout(ParagraphConstraints(width: w.toDouble(),));
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawParagraph(paragraph, Offset.zero);
    final picture = recorder.endRecording();
    return await picture.toImage(w, h);
  }

  Future<Uint8List> previewTicket(Schedule schedule, Ticket ticket) async {
    final image = await generateTicket(schedule, ticket);
    final bytes = await image.toByteData(format: ImageByteFormat.png);
    if (bytes == null) {
      throw UnsupportedError("Empty bytes array");
    }
    return Uint8List.view(bytes.buffer);
  }

  Future<bool> printTicket(Schedule schedule, Ticket ticket) async {
    final response = await requestPrint(await generateTicket(schedule, ticket));
    if (response.statusCode != 200) {
      return false;
    }
    return true;
  }

  Future<http.Response> requestPrint(Image image) async {
    final blob = Blob([
      "P4\n${preferences.width} ${preferences.height}\n",
      await image.toByteData(format: ImageByteFormat.rawUnmodified),
    ]);
    return await http.post(Uri(host: preferences.host), body: blob);
  }

}
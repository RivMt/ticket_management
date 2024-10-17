import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ticket_management/generated/locale_keys.g.dart';
import 'package:ticket_management/models/printer_preferences.dart';
import 'package:ticket_management/provider.dart' as provider;

class PrinterPage extends ConsumerStatefulWidget {
  const PrinterPage({
    super.key,
  });

  @override
  ConsumerState createState() => _PrinterPageState();
}

class _PrinterPageState extends ConsumerState<PrinterPage> {

  final TextEditingController hostController = TextEditingController();

  final TextEditingController widthController = TextEditingController();

  final TextEditingController heightController = TextEditingController();

  final TextEditingController dpiController = TextEditingController();

  final TextEditingController titleController = TextEditingController();

  final TextEditingController subtitleController = TextEditingController();

  void update(PrinterPreferences pref) {
    provider.setPrinter(ref, pref);
  }

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(provider.printer);
    hostController.text = preferences.host;
    widthController.text = preferences.width.toString();
    heightController.text = preferences.height.toString();
    dpiController.text = preferences.dpi.toString();
    titleController.text = preferences.title;
    subtitleController.text = preferences.subtitle;
    return Scaffold(
      appBar: AppBar(
        title: Text(LocaleKeys.printer_title.tr()),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Host
              TextField(
                controller: hostController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: LocaleKeys.printer_hint_host.tr(),
                ),
                onChanged: (text) {
                  preferences.host = text;
                  update(preferences);
                },
              ),
              // Size
              // Width
              TextField(
                controller: widthController,
                keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
                decoration: InputDecoration(
                  hintText: LocaleKeys.printer_hint_width.tr(),
                ),
                onChanged: (text) {
                  try {
                    preferences.width = int.parse(text);
                    update(preferences);
                  } catch (e, s) {
                    debugPrint(e.toString());
                    debugPrintStack(stackTrace: s);
                  }
                },
              ),
              // Height
              TextField(
                controller: heightController,
                keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
                decoration: InputDecoration(
                  hintText: LocaleKeys.printer_hint_height.tr(),
                ),
                onChanged: (text) {
                  try {
                    preferences.height = int.parse(text);
                    update(preferences);
                  } catch (e, s) {
                    debugPrint(e.toString());
                    debugPrintStack(stackTrace: s);
                  }
                },
              ),
              // DPI
              TextField(
                controller: dpiController,
                keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
                decoration: InputDecoration(
                  hintText: LocaleKeys.printer_hint_dpi.tr(),
                ),
                onChanged: (text) {
                  try {
                    preferences.dpi = int.parse(text);
                    update(preferences);
                  } catch (e, s) {
                    debugPrint(e.toString());
                    debugPrintStack(stackTrace: s);
                  }
                },
              ),
              // Title
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: LocaleKeys.printer_hint_title.tr(),
                ),
                onChanged: (text) {
                  preferences.title = text;
                  update(preferences);
                },
              ),
              // Subtitle
              TextField(
                controller: subtitleController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  hintText: LocaleKeys.printer_hint_subtitle.tr(),
                ),
                onChanged: (text) {
                  preferences.subtitle = text;
                  update(preferences);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
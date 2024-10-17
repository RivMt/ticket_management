import 'package:ticket_management/models/model.dart';

class PrinterPreferences extends Model {

  static const String baseUid = "printer";

  static const String keyHost = "host";

  static const String keyWidth = "width";

  static const String keyHeight = "height";

  static const String keyDpi = "dpi";

  static const String keyTitle = "title";

  static const String keySubtitle = "subtitle";

  PrinterPreferences({
    required String host,
    required int width,
    required int height,
    required int dpi,
    required String title,
    required String subtitle,
  }) : super() {
    this.host = host;
    this.width = width;
    this.height = height;
    this.dpi = dpi;
    this.title = title;
    this.subtitle = subtitle;
  }

  PrinterPreferences.simple() {
    host = "localhost";
    width = 58;
    height = 30;
    dpi = 96;
    title = "Printer";
    subtitle = "Simple mode";
  }

  PrinterPreferences.fromMap(super.map) : super.fromMap();

  @override
  String get uid => baseUid;

  @override
  String get code => uid;

  String get host => getValue<String>(keyHost) ?? "";

  set host(String value) => setValue(keyHost, value);

  int get width => getValue<int>(keyWidth) ?? -1;

  set width(int value) => setValue(keyWidth, value);

  int get height => getValue<int>(keyHeight) ?? -1;

  set height(int value) => setValue(keyHeight, value);

  int get dpi => getValue<int>(keyDpi) ?? 96;

  set dpi(int value) => setValue(keyDpi, value);

  String get title => getValue<String>(keyTitle) ?? "";

  set title(String value) => setValue<String>(keyTitle, value);

  String get subtitle => getValue<String>(keySubtitle) ?? "";

  set subtitle(String value) => setValue<String>(keySubtitle, value);

}
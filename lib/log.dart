import 'package:shared_preferences/shared_preferences.dart';

class Log {
  create(String value) async {
    List<String>? list = [];
    final SharedPreferences sp = await SharedPreferences.getInstance();
    sp.reload();
    list = sp.getStringList('log');
    list!.add(value);
    sp.setStringList('log', list);
  }
}

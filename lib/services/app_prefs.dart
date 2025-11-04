import 'package:shared_preferences/shared_preferences.dart';

class PrefKeys {
  static const defaultCourtName       = 'defaultCourtName';
  static const defaultCourtRate       = 'defaultCourtRate';
  static const defaultShuttlePrice    = 'defaultShuttlePrice';
  static const defaultDivideEqually   = 'defaultDivideEqually';
}

class AppPrefs {
  /// Save all defaults in one go
  static Future<void> saveDefaults({
    required String courtName,
    required double courtRate,
    required double shuttlecockPrice,
    required bool divideEqually,
  }) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(PrefKeys.defaultCourtName, courtName);
    await p.setDouble(PrefKeys.defaultCourtRate, courtRate);
    await p.setDouble(PrefKeys.defaultShuttlePrice, shuttlecockPrice);
    await p.setBool(PrefKeys.defaultDivideEqually, divideEqually);
  }

  /// Read defaults with sensible fallbacks
  static Future<({String courtName, double courtRate, double shuttlecockPrice, bool divideEqually})>
  loadDefaults() async {
    final p = await SharedPreferences.getInstance();
    final name   = p.getString(PrefKeys.defaultCourtName)     ?? 'Default Court';
    final rate   = p.getDouble(PrefKeys.defaultCourtRate)     ?? 500.0;
    final shutt  = p.getDouble(PrefKeys.defaultShuttlePrice)  ?? 50.0;
    final split  = p.getBool(PrefKeys.defaultDivideEqually)   ?? true;
    return (courtName: name, courtRate: rate, shuttlecockPrice: shutt, divideEqually: split);
  }
}

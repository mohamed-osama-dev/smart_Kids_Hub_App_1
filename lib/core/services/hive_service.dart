import 'package:hive_flutter/hive_flutter.dart';

import '../../features/auth/domain/models/child_profile.dart';

class HiveService {
  static const String childrenBoxName = 'children_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(ChildProfileAdapter());
    }
    await Hive.openBox<ChildProfile>(childrenBoxName);
  }

  static Box<ChildProfile> get childrenBox =>
      Hive.box<ChildProfile>(childrenBoxName);

  static Future<void> saveChildren(List<ChildProfile> children) async {
    await childrenBox.clear();
    final entries = <dynamic, ChildProfile>{
      for (final child in children) child.id: child,
    };
    await childrenBox.putAll(entries);
  }

  static List<ChildProfile> getCachedChildren() {
    return childrenBox.values.toList();
  }

  static Future<void> clearChildren() async {
    await childrenBox.clear();
  }
}


import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlleaf/features/modules/module_repository.dart';

/// Validates the actual bundled modules.json ships correctly (content testing,
/// §21). Loads the real asset so a typo in the content file fails CI.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled modules.json loads, is ordered, and has unique ids', () async {
    final repo = ModuleRepository(loader: rootBundle.loadString);
    final modules = await repo.loadModules();

    expect(modules.length, 10);

    final ids = modules.map((m) => m.id).toSet();
    expect(ids.length, modules.length, reason: 'module ids must be unique');

    final orders = modules.map((m) => m.order).toList();
    final sorted = [...orders]..sort();
    expect(orders, sorted, reason: 'modules must be returned in order');

    for (final m in modules) {
      expect(m.title.trim(), isNotEmpty);
      expect(m.summary.trim(), isNotEmpty);
    }
  });
}

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/features/tools/data/dice_model_licenses.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the licence page lists YOLOX and the dice dataset', () async {
    registerDiceModelLicenses();

    final entries = await LicenseRegistry.licenses.toList();
    final packages = {for (final entry in entries) ...entry.packages};
    expect(packages, containsAll(['YOLOX', 'D6DiceSideRecognition']));

    final yolox = entries.firstWhere((e) => e.packages.contains('YOLOX'));
    final text = yolox.paragraphs.map((p) => p.text).join('\n');
    expect(text, contains('Apache License'));
    expect(text, contains('Megvii'));

    final dataset = entries.firstWhere(
      (e) => e.packages.contains('D6DiceSideRecognition'),
    );
    final attribution = dataset.paragraphs.map((p) => p.text).join('\n');
    expect(attribution, contains('dicemaschine'));
    expect(attribution, contains('CC BY 4.0'));
  });
}

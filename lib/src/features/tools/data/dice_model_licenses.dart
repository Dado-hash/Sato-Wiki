import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Asset with the Apache-2.0 license of YOLOX, the base of the dice detector.
const yoloxLicenseAsset = 'assets/models/yolox_license.txt';

/// Attribution the CC BY 4.0 dataset of the dice detector asks for.
const diceDatasetAttribution =
    'The dice detector (assets/models/dice_detector.tflite) is trained on '
    'D6DiceSideRecognition v2 by dicemaschine, Roboflow Universe '
    '(https://universe.roboflow.com/dicemaschine/d6dicesiderecognition), '
    'licensed under CC BY 4.0 (https://creativecommons.org/licenses/by/4.0/). '
    'Changes: resized, split by source photo, converted to COCO layout and '
    'combined with synthetic scenes. The model weights are shared under the '
    'same license.';

/// Adds the dice detector's licenses to the app's licence page: YOLOX
/// (Apache-2.0) and the training dataset (CC BY 4.0).
void registerDiceModelLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(const [
      'YOLOX',
    ], await rootBundle.loadString(yoloxLicenseAsset));
    yield const LicenseEntryWithLineBreaks([
      'D6DiceSideRecognition',
    ], diceDatasetAttribution);
  });
}

# Dice to Seed

Dice to Seed (Dadi → Seed in the app) is an offline sandbox in the Code tools. You roll real six-sided dice, the phone reads them, and the app turns the rolls into a BIP39 seed of 12 or 24 English words. Everything stays in memory and is erased when you leave.

**Status.** The sandbox, the BIP39 encoding, the keypad, the correction flow and the detector code are built and tested, with unit tests and widget tests for the sandbox screens. The seed encoding is compatible with SeedSigner and Coldcard: the app reproduces their published dice vectors. The detector model is bundled as a **beta**: on the held-out test split it finds 98.5% of the dice but reads the right face on 77.4% of them, below the 0.99 gate, so every camera reading must be checked against the dice. A better model and the physical device checks are still open (see `docs/roadmap.md`, section 6). A cross-check on a physical SeedSigner or Coldcard is a nice-to-have, not a blocker.

The app is not a reference implementation of a wallet. Treat the seed as you would any seed you write by hand: check it on a second device before you put funds on it.

## Method

### From rolls to entropy

The method is SeedSigner's (`generate_mnemonic_from_dice`), and the app matches SeedSigner's test vectors and the Coldcard sample in SeedSigner's tests:

1. Roll one die per roll and write the values in order. A 24-word seed needs **99 rolls**; a 12-word seed needs **50 rolls**.
2. Turn the rolls into one ASCII string of digits `1` to `6`, with no separators.
3. `entropy = SHA-256(that ASCII string)`. For 24 words all 32 bytes are used; for 12 words the first 16 bytes are used.
4. BIP39: the checksum is the first `ENT / 32` bits of `SHA-256(entropy)` (8 bits for 24 words, 4 bits for 12). The entropy plus checksum is split into 11-bit groups (24 groups or 12 groups). Each group is an index from 0 to 2047 into the English wordlist.

Each roll carries log2(6), about 2.58 bits. 99 rolls give about 255.9 bits, so a 24-word seed is capped at 256 bits of entropy; 50 rolls give about 129.2 bits, capped at 128.

The app uses only the English BIP39 wordlist. It does not add a BIP39 passphrase.

### Ordering by position

Inside one throw the app orders the dice by position, never by value: rows from top to bottom, and left to right inside a row. A die joins a row when its centre is within half the mean die height of that row. Sorting by value would discard information about the order of the rolls, so the app does not do it. The keypad keeps the order you type.

The rolls grid on the sandbox screen shows the order that was recorded. If you check the seed on another device, enter the rolls in that order.

### Test vectors

The dice vectors below are SeedSigner's own test vectors from `tests/test_mnemonic_generation.py` (`test_known_dice_rolls`, `test_50_dice_rolls`) and the Coldcard sample (`test_verify_against_coldcard_sample`, the `123456` roll string). The app reproduces all seven exactly. The vectors are in `test/tools_bip39_test.dart` and `test/tools_dice_entropy_test.dart`. They were also recomputed with a short standard-library Python script (`hashlib` and the official English wordlist, SHA-256 `2f5eed53a4727b4bf8880d8f3f199efc90e58503646d9ff8eff3a2ed3b24dbda`), which is not part of the repository.

| Input | Words |
| --- | --- |
| 32-byte entropy = SHA-256 of the ASCII `123456` (checks the BIP39 layer only) | `mirror reject rookie talk pudding throw happy era myth already payment own sentence push head sting video explain letter bomb casual hotel rather garment` |
| 99 rolls: `5`, then 44 × `2`, then 54 × `5` | `resource timber firm banner horror pupil frozen main pear direct pioneer broken grid core insane begin sister pony end debate task silk empty curious` |
| 99 rolls: 45 × `2`, then 54 × `5` | `garden uphold level clog sword globe armor issue two cute scorpion improve verb artwork blind tail raw butter combine move produce foil feature wave` |
| 99 rolls: 45 × `2`, then 53 × `5`, then `6` | `lizard broken love tired depend eyebrow excess lonely advance father various cram ignore panic feed plunge miss regret boring unique galaxy fan detail fly` |
| 50 rolls: `123456` × 8, then `12` | `unveil nice picture region tragic fault cream strike tourist control recipe tourist` |
| 50 rolls: 50 × `1` | `diet glad hat rural panther lawsuit act drop gallery urge where fit` |
| 50 rolls: 50 × `6` | `senior morning song proud recycle toy search apple trigger lend vibrant arrest` |
| 16 zero bytes (BIP39 layer) | `abandon` × 11, then `about` |
| 32 bytes of `0x7f` (BIP39 layer) | `legal winner thank year wave sausage worth useful` × 3, then `legal winner thank year wave sausage worth title`; checksum bits `00010111` |

A minimal version of the computation, for checking by hand:

```python
import hashlib

words = open("english.txt").read().split()  # official BIP39 English list, 2048 lines

def mnemonic(entropy: bytes) -> str:
    cs = len(entropy) * 8 // 32
    bits = bin(int.from_bytes(entropy, "big"))[2:].zfill(len(entropy) * 8)
    bits += bin(hashlib.sha256(entropy).digest()[0])[2:].zfill(8)[:cs]
    return " ".join(words[int(bits[i:i + 11], 2)] for i in range(0, len(bits), 11))

def dice_seed(rolls: str, n_words: int) -> str:
    nbytes = {12: 16, 24: 32}[n_words]
    return mnemonic(hashlib.sha256(rolls.encode("ascii")).digest()[:nbytes])

print(dice_seed("1" * 50, 12))
```

### Cross-check on a second device

Do this before you use a seed for real funds. Use a device that is not the phone running SatoWiki, for example a SeedSigner or a Coldcard, with its dice-roll entry:

1. Write down the rolls in the order shown in the sandbox.
2. Enter the same rolls on the other device, with the same seed length.
3. Compare the words. If they match, the roll method and the BIP39 encoding agree.

Compatibility with SeedSigner and Coldcard is confirmed by the vectors above. A check on a physical device is still worth doing as a nice-to-have, but it is not a blocker.

### Statistics

The sandbox counts how often each face came up. With 30 or more rolls it runs a chi-square test against a fair die. If the statistic is above 20.515 (p below 0.001, 5 degrees of freedom), the sandbox shows a warning: "Unusual distribution: check the dice and the readings". The warning does not block the session. It catches dice that are clearly unfair or readings that are clearly wrong, not small biases.

## Recognition (camera)

The camera is an alternative to typing the rolls. It works only in the sandbox, on the device, offline.

- **Model:** YOLOX-Nano (Megvii, Apache-2.0), six classes labelled `1` to `6`. It is trained with the scripts in `tool/dice_model/`, and its card is `assets/models/dice_detector.md`. The weights are `assets/models/dice_detector.tflite` (float32, 3.6 MiB). It is trained on a public dice dataset plus synthetic scenes rendered in Blender.
- **Input:** one 640 × 640 BGR tensor (the app reads the size from the model), raw 0 to 255, letterboxed (the image keeps its aspect ratio, is placed top-left, and the rest is filled with 114).
- **Output:** `[1, 8400, 11]`, decoded by the export. Each row is `cx, cy, w, h`, objectness, and six class probabilities.
- **Decoding in the app:** score = objectness × best class probability. Rows below 0.3 are dropped. Overlapping boxes are removed with class-agnostic NMS at IoU 0.45, keeping at most 10 detections.
- **Frames:** the back camera at medium resolution, through `startImageStream` only. At most one frame every 200 ms is processed. Android frames are converted from YUV420 and rotated by the sensor orientation; iOS frames are BGRA and are not rotated. Conversion and inference run in isolates.
- **Auto-capture:** a throw is read when the same dice stay still for 4 consecutive frames (about 0.8 s). "Still" means the same count, the same values, and centres moving no more than 4% of the frame. Dice below 0.5 confidence are ignored. A frame with no dice, or with more than 5, resets the count. A still scene is recorded once: the dice must leave the frame or move before the next throw is read.
- **Review:** if any die of the throw has confidence below 0.85, the throw is not recorded. A correction sheet opens with the values and their confidence, and you tap a die to change it. The Confirm throw button and the keypad are always available.
- **Frames are not kept.** Nothing is saved, logged or sent, and the app never calls `takePicture`.

Accuracy on the held-out test split of the public dataset (95 images, 731 dice): 99.7% of the dice found, value accuracy 0.959. On 17 photos of the maintainer's own throws (85 dice): every die found, 77.6% read right, 5 throws of 17 fully right; most errors are a 2 read as a 3. The release gate is at least 0.99 value accuracy, measured last on the maintainer's own photos, which are never used for training (`tool/dice_model/evaluate.py`, `tool/dice_model/evaluate_throws.py`).

## Threat model and safeguards

The threats the sandbox is built against:

- someone takes a screenshot or a screen recording, or mirrors the screen;
- the session is visible in the app switcher or in the recent apps preview;
- the words end up in the keyboard's learning, the clipboard, or a text selection;
- the session is stored on disk or in logs;
- the phone makes a network call with the session data;
- someone nearby reads the words off the screen.

### Safeguards by platform

| Safeguard | Android | iOS | Shared Dart code |
| --- | --- | --- | --- |
| Screenshot | `FLAG_SECURE` blocks the capture. From Android 14 (API 34), `ScreenCaptureCallback` reports a screenshot, and the session is wiped and a dialog shows. On Android 13 and older the screenshot is blocked but not detected. | The sensitive area is drawn inside a secure text layer, so it is blank in a capture. `userDidTakeScreenshotNotification` reports the screenshot, and the session is wiped. The screenshot itself is not prevented. | On `screenshotTaken`: wipe, dialog, leave the sandbox. |
| Screen recording and mirroring | `FLAG_SECURE` blocks recorded and mirrored output. No event is sent. | `UIScreen.capturedDidChange` reports capture. The screen is covered until capture stops. | Cover the screen on `captureStarted` (iOS only). |
| App switcher and recent apps | `FLAG_SECURE` blanks the preview. | The app is covered as soon as it becomes inactive. | Cover on `inactive`; wipe on `paused`, `hidden` and `detached`. |
| Network | Warning when a network with internet access is active. Connectivity callbacks update it. | Warning from `NWPathMonitor`. | The sandbox starts no request. The warning does not block the session. |
| Keyboard, clipboard, selection | Not applicable | Not applicable | No `TextField`, no `SelectableText`, no `SelectionArea`, no copy or share action. |
| Storage and logs | None | None | Nothing is written; no `shared_preferences`, files, `print`, `debugPrint` or analytics. |
| Words hidden | Same | Same | Words are not built while hidden. The reveal control is a press-and-hold, or a toggle when a screen reader is on. The words card and the bits card share one reveal state: holding either one reveals words, bits and math values together, and releasing hides all of them. |
| Screen awake | `FLAG_KEEP_SCREEN_ON` | `isIdleTimerDisabled` | Set on enter, cleared on exit. |

The Dart side also keeps the state in typed buffers: rolls in `Uint8List`, word indices in `Uint16List`, entropy in `Uint8List`. `wipe()` fills them with zeros, and it runs when:

- you leave the screen, or confirm "Exit and erase";
- the app goes to the background (`paused`, `hidden`, `detached`);
- a screenshot is detected;
- you finish with "I wrote down the seed, erase", or start a new session.

The app's content-update check runs at app start, never inside the sandbox.

## Limits

These limits are part of the design, not footnotes.

- **Dart cannot guarantee that strings are erased from memory.** The buffers are zeroed, but the strings made for display and for accessibility labels (the bit strings, the math lines, the word labels) and the framework's own copies are only released by the garbage collector. The app cannot control that. The protection is against casual exposure, not against someone reading the device's memory.
- **The iOS screen protection is an undocumented UIKit technique.** It has changed between iOS versions and can change again. Test it on a physical device for each iOS release. The simulator does not reproduce capture blanking.
- **A phone is not an air-gapped device.** The operating system, other apps with screen access, accessibility services, keyboards in other apps, device management tools and any malware with screen access can read what is on screen. Photos taken before the sandbox opened can be synced to a cloud.
- **Accessibility services can read revealed words.** A screen reader or an accessibility service reads what is shown while the words are revealed. With a screen reader on, the reveal control is a toggle, so the words stay visible until you toggle them off.
- **Android 13 and older cannot detect screenshots.** They are blocked by `FLAG_SECURE`, but the sandbox gets no event, so the session is not wiped by a screenshot attempt on those versions.
- **The app cannot check what you write down.** The BIP39 checksum helps the wallet catch some typing errors when you import the seed, not the app.
- **Dice are assumed fair.** The statistics only catch gross bias.
- **Camera readings can be wrong.** The current model reads about one die in four wrong, sometimes with high confidence. The review threshold and the correction sheet are the defence, and you must check every throw against the dice before you confirm it.
- **Same dice in the same place.** If you roll to the same values without moving the dice out of the frame, auto-capture does not record a new throw. Use the Confirm throw button or the keypad.
- **Only the English wordlist is supported.**

## Device test checklist

To run on physical devices. The simulator has no camera and does not reproduce the iOS capture blanking.

- [ ] Android: a screenshot is blocked (the capture is blank or black), and a screen recording shows nothing from the sandbox.
- [ ] Android 14 or later: a screenshot wipes the session and shows the dialog.
- [ ] Android: the recent apps preview of the sandbox is blank.
- [ ] iOS: a screenshot of the sandbox shows the sensitive area blank.
- [ ] iOS: screen recording or mirroring covers the sandbox until it stops.
- [ ] iOS: the app switcher shows the cover, not the words, and leaving the app wipes the session.
- [ ] iOS: after leaving the sandbox, the rest of the app draws normally (the shield is removed).
- [ ] Both: auto-capture reads five dice on a light surface, shows the values above the dice, and opens the correction sheet when a reading is below 0.85. This needs the trained model.
- [ ] Both: with airplane mode off, the online warning shows; with it on, it goes away.
- [ ] Both: the words are hidden until held, and hidden again on release. There is no selection, copy or share action on long press.
- [ ] Both: with camera permission denied, the sandbox says the camera is not available and the keypad works.
- [ ] Both: a 12-word and a 24-word seed from the same rolls match SeedSigner or Coldcard, or the Python script above.

## Code map

- `lib/src/features/tools/domain/`: `bip39.dart`, `bip39_wordlist_en.dart`, `dice_entropy.dart`, `dice_detection.dart`. Pure Dart, no Flutter imports.
- `lib/src/features/tools/data/`: `dice_detector.dart` (interface), `tflite_dice_detector.dart` (camera and TFLite), `secure_screen_channel.dart` (Dart side of the native guard).
- `lib/src/features/tools/presentation/`: `tool_dice_screen.dart` (the entry screen), `dice_sandbox_screen.dart` (the sandbox), `dice_session_controller.dart` (in-memory state), `dice_widgets.dart`, `dice_result_view.dart`.
- Native guard: `android/app/src/main/kotlin/org/satowiki/sato_wiki/MainActivity.kt` and `ios/Runner/AppDelegate.swift`, on the channel `org.satowiki/secure_screen`.
- Model pipeline: `tool/dice_model/`, with `README.md`. The model card is `assets/models/dice_detector.md`.
- Unit tests: `test/tools_bip39_test.dart`, `test/tools_dice_entropy_test.dart`, `test/tools_dice_detection_test.dart`, `test/tools_dice_detector_test.dart`, `test/tools_dice_session_controller_test.dart`, `test/tools_secure_screen_test.dart`. Widget tests: `test/tools_dice_screen_test.dart`, with fakes in `test/tools_dice_fakes.dart` (`FakeDiceDetector`, `FakeSecureScreen`). The seed smoke test (`test/seed_smoke_support.dart`) also opens the dice intro in every combination. The tests never open a camera: the detector and the secure-screen channel are faked or mocked.

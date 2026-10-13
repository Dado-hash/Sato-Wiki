import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/features/tools/domain/units.dart';

void main() {
  group('satoshiToBitcoinText', () {
    test('always shows 8 decimals', () {
      expect(satoshiToBitcoinText(1), '0.00000001');
      expect(satoshiToBitcoinText(0), '0.00000000');
      expect(satoshiToBitcoinText(100000000), '1.00000000');
      expect(satoshiToBitcoinText(2100000000000000), '21000000.00000000');
      expect(satoshiToBitcoinText(5000000000), '50.00000000');
    });

    test('negative amounts keep the sign', () {
      expect(satoshiToBitcoinText(-1), '-0.00000001');
      expect(satoshiToBitcoinText(-150000000), '-1.50000000');
    });
  });

  group('bitcoinTextToSatoshi', () {
    test('parses dot and comma separators', () {
      expect(bitcoinTextToSatoshi('1.5'), 150000000);
      expect(bitcoinTextToSatoshi('1,5'), 150000000);
      expect(bitcoinTextToSatoshi('0.00000001'), 1);
      expect(bitcoinTextToSatoshi('21000000'), 2100000000000000);
      expect(bitcoinTextToSatoshi(' 0.1 '), 10000000);
    });

    test('parses negative amounts', () {
      expect(bitcoinTextToSatoshi('-0.00000001'), -1);
      expect(bitcoinTextToSatoshi('-1,5'), -150000000);
    });

    test('rejects more than 8 decimals', () {
      expect(() => bitcoinTextToSatoshi('1.000000001'), throwsFormatException);
      expect(() => bitcoinTextToSatoshi('1.100000000'), throwsFormatException);
    });

    test('rejects empty text, garbage and dangling separators', () {
      expect(() => bitcoinTextToSatoshi(''), throwsFormatException);
      expect(() => bitcoinTextToSatoshi('   '), throwsFormatException);
      expect(() => bitcoinTextToSatoshi('abc'), throwsFormatException);
      expect(() => bitcoinTextToSatoshi('1.2.3'), throwsFormatException);
      expect(() => bitcoinTextToSatoshi('1.'), throwsFormatException);
      expect(() => bitcoinTextToSatoshi('.'), throwsFormatException);
      expect(() => bitcoinTextToSatoshi('-'), throwsFormatException);
      expect(() => bitcoinTextToSatoshi('1e3'), throwsFormatException);
    });

    test('round trips through text', () {
      for (final satoshi in [
        0,
        1,
        99999999,
        100000000,
        -42,
        2100000000000000,
      ]) {
        expect(bitcoinTextToSatoshi(satoshiToBitcoinText(satoshi)), satoshi);
      }
    });
  });

  group('weight and virtual size', () {
    test('vbytesFromWeight rounds up', () {
      expect(vbytesFromWeight(561), 141);
      expect(vbytesFromWeight(564), 141);
      expect(vbytesFromWeight(565), 142);
      expect(vbytesFromWeight(0), 0);
    });

    test('weightFromSizes is base * 3 + total', () {
      expect(weightFromSizes(baseSize: 100, totalSize: 200), 500);
      expect(weightFromSizes(baseSize: 204, totalSize: 204), 816);
    });
  });

  group('fee rate', () {
    test('feeRate is satoshi per virtual byte', () {
      expect(feeRate(feeSatoshi: 1410, vbytes: 141), 10.0);
      expect(feeRate(feeSatoshi: 100, vbytes: 3), closeTo(33.333, 0.001));
    });

    test('feeRate rejects zero or negative vbytes', () {
      expect(() => feeRate(feeSatoshi: 1, vbytes: 0), throwsArgumentError);
      expect(() => feeRate(feeSatoshi: 1, vbytes: -5), throwsArgumentError);
    });

    test('feeForRate rounds up', () {
      expect(feeForRate(satPerVbyte: 2.5, vbytes: 141), 353);
      expect(feeForRate(satPerVbyte: 1, vbytes: 141), 141);
      expect(feeForRate(satPerVbyte: 1.1, vbytes: 10), 11);
      expect(feeForRate(satPerVbyte: 0, vbytes: 141), 0);
    });

    test('feeForRate rejects bad input', () {
      expect(
        () => feeForRate(satPerVbyte: -1, vbytes: 10),
        throwsArgumentError,
      );
      expect(
        () => feeForRate(satPerVbyte: double.nan, vbytes: 10),
        throwsArgumentError,
      );
      expect(() => feeForRate(satPerVbyte: 1, vbytes: -1), throwsArgumentError);
    });
  });
}

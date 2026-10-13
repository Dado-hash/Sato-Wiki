import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:sato_wiki/src/features/tools/domain/script_machine.dart';
import 'package:sato_wiki/src/features/tools/domain/script_opcodes.dart';
import 'package:sato_wiki/src/features/tools/domain/script_parser.dart';
import 'package:sato_wiki/src/features/tools/domain/tools_bytes.dart';

// Bitcoin Core test vectors, from src/test/data/script_tests.json on the
// master branch of https://github.com/bitcoin/bitcoin, fetched during
// development. Only the 915 non-witness vectors whose flags are empty, P2SH,
// STRICTENC or P2SH,STRICTENC are stored here, as
// [scriptSig, scriptPubKey, flags, expected]. The comment field is dropped.
// The test helper below applies the selection rules.
const _coreVectorsJson =
    r'''[["","DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["  ","DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["   ","DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["    ","DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["1 2","2 EQUALVERIFY 1 EQUAL","P2SH,STRICTENC","OK"],["1  2","2 EQUALVERIFY 1 EQUAL","P2SH,STRICTENC","OK"],["  1  2","2 EQUALVERIFY 1 EQUAL","P2SH,STRICTENC","OK"],["1  2  ","2 EQUALVERIFY 1 EQUAL","P2SH,STRICTENC","OK"],["  1  2  ","2 EQUALVERIFY 1 EQUAL","P2SH,STRICTENC","OK"],["1","","P2SH,STRICTENC","OK"],["0x02 0x01 0x00","","P2SH,STRICTENC","OK"],["0x09 0x00000000 0x00000000 0x10","","P2SH,STRICTENC","OK"],["0x01 0x0b","11 EQUAL","P2SH,STRICTENC","OK"],["0x02 0x417a","'Az' EQUAL","P2SH,STRICTENC","OK"],["0x4b 0x417a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a7a","'Azzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzzz' EQUAL","P2SH,STRICTENC","OK"],["0x4c 0x01 0x07","7 EQUAL","P2SH,STRICTENC","OK"],["0x4d 0x0100 0x08","8 EQUAL","P2SH,STRICTENC","OK"],["0x4e 0x01000000 0x09","9 EQUAL","P2SH,STRICTENC","OK"],["0x4c 0x00","0 EQUAL","P2SH,STRICTENC","OK"],["0x4d 0x0000","0 EQUAL","P2SH,STRICTENC","OK"],["0x4e 0x00000000","0 EQUAL","P2SH,STRICTENC","OK"],["0x4f 1000 ADD","999 EQUAL","P2SH,STRICTENC","OK"],["0","IF 0x50 ENDIF 1","P2SH,STRICTENC","OK"],["0x51","0x5f ADD 0x60 EQUAL","P2SH,STRICTENC","OK"],["1","NOP","P2SH,STRICTENC","OK"],["0","IF VER ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF RESERVED RESERVED1 RESERVED2 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["1","DUP IF ENDIF","P2SH,STRICTENC","OK"],["1","IF 1 ENDIF","P2SH,STRICTENC","OK"],["1","DUP IF ELSE ENDIF","P2SH,STRICTENC","OK"],["1","IF 1 ELSE ENDIF","P2SH,STRICTENC","OK"],["0","IF ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["1 1","IF IF 1 ELSE 0 ENDIF ENDIF","P2SH,STRICTENC","OK"],["1 0","IF IF 1 ELSE 0 ENDIF ENDIF","P2SH,STRICTENC","OK"],["1 1","IF IF 1 ELSE 0 ENDIF ELSE IF 0 ELSE 1 ENDIF ENDIF","P2SH,STRICTENC","OK"],["0 0","IF IF 1 ELSE 0 ENDIF ELSE IF 0 ELSE 1 ENDIF ENDIF","P2SH,STRICTENC","OK"],["1 0","NOTIF IF 1 ELSE 0 ENDIF ENDIF","P2SH,STRICTENC","OK"],["1 1","NOTIF IF 1 ELSE 0 ENDIF ENDIF","P2SH,STRICTENC","OK"],["1 0","NOTIF IF 1 ELSE 0 ENDIF ELSE IF 0 ELSE 1 ENDIF ENDIF","P2SH,STRICTENC","OK"],["0 1","NOTIF IF 1 ELSE 0 ENDIF ELSE IF 0 ELSE 1 ENDIF ENDIF","P2SH,STRICTENC","OK"],["0","IF 0 ELSE 1 ELSE 0 ENDIF","P2SH,STRICTENC","OK"],["1","IF 1 ELSE 0 ELSE ENDIF","P2SH,STRICTENC","OK"],["1","IF ELSE 0 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["1","IF 1 ELSE 0 ELSE 1 ENDIF ADD 2 EQUAL","P2SH,STRICTENC","OK"],["'' 1","IF SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ENDIF 0x14 0x68ca4fec736264c13b859bac43d5173df6871682 EQUAL","P2SH,STRICTENC","OK"],["1","NOTIF 0 ELSE 1 ELSE 0 ENDIF","P2SH,STRICTENC","OK"],["0","NOTIF 1 ELSE 0 ELSE ENDIF","P2SH,STRICTENC","OK"],["0","NOTIF ELSE 0 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","NOTIF 1 ELSE 0 ELSE 1 ENDIF ADD 2 EQUAL","P2SH,STRICTENC","OK"],["'' 0","NOTIF SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ELSE ELSE SHA1 ENDIF 0x14 0x68ca4fec736264c13b859bac43d5173df6871682 EQUAL","P2SH,STRICTENC","OK"],["0","IF 1 IF RETURN ELSE RETURN ELSE RETURN ENDIF ELSE 1 IF 1 ELSE RETURN ELSE 1 ENDIF ELSE RETURN ENDIF ADD 2 EQUAL","P2SH,STRICTENC","OK"],["1","NOTIF 0 NOTIF RETURN ELSE RETURN ELSE RETURN ENDIF ELSE 0 NOTIF 1 ELSE RETURN ELSE 1 ENDIF ELSE RETURN ENDIF ADD 2 EQUAL","P2SH,STRICTENC","OK"],["0","IF RETURN ENDIF 1","P2SH,STRICTENC","OK"],["1 1","VERIFY","P2SH,STRICTENC","OK"],["1 0x05 0x01 0x00 0x00 0x00 0x00","VERIFY","P2SH,STRICTENC","OK"],["1 0x01 0x80","IF 0 ENDIF","P2SH,STRICTENC","OK"],["10 0 11 TOALTSTACK DROP FROMALTSTACK","ADD 21 EQUAL","P2SH,STRICTENC","OK"],["'gavin_was_here' TOALTSTACK 11 FROMALTSTACK","'gavin_was_here' EQUALVERIFY 11 EQUAL","P2SH,STRICTENC","OK"],["0 IFDUP","DEPTH 1 EQUALVERIFY 0 EQUAL","P2SH,STRICTENC","OK"],["1 IFDUP","DEPTH 2 EQUALVERIFY 1 EQUALVERIFY 1 EQUAL","P2SH,STRICTENC","OK"],["0x05 0x0100000000 IFDUP","DEPTH 2 EQUALVERIFY 0x05 0x0100000000 EQUAL","P2SH,STRICTENC","OK"],["0 DROP","DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["0","DUP 1 ADD 1 EQUALVERIFY 0 EQUAL","P2SH,STRICTENC","OK"],["0 1","NIP","P2SH,STRICTENC","OK"],["1 0","OVER DEPTH 3 EQUALVERIFY","P2SH,STRICTENC","OK"],["22 21 20","0 PICK 20 EQUALVERIFY DEPTH 3 EQUAL","P2SH,STRICTENC","OK"],["22 21 20","1 PICK 21 EQUALVERIFY DEPTH 3 EQUAL","P2SH,STRICTENC","OK"],["22 21 20","2 PICK 22 EQUALVERIFY DEPTH 3 EQUAL","P2SH,STRICTENC","OK"],["22 21 20","0 ROLL 20 EQUALVERIFY DEPTH 2 EQUAL","P2SH,STRICTENC","OK"],["22 21 20","1 ROLL 21 EQUALVERIFY DEPTH 2 EQUAL","P2SH,STRICTENC","OK"],["22 21 20","2 ROLL 22 EQUALVERIFY DEPTH 2 EQUAL","P2SH,STRICTENC","OK"],["22 21 20","ROT 22 EQUAL","P2SH,STRICTENC","OK"],["22 21 20","ROT DROP 20 EQUAL","P2SH,STRICTENC","OK"],["22 21 20","ROT DROP DROP 21 EQUAL","P2SH,STRICTENC","OK"],["22 21 20","ROT ROT 21 EQUAL","P2SH,STRICTENC","OK"],["22 21 20","ROT ROT ROT 20 EQUAL","P2SH,STRICTENC","OK"],["25 24 23 22 21 20","2ROT 24 EQUAL","P2SH,STRICTENC","OK"],["25 24 23 22 21 20","2ROT DROP 25 EQUAL","P2SH,STRICTENC","OK"],["25 24 23 22 21 20","2ROT 2DROP 20 EQUAL","P2SH,STRICTENC","OK"],["25 24 23 22 21 20","2ROT 2DROP DROP 21 EQUAL","P2SH,STRICTENC","OK"],["25 24 23 22 21 20","2ROT 2DROP 2DROP 22 EQUAL","P2SH,STRICTENC","OK"],["25 24 23 22 21 20","2ROT 2DROP 2DROP DROP 23 EQUAL","P2SH,STRICTENC","OK"],["25 24 23 22 21 20","2ROT 2ROT 22 EQUAL","P2SH,STRICTENC","OK"],["25 24 23 22 21 20","2ROT 2ROT 2ROT 20 EQUAL","P2SH,STRICTENC","OK"],["1 2 3 4 5 6","2ROT DEPTH 6 EQUAL","P2SH,STRICTENC","OK"],["1 0","SWAP 1 EQUALVERIFY 0 EQUAL","P2SH,STRICTENC","OK"],["0 1","TUCK DEPTH 3 EQUALVERIFY SWAP 2DROP","P2SH,STRICTENC","OK"],["13 14","2DUP ROT EQUALVERIFY EQUAL","P2SH,STRICTENC","OK"],["-1 0 1 2","3DUP DEPTH 7 EQUALVERIFY ADD ADD 3 EQUALVERIFY 2DROP 0 EQUALVERIFY","P2SH,STRICTENC","OK"],["1 2 3 5","2OVER ADD ADD 8 EQUALVERIFY ADD ADD 6 EQUAL","P2SH,STRICTENC","OK"],["1 3 5 7","2SWAP ADD 4 EQUALVERIFY ADD 12 EQUAL","P2SH,STRICTENC","OK"],["0","SIZE 0 EQUAL","P2SH,STRICTENC","OK"],["1","SIZE 1 EQUAL","P2SH,STRICTENC","OK"],["127","SIZE 1 EQUAL","P2SH,STRICTENC","OK"],["128","SIZE 2 EQUAL","P2SH,STRICTENC","OK"],["32767","SIZE 2 EQUAL","P2SH,STRICTENC","OK"],["32768","SIZE 3 EQUAL","P2SH,STRICTENC","OK"],["8388607","SIZE 3 EQUAL","P2SH,STRICTENC","OK"],["8388608","SIZE 4 EQUAL","P2SH,STRICTENC","OK"],["2147483647","SIZE 4 EQUAL","P2SH,STRICTENC","OK"],["2147483648","SIZE 5 EQUAL","P2SH,STRICTENC","OK"],["0x05ffffffff7f","SIZE 5 EQUAL","P2SH,STRICTENC","OK"],["0x06000000008000","SIZE 6 EQUAL","P2SH,STRICTENC","OK"],["0x08ffffffffffffff7f","SIZE 8 EQUAL","P2SH,STRICTENC","OK"],["-1","SIZE 1 EQUAL","P2SH,STRICTENC","OK"],["-127","SIZE 1 EQUAL","P2SH,STRICTENC","OK"],["-128","SIZE 2 EQUAL","P2SH,STRICTENC","OK"],["-32767","SIZE 2 EQUAL","P2SH,STRICTENC","OK"],["-32768","SIZE 3 EQUAL","P2SH,STRICTENC","OK"],["-8388607","SIZE 3 EQUAL","P2SH,STRICTENC","OK"],["-8388608","SIZE 4 EQUAL","P2SH,STRICTENC","OK"],["-2147483647","SIZE 4 EQUAL","P2SH,STRICTENC","OK"],["-2147483648","SIZE 5 EQUAL","P2SH,STRICTENC","OK"],["0x05ffffffffff","SIZE 5 EQUAL","P2SH,STRICTENC","OK"],["0x06000000008080","SIZE 6 EQUAL","P2SH,STRICTENC","OK"],["0x08ffffffffffffffff","SIZE 8 EQUAL","P2SH,STRICTENC","OK"],["'abcdefghijklmnopqrstuvwxyz'","SIZE 26 EQUAL","P2SH,STRICTENC","OK"],["42","SIZE 1 EQUALVERIFY 42 EQUAL","P2SH,STRICTENC","OK"],["2 -2 ADD","0 EQUAL","P2SH,STRICTENC","OK"],["2147483647 -2147483647 ADD","0 EQUAL","P2SH,STRICTENC","OK"],["-1 -1 ADD","-2 EQUAL","P2SH,STRICTENC","OK"],["0 0","EQUAL","P2SH,STRICTENC","OK"],["1 1 ADD","2 EQUAL","P2SH,STRICTENC","OK"],["1 1ADD","2 EQUAL","P2SH,STRICTENC","OK"],["111 1SUB","110 EQUAL","P2SH,STRICTENC","OK"],["111 1 ADD 12 SUB","100 EQUAL","P2SH,STRICTENC","OK"],["0 ABS","0 EQUAL","P2SH,STRICTENC","OK"],["16 ABS","16 EQUAL","P2SH,STRICTENC","OK"],["-16 ABS","-16 NEGATE EQUAL","P2SH,STRICTENC","OK"],["0 NOT","NOP","P2SH,STRICTENC","OK"],["1 NOT","0 EQUAL","P2SH,STRICTENC","OK"],["11 NOT","0 EQUAL","P2SH,STRICTENC","OK"],["0 0NOTEQUAL","0 EQUAL","P2SH,STRICTENC","OK"],["1 0NOTEQUAL","1 EQUAL","P2SH,STRICTENC","OK"],["111 0NOTEQUAL","1 EQUAL","P2SH,STRICTENC","OK"],["-111 0NOTEQUAL","1 EQUAL","P2SH,STRICTENC","OK"],["1 1 BOOLAND","NOP","P2SH,STRICTENC","OK"],["1 0 BOOLAND","NOT","P2SH,STRICTENC","OK"],["0 1 BOOLAND","NOT","P2SH,STRICTENC","OK"],["0 0 BOOLAND","NOT","P2SH,STRICTENC","OK"],["16 17 BOOLAND","NOP","P2SH,STRICTENC","OK"],["1 1 BOOLOR","NOP","P2SH,STRICTENC","OK"],["1 0 BOOLOR","NOP","P2SH,STRICTENC","OK"],["0 1 BOOLOR","NOP","P2SH,STRICTENC","OK"],["0 0 BOOLOR","NOT","P2SH,STRICTENC","OK"],["0x01 0x80","DUP BOOLOR","P2SH,STRICTENC","EVAL_FALSE"],["0x01 0x00","DUP BOOLOR","P2SH,STRICTENC","EVAL_FALSE"],["0x01 0x81","DUP BOOLOR","P2SH,STRICTENC","OK"],["0x01 0x80","DUP BOOLAND","P2SH,STRICTENC","EVAL_FALSE"],["0x01 0x00","DUP BOOLAND","P2SH,STRICTENC","EVAL_FALSE"],["0x01 0x81","DUP BOOLAND","P2SH,STRICTENC","OK"],["0x01 0x00","NOT","P2SH,STRICTENC","OK"],["0x01 0x80","NOT","P2SH,STRICTENC","OK"],["0x01 0x81","NOT","P2SH,STRICTENC","EVAL_FALSE"],["0x01 0x80 0","NUMEQUAL","P2SH","OK"],["0x01 0x00 0","NUMEQUAL","P2SH","OK"],["0x02 0x00 0x00 0","NUMEQUAL","P2SH","OK"],["16 17 BOOLOR","NOP","P2SH,STRICTENC","OK"],["11 10 1 ADD","NUMEQUAL","P2SH,STRICTENC","OK"],["11 10 1 ADD","NUMEQUALVERIFY 1","P2SH,STRICTENC","OK"],["11 10 1 ADD","NUMNOTEQUAL NOT","P2SH,STRICTENC","OK"],["111 10 1 ADD","NUMNOTEQUAL","P2SH,STRICTENC","OK"],["11 10","LESSTHAN NOT","P2SH,STRICTENC","OK"],["4 4","LESSTHAN NOT","P2SH,STRICTENC","OK"],["10 11","LESSTHAN","P2SH,STRICTENC","OK"],["-11 11","LESSTHAN","P2SH,STRICTENC","OK"],["-11 -10","LESSTHAN","P2SH,STRICTENC","OK"],["11 10","GREATERTHAN","P2SH,STRICTENC","OK"],["4 4","GREATERTHAN NOT","P2SH,STRICTENC","OK"],["10 11","GREATERTHAN NOT","P2SH,STRICTENC","OK"],["-11 11","GREATERTHAN NOT","P2SH,STRICTENC","OK"],["-11 -10","GREATERTHAN NOT","P2SH,STRICTENC","OK"],["11 10","LESSTHANOREQUAL NOT","P2SH,STRICTENC","OK"],["4 4","LESSTHANOREQUAL","P2SH,STRICTENC","OK"],["10 11","LESSTHANOREQUAL","P2SH,STRICTENC","OK"],["-11 11","LESSTHANOREQUAL","P2SH,STRICTENC","OK"],["-11 -10","LESSTHANOREQUAL","P2SH,STRICTENC","OK"],["11 10","GREATERTHANOREQUAL","P2SH,STRICTENC","OK"],["4 4","GREATERTHANOREQUAL","P2SH,STRICTENC","OK"],["10 11","GREATERTHANOREQUAL NOT","P2SH,STRICTENC","OK"],["-11 11","GREATERTHANOREQUAL NOT","P2SH,STRICTENC","OK"],["-11 -10","GREATERTHANOREQUAL NOT","P2SH,STRICTENC","OK"],["1 0 MIN","0 NUMEQUAL","P2SH,STRICTENC","OK"],["0 1 MIN","0 NUMEQUAL","P2SH,STRICTENC","OK"],["-1 0 MIN","-1 NUMEQUAL","P2SH,STRICTENC","OK"],["0 -2147483647 MIN","-2147483647 NUMEQUAL","P2SH,STRICTENC","OK"],["2147483647 0 MAX","2147483647 NUMEQUAL","P2SH,STRICTENC","OK"],["0 100 MAX","100 NUMEQUAL","P2SH,STRICTENC","OK"],["-100 0 MAX","0 NUMEQUAL","P2SH,STRICTENC","OK"],["0 -2147483647 MAX","0 NUMEQUAL","P2SH,STRICTENC","OK"],["0 0 1","WITHIN","P2SH,STRICTENC","OK"],["1 0 1","WITHIN NOT","P2SH,STRICTENC","OK"],["0 -2147483647 2147483647","WITHIN","P2SH,STRICTENC","OK"],["-1 -100 100","WITHIN","P2SH,STRICTENC","OK"],["11 -100 100","WITHIN","P2SH,STRICTENC","OK"],["-2147483647 -100 100","WITHIN NOT","P2SH,STRICTENC","OK"],["2147483647 -100 100","WITHIN NOT","P2SH,STRICTENC","OK"],["0 0 1","WITHIN DEPTH 1 EQUALVERIFY","P2SH,STRICTENC","OK"],["2147483647 2147483647 SUB","0 EQUAL","P2SH,STRICTENC","OK"],["2147483647 DUP ADD","4294967294 EQUAL","P2SH,STRICTENC","OK"],["2147483647 NEGATE DUP ADD","-4294967294 EQUAL","P2SH,STRICTENC","OK"],["''","RIPEMD160 0x14 0x9c1185a5c5e9fc54612808977ee8f548b2258d31 EQUAL","P2SH,STRICTENC","OK"],["'a'","RIPEMD160 0x14 0x0bdc9d2d256b3ee9daae347be6f4dc835a467ffe EQUAL","P2SH,STRICTENC","OK"],["'abcdefghijklmnopqrstuvwxyz'","RIPEMD160 0x14 0xf71c27109c692c1b56bbdceb5b9d2865b3708dbc EQUAL","P2SH,STRICTENC","OK"],["''","SHA1 0x14 0xda39a3ee5e6b4b0d3255bfef95601890afd80709 EQUAL","P2SH,STRICTENC","OK"],["'a'","SHA1 0x14 0x86f7e437faa5a7fce15d1ddcb9eaeaea377667b8 EQUAL","P2SH,STRICTENC","OK"],["'abcdefghijklmnopqrstuvwxyz'","SHA1 0x14 0x32d10c7b8cf96570ca04ce37f2a19d84240d3a89 EQUAL","P2SH,STRICTENC","OK"],["''","SHA256 0x20 0xe3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855 EQUAL","P2SH,STRICTENC","OK"],["'a'","SHA256 0x20 0xca978112ca1bbdcafac231b39a23dc4da786eff8147c4e72b9807785afee48bb EQUAL","P2SH,STRICTENC","OK"],["'abcdefghijklmnopqrstuvwxyz'","SHA256 0x20 0x71c480df93d6ae2f1efad1447c66c9525e316218cf51fc8d9ed832f2daf18b73 EQUAL","P2SH,STRICTENC","OK"],["''","DUP HASH160 SWAP SHA256 RIPEMD160 EQUAL","P2SH,STRICTENC","OK"],["''","DUP HASH256 SWAP SHA256 SHA256 EQUAL","P2SH,STRICTENC","OK"],["''","NOP HASH160 0x14 0xb472a266d0bd89c13706a4132ccfb16f7c3b9fcb EQUAL","P2SH,STRICTENC","OK"],["'a'","HASH160 NOP 0x14 0x994355199e516ff76c4fa4aab39337b9d84cf12b EQUAL","P2SH,STRICTENC","OK"],["'abcdefghijklmnopqrstuvwxyz'","HASH160 0x4c 0x14 0xc286a1af0947f58d1ad787385b1c2c4a976f9e71 EQUAL","P2SH,STRICTENC","OK"],["''","HASH256 0x20 0x5df6e0e2761359d30a8275058e299fcc0381534545f55cf43e41983f5d4c9456 EQUAL","P2SH,STRICTENC","OK"],["'a'","HASH256 0x20 0xbf5d3affb73efd2ec6c36ad3112dd933efed63c4e1cbffcfa88e2759c144f2d8 EQUAL","P2SH,STRICTENC","OK"],["'abcdefghijklmnopqrstuvwxyz'","HASH256 0x4c 0x20 0xca139bc10c2f660da42666f72e89a225936fc60f193c161124a672050c434671 EQUAL","P2SH,STRICTENC","OK"],["1","NOP1 CHECKLOCKTIMEVERIFY CHECKSEQUENCEVERIFY NOP4 NOP5 NOP6 NOP7 NOP8 NOP9 NOP10 1 EQUAL","P2SH,STRICTENC","OK"],["'NOP_1_to_10' NOP1 CHECKLOCKTIMEVERIFY CHECKSEQUENCEVERIFY NOP4 NOP5 NOP6 NOP7 NOP8 NOP9 NOP10","'NOP_1_to_10' EQUAL","P2SH,STRICTENC","OK"],["0","IF 0xba ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xbb ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xbc ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xbd ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xbe ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xbf ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xc0 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xc1 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xc2 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xc3 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xc4 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xc5 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xc6 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xc7 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xc8 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xc9 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xca ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xcb ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xcc ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xcd ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xce ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xcf ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xd0 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xd1 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xd2 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xd3 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xd4 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xd5 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xd6 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xd7 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xd8 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xd9 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xda ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xdb ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xdc ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xdd ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xde ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xdf ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xe0 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xe1 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xe2 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xe3 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xe4 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xe5 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xe6 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xe7 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xe8 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xe9 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xea ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xeb ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xec ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xed ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xee ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xef ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xf0 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xf1 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xf2 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xf3 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xf4 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xf5 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xf6 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xf7 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xf8 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xf9 ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xfa ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xfb ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xfc ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xfd ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xfe ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["0","IF 0xff ELSE 1 ENDIF","P2SH,STRICTENC","OK"],["NOP","'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'","P2SH,STRICTENC","OK"],["1","0x616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161","P2SH,STRICTENC","OK"],["1","0x60606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060606060","P2SH,STRICTENC","OK"],["1 2 3 4 5 0x6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f","1 2 3 4 5 0x6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f","P2SH,STRICTENC","OK"],["1 TOALTSTACK 2 TOALTSTACK 3 4 5 0x6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f","1 2 3 4 5 6 7 0x6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f","P2SH,STRICTENC","OK"],["'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 0x6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f","'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 0x6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f 2DUP 0x616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161","P2SH,STRICTENC","OK"],["0","IF 0x5050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050 ENDIF 1","P2SH,STRICTENC","OK"],["NOP","1","P2SH,STRICTENC","OK"],["1","0x01 0x01 EQUAL","P2SH,STRICTENC","OK"],["127","0x01 0x7F EQUAL","P2SH,STRICTENC","OK"],["128","0x02 0x8000 EQUAL","P2SH,STRICTENC","OK"],["32767","0x02 0xFF7F EQUAL","P2SH,STRICTENC","OK"],["32768","0x03 0x008000 EQUAL","P2SH,STRICTENC","OK"],["8388607","0x03 0xFFFF7F EQUAL","P2SH,STRICTENC","OK"],["8388608","0x04 0x00008000 EQUAL","P2SH,STRICTENC","OK"],["2147483647","0x04 0xFFFFFF7F EQUAL","P2SH,STRICTENC","OK"],["2147483648","0x05 0x0000008000 EQUAL","P2SH,STRICTENC","OK"],["0x05ffffffff7f","0x05 0xFFFFFFFF7F EQUAL","P2SH,STRICTENC","OK"],["0x06000000008000","0x06 0x000000008000 EQUAL","P2SH,STRICTENC","OK"],["0x08ffffffffffffff7f","0x08 0xFFFFFFFFFFFFFF7F EQUAL","P2SH,STRICTENC","OK"],["-1","0x01 0x81 EQUAL","P2SH,STRICTENC","OK"],["-127","0x01 0xFF EQUAL","P2SH,STRICTENC","OK"],["-128","0x02 0x8080 EQUAL","P2SH,STRICTENC","OK"],["-32767","0x02 0xFFFF EQUAL","P2SH,STRICTENC","OK"],["-32768","0x03 0x008080 EQUAL","P2SH,STRICTENC","OK"],["-8388607","0x03 0xFFFFFF EQUAL","P2SH,STRICTENC","OK"],["-8388608","0x04 0x00008080 EQUAL","P2SH,STRICTENC","OK"],["-2147483647","0x04 0xFFFFFFFF EQUAL","P2SH,STRICTENC","OK"],["-2147483648","0x05 0x0000008080 EQUAL","P2SH,STRICTENC","OK"],["-4294967295","0x05 0xFFFFFFFF80 EQUAL","P2SH,STRICTENC","OK"],["0x05ffffffffff","0x05 0xFFFFFFFFFF EQUAL","P2SH,STRICTENC","OK"],["0x06000000008080","0x06 0x000000008080 EQUAL","P2SH,STRICTENC","OK"],["0x08ffffffffffffffff","0x08 0xFFFFFFFFFFFFFFFF EQUAL","P2SH,STRICTENC","OK"],["2147483647","1ADD 2147483648 EQUAL","P2SH,STRICTENC","OK"],["2147483647","1ADD 1","P2SH,STRICTENC","OK"],["-2147483647","1ADD 1","P2SH,STRICTENC","OK"],["1","0x02 0x0100 EQUAL NOT","P2SH,STRICTENC","OK"],["1","0x02 0x0100 NUMEQUAL","P2SH,STRICTENC","OK"],["11","0x4c 0x03 0x0b0000 NUMEQUAL","P2SH,STRICTENC","OK"],["0","0x01 0x80 EQUAL NOT","P2SH,STRICTENC","OK"],["0","0x01 0x80 NUMEQUAL","P2SH,STRICTENC","OK"],["0","0x02 0x0080 NUMEQUAL","P2SH,STRICTENC","OK"],["0x03 0x000080","0x04 0x00000080 NUMEQUAL","P2SH,STRICTENC","OK"],["0x03 0x100080","0x04 0x10000080 NUMEQUAL","P2SH,STRICTENC","OK"],["0x03 0x100000","0x04 0x10000000 NUMEQUAL","P2SH,STRICTENC","OK"],["NOP","NOP 1","P2SH,STRICTENC","OK"],["1","IF 1 ENDIF","P2SH,STRICTENC","OK"],["0","NOTIF 1 ENDIF","P2SH,STRICTENC","OK"],["1","VERIFY 1","P2SH,STRICTENC","OK"],["0","TOALTSTACK 1","P2SH,STRICTENC","OK"],["1","TOALTSTACK FROMALTSTACK","P2SH,STRICTENC","OK"],["0 0","2DROP 1","P2SH,STRICTENC","OK"],["0 1","2DUP","P2SH,STRICTENC","OK"],["0 0 1","3DUP","P2SH,STRICTENC","OK"],["0 1 0 0","2OVER","P2SH,STRICTENC","OK"],["0 1 0 0 0 0","2ROT","P2SH,STRICTENC","OK"],["0 1 0 0","2SWAP","P2SH,STRICTENC","OK"],["1","IFDUP","P2SH,STRICTENC","OK"],["NOP","DEPTH 1","P2SH,STRICTENC","OK"],["0","DROP 1","P2SH,STRICTENC","OK"],["1","DUP","P2SH,STRICTENC","OK"],["0 1","NIP","P2SH,STRICTENC","OK"],["1 0","OVER","P2SH,STRICTENC","OK"],["1 0 0 0 3","PICK","P2SH,STRICTENC","OK"],["1 0","PICK","P2SH,STRICTENC","OK"],["1 0 0 0 3","ROLL","P2SH,STRICTENC","OK"],["1 0","ROLL","P2SH,STRICTENC","OK"],["1 0 0","ROT","P2SH,STRICTENC","OK"],["1 0","SWAP","P2SH,STRICTENC","OK"],["0 1","TUCK","P2SH,STRICTENC","OK"],["1","SIZE","P2SH,STRICTENC","OK"],["0 0","EQUAL","P2SH,STRICTENC","OK"],["0 0","EQUALVERIFY 1","P2SH,STRICTENC","OK"],["0 0 1","EQUAL EQUAL","P2SH,STRICTENC","OK"],["0","1ADD","P2SH,STRICTENC","OK"],["2","1SUB","P2SH,STRICTENC","OK"],["-1","NEGATE","P2SH,STRICTENC","OK"],["-1","ABS","P2SH,STRICTENC","OK"],["0","NOT","P2SH,STRICTENC","OK"],["-1","0NOTEQUAL","P2SH,STRICTENC","OK"],["1 0","ADD","P2SH,STRICTENC","OK"],["1 0","SUB","P2SH,STRICTENC","OK"],["-1 -1","BOOLAND","P2SH,STRICTENC","OK"],["-1 0","BOOLOR","P2SH,STRICTENC","OK"],["0 0","NUMEQUAL","P2SH,STRICTENC","OK"],["0 0","NUMEQUALVERIFY 1","P2SH,STRICTENC","OK"],["2 0","NUMEQUALVERIFY","P2SH,STRICTENC","NUMEQUALVERIFY"],["-1 0","NUMNOTEQUAL","P2SH,STRICTENC","OK"],["-1 0","LESSTHAN","P2SH,STRICTENC","OK"],["1 0","GREATERTHAN","P2SH,STRICTENC","OK"],["0 0","LESSTHANOREQUAL","P2SH,STRICTENC","OK"],["0 0","GREATERTHANOREQUAL","P2SH,STRICTENC","OK"],["-1 0","MIN","P2SH,STRICTENC","OK"],["1 0","MAX","P2SH,STRICTENC","OK"],["-1 -1 0","WITHIN","P2SH,STRICTENC","OK"],["0","RIPEMD160","P2SH,STRICTENC","OK"],["0","SHA1","P2SH,STRICTENC","OK"],["0","SHA256","P2SH,STRICTENC","OK"],["0","HASH160","P2SH,STRICTENC","OK"],["0","HASH256","P2SH,STRICTENC","OK"],["NOP","CODESEPARATOR 1","P2SH,STRICTENC","OK"],["NOP","NOP1 1","P2SH,STRICTENC","OK"],["NOP","CHECKLOCKTIMEVERIFY 1","P2SH,STRICTENC","OK"],["NOP","CHECKSEQUENCEVERIFY 1","P2SH,STRICTENC","OK"],["NOP","NOP4 1","P2SH,STRICTENC","OK"],["NOP","NOP5 1","P2SH,STRICTENC","OK"],["NOP","NOP6 1","P2SH,STRICTENC","OK"],["NOP","NOP7 1","P2SH,STRICTENC","OK"],["NOP","NOP8 1","P2SH,STRICTENC","OK"],["NOP","NOP9 1","P2SH,STRICTENC","OK"],["NOP","NOP10 1","P2SH,STRICTENC","OK"],["","0 0 0 CHECKMULTISIG VERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 0 CHECKMULTISIGVERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 0 1 CHECKMULTISIG VERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 0 1 CHECKMULTISIGVERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 0 CHECKMULTISIG VERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 0 CHECKMULTISIGVERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 0 1 CHECKMULTISIG VERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 0 1 CHECKMULTISIGVERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 2 CHECKMULTISIG VERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 3 CHECKMULTISIG VERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 4 CHECKMULTISIG VERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 5 CHECKMULTISIG VERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 6 CHECKMULTISIG VERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 7 CHECKMULTISIG VERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 8 CHECKMULTISIG VERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 9 CHECKMULTISIG VERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 10 CHECKMULTISIG VERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 11 CHECKMULTISIG VERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 12 CHECKMULTISIG VERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 13 CHECKMULTISIG VERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 14 CHECKMULTISIG VERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 15 CHECKMULTISIG VERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 16 CHECKMULTISIG VERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 17 CHECKMULTISIG VERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 18 CHECKMULTISIG VERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 19 CHECKMULTISIG VERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIG VERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 1 CHECKMULTISIGVERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 2 CHECKMULTISIGVERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 3 CHECKMULTISIGVERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 4 CHECKMULTISIGVERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 5 CHECKMULTISIGVERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 6 CHECKMULTISIGVERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 7 CHECKMULTISIGVERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 8 CHECKMULTISIGVERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 9 CHECKMULTISIGVERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 10 CHECKMULTISIGVERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 11 CHECKMULTISIGVERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 12 CHECKMULTISIGVERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 13 CHECKMULTISIGVERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 14 CHECKMULTISIGVERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 15 CHECKMULTISIGVERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 16 CHECKMULTISIGVERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 17 CHECKMULTISIGVERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 18 CHECKMULTISIGVERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 19 CHECKMULTISIGVERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIGVERIFY DEPTH 0 EQUAL","P2SH,STRICTENC","OK"],["","0 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG","P2SH,STRICTENC","OK"],["1","0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY 0 0 0 CHECKMULTISIGVERIFY","P2SH,STRICTENC","OK"],["","NOP NOP NOP NOP NOP NOP NOP NOP NOP NOP NOP NOP 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIG 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIG 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIG 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIG 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIG 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIG 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIG 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIG 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIG","P2SH,STRICTENC","OK"],["1","NOP NOP NOP NOP NOP NOP NOP NOP NOP NOP NOP NOP 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIGVERIFY 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIGVERIFY 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIGVERIFY 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIGVERIFY 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIGVERIFY 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIGVERIFY 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIGVERIFY 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIGVERIFY 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIGVERIFY","P2SH,STRICTENC","OK"],["0 0x01 1","HASH160 0x14 0xda1745e9b549bd0bfa1a569971c77eba30cd5a4b EQUAL","P2SH,STRICTENC","OK"],["0x4c 0 0x01 1","HASH160 0x14 0xda1745e9b549bd0bfa1a569971c77eba30cd5a4b EQUAL","P2SH,STRICTENC","OK"],["0x40 0x42424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242","0x4d 0x4000 0x42424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242 EQUAL","P2SH,STRICTENC","OK"],["0x4c 0x40 0x42424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242","0x4d 0x4000 0x42424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242424242 EQUAL","P2SH,STRICTENC","OK"],["0x4c 0x4b 0x111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111","0x4b 0x111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111 EQUAL","","OK"],["0x4d 0xFF00 0x111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111","0x4c 0xFF 0x111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111 EQUAL","","OK"],["0x00","SIZE 0 EQUAL","P2SH,STRICTENC","OK"],["0x01 0x81","0x4f EQUAL","","OK"],["0x01 0x01","0x51 EQUAL","","OK"],["0x01 0x02","0x52 EQUAL","","OK"],["0x01 0x03","0x53 EQUAL","","OK"],["0x01 0x04","0x54 EQUAL","","OK"],["0x01 0x05","0x55 EQUAL","","OK"],["0x01 0x06","0x56 EQUAL","","OK"],["0x01 0x07","0x57 EQUAL","","OK"],["0x01 0x08","0x58 EQUAL","","OK"],["0x01 0x09","0x59 EQUAL","","OK"],["0x01 0x0a","0x5a EQUAL","","OK"],["0x01 0x0b","0x5b EQUAL","","OK"],["0x01 0x0c","0x5c EQUAL","","OK"],["0x01 0x0d","0x5d EQUAL","","OK"],["0x01 0x0e","0x5e EQUAL","","OK"],["0x01 0x0f","0x5f EQUAL","","OK"],["0x01 0x10","0x60 EQUAL","","OK"],["0x02 0x8000","128 NUMEQUAL","","OK"],["0x01 0x00","0 NUMEQUAL","","OK"],["0x01 0x80","0 NUMEQUAL","","OK"],["0x02 0x0080","0 NUMEQUAL","","OK"],["0x02 0x0500","5 NUMEQUAL","","OK"],["0x03 0xff7f80","0x02 0xffff NUMEQUAL","","OK"],["0x03 0xff7f00","0x02 0xff7f NUMEQUAL","","OK"],["0x04 0xffff7f80","0x03 0xffffff NUMEQUAL","","OK"],["0x04 0xffff7f00","0x03 0xffff7f NUMEQUAL","","OK"],["1 0x02 0x0000","PICK DROP","","OK"],["1 0x02 0x0000","ROLL DROP 1","","OK"],["0x02 0x0000","1ADD DROP 1","","OK"],["0x02 0x0000","1SUB DROP 1","","OK"],["0x02 0x0000","NEGATE DROP 1","","OK"],["0x02 0x0000","ABS DROP 1","","OK"],["0x02 0x0000","NOT DROP 1","","OK"],["0x02 0x0000","0NOTEQUAL DROP 1","","OK"],["0 0x02 0x0000","ADD DROP 1","","OK"],["0x02 0x0000 0","ADD DROP 1","","OK"],["0 0x02 0x0000","SUB DROP 1","","OK"],["0x02 0x0000 0","SUB DROP 1","","OK"],["0 0x02 0x0000","BOOLAND DROP 1","","OK"],["0x02 0x0000 0","BOOLAND DROP 1","","OK"],["0 0x02 0x0000","BOOLOR DROP 1","","OK"],["0x02 0x0000 0","BOOLOR DROP 1","","OK"],["0 0x02 0x0000","NUMEQUAL DROP 1","","OK"],["0x02 0x0000 1","NUMEQUAL DROP 1","","OK"],["0 0x02 0x0000","NUMEQUALVERIFY 1","","OK"],["0x02 0x0000 0","NUMEQUALVERIFY 1","","OK"],["0 0x02 0x0000","NUMNOTEQUAL DROP 1","","OK"],["0x02 0x0000 0","NUMNOTEQUAL DROP 1","","OK"],["0 0x02 0x0000","LESSTHAN DROP 1","","OK"],["0x02 0x0000 0","LESSTHAN DROP 1","","OK"],["0 0x02 0x0000","GREATERTHAN DROP 1","","OK"],["0x02 0x0000 0","GREATERTHAN DROP 1","","OK"],["0 0x02 0x0000","LESSTHANOREQUAL DROP 1","","OK"],["0x02 0x0000 0","LESSTHANOREQUAL DROP 1","","OK"],["0 0x02 0x0000","GREATERTHANOREQUAL DROP 1","","OK"],["0x02 0x0000 0","GREATERTHANOREQUAL DROP 1","","OK"],["0 0x02 0x0000","MIN DROP 1","","OK"],["0x02 0x0000 0","MIN DROP 1","","OK"],["0 0x02 0x0000","MAX DROP 1","","OK"],["0x02 0x0000 0","MAX DROP 1","","OK"],["0x02 0x0000 0 0","WITHIN DROP 1","","OK"],["0 0x02 0x0000 0","WITHIN DROP 1","","OK"],["0 0 0x02 0x0000","WITHIN DROP 1","","OK"],["0 0 0x02 0x0000","CHECKMULTISIG DROP 1","","OK"],["0 0x02 0x0000 0","CHECKMULTISIG DROP 1","","OK"],["0 0x02 0x0000 0 1","CHECKMULTISIG DROP 1","","OK"],["0 0 0x02 0x0000","CHECKMULTISIGVERIFY 1","","OK"],["0 0x02 0x0000 0","CHECKMULTISIGVERIFY 1","","OK"],["0","0x21 0x02865c40293a680cb9c020e7b1e106d8c1916d3cef99aa431a56d253e69256dac0 CHECKSIG NOT","STRICTENC","OK"],["0 0","1 0x21 0x02865c40293a680cb9c020e7b1e106d8c1916d3cef99aa431a56d253e69256dac0 1 CHECKMULTISIG NOT","STRICTENC","OK"],["0 0x47 0x3044022044dc17b0887c161bb67ba9635bf758735bdde503e4b0a0987f587f14a4e1143d022009a215772d49a85dae40d8ca03955af26ad3978a0ff965faa12915e9586249a501 0x47 0x3044022044dc17b0887c161bb67ba9635bf758735bdde503e4b0a0987f587f14a4e1143d022009a215772d49a85dae40d8ca03955af26ad3978a0ff965faa12915e9586249a501","2 0 0x21 0x02865c40293a680cb9c020e7b1e106d8c1916d3cef99aa431a56d253e69256dac0 2 CHECKMULTISIG NOT","STRICTENC","OK"],["0 1 0x47 0x3044022044dc17b0887c161bb67ba9635bf758735bdde503e4b0a0987f587f14a4e1143d022009a215772d49a85dae40d8ca03955af26ad3978a0ff965faa12915e9586249a501","2 0x21 0x02865c40293a680cb9c020e7b1e106d8c1916d3cef99aa431a56d253e69256dac0 0x21 0x02865c40293a680cb9c020e7b1e106d8c1916d3cef99aa431a56d253e69256dac0 2 CHECKMULTISIG NOT","STRICTENC","OK"],["0x4a 0x0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000","0 CHECKSIG NOT","","OK"],["0x25 0x30220220000000000000000000000000000000000000000000000000000000000000000000","0 CHECKSIG NOT","","OK"],["0x27 0x3024021077777777777777777777777777777777020a7777777777777777777777777777777701","0 CHECKSIG NOT","","OK"],["0x27 0x302403107777777777777777777777777777777702107777777777777777777777777777777701","0 CHECKSIG NOT","","OK"],["0x27 0x302402107777777777777777777777777777777703107777777777777777777777777777777701","0 CHECKSIG NOT","","OK"],["0x17 0x3014020002107777777777777777777777777777777701","0 CHECKSIG NOT","","OK"],["0x17 0x3014021077777777777777777777777777777777020001","0 CHECKSIG NOT","","OK"],["0x27 0x302402107777777777777777777777777777777702108777777777777777777777777777777701","0 CHECKSIG NOT","","OK"],["0x4a 0x3047022201010101010101010101010101010101010101010101010101010101010101010101022101010101010101010101010101010101010101010101010101010101010101010101","0 CHECKSIG NOT","","OK"],["0x47 0x3043022044dc17b0887c161bb67ba9635bf758735bdde503e4b0a0987f587f14a4e1143d022009a215772d49a85dae40d8ca03955af26ad3978a0ff965faa12915e9586249a501","0 CHECKSIG NOT","","OK"],["0x03 0x300000","0 CHECKSIG NOT","","OK"],["","DEPTH","P2SH,STRICTENC","EVAL_FALSE"],["  ","DEPTH","P2SH,STRICTENC","EVAL_FALSE"],["   ","DEPTH","P2SH,STRICTENC","EVAL_FALSE"],["    ","DEPTH","P2SH,STRICTENC","EVAL_FALSE"],["","","P2SH,STRICTENC","EVAL_FALSE"],["","NOP","P2SH,STRICTENC","EVAL_FALSE"],["","NOP DEPTH","P2SH,STRICTENC","EVAL_FALSE"],["NOP","","P2SH,STRICTENC","EVAL_FALSE"],["NOP","DEPTH","P2SH,STRICTENC","EVAL_FALSE"],["NOP","NOP","P2SH,STRICTENC","EVAL_FALSE"],["NOP","NOP DEPTH","P2SH,STRICTENC","EVAL_FALSE"],["DEPTH","","P2SH,STRICTENC","EVAL_FALSE"],["0x4c01","0x01 NOP","P2SH,STRICTENC","BAD_OPCODE"],["0x4d0200ff","0x01 NOP","P2SH,STRICTENC","BAD_OPCODE"],["0x4e03000000ffff","0x01 NOP","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0x50 ENDIF 1","P2SH,STRICTENC","BAD_OPCODE"],["0x52","0x5f ADD 0x60 EQUAL","P2SH,STRICTENC","EVAL_FALSE"],["0","NOP","P2SH,STRICTENC","EVAL_FALSE"],["1","IF VER ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["0","IF VERIF ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["0","IF ELSE 1 ELSE VERIF ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["0","IF VERNOTIF ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["0","IF ELSE 1 ELSE VERNOTIF ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1 IF","1 ENDIF","P2SH,STRICTENC","UNBALANCED_CONDITIONAL"],["1 IF 0 ENDIF","1 ENDIF","P2SH,STRICTENC","UNBALANCED_CONDITIONAL"],["1 ELSE 0 ENDIF","1","P2SH,STRICTENC","UNBALANCED_CONDITIONAL"],["0 NOTIF","123","P2SH,STRICTENC","UNBALANCED_CONDITIONAL"],["0","DUP IF ENDIF","P2SH,STRICTENC","EVAL_FALSE"],["0","IF 1 ENDIF","P2SH,STRICTENC","EVAL_FALSE"],["0","DUP IF ELSE ENDIF","P2SH,STRICTENC","EVAL_FALSE"],["0","IF 1 ELSE ENDIF","P2SH,STRICTENC","EVAL_FALSE"],["0","NOTIF ELSE 1 ENDIF","P2SH,STRICTENC","EVAL_FALSE"],["0 1","IF IF 1 ELSE 0 ENDIF ENDIF","P2SH,STRICTENC","EVAL_FALSE"],["0 0","IF IF 1 ELSE 0 ENDIF ENDIF","P2SH,STRICTENC","EVAL_FALSE"],["1 0","IF IF 1 ELSE 0 ENDIF ELSE IF 0 ELSE 1 ENDIF ENDIF","P2SH,STRICTENC","EVAL_FALSE"],["0 1","IF IF 1 ELSE 0 ENDIF ELSE IF 0 ELSE 1 ENDIF ENDIF","P2SH,STRICTENC","EVAL_FALSE"],["0 0","NOTIF IF 1 ELSE 0 ENDIF ENDIF","P2SH,STRICTENC","EVAL_FALSE"],["0 1","NOTIF IF 1 ELSE 0 ENDIF ENDIF","P2SH,STRICTENC","EVAL_FALSE"],["1 1","NOTIF IF 1 ELSE 0 ENDIF ELSE IF 0 ELSE 1 ENDIF ENDIF","P2SH,STRICTENC","EVAL_FALSE"],["0 0","NOTIF IF 1 ELSE 0 ENDIF ELSE IF 0 ELSE 1 ENDIF ENDIF","P2SH,STRICTENC","EVAL_FALSE"],["1","IF RETURN ELSE ELSE 1 ENDIF","P2SH,STRICTENC","OP_RETURN"],["1","IF 1 ELSE ELSE RETURN ENDIF","P2SH,STRICTENC","OP_RETURN"],["1","ENDIF","P2SH,STRICTENC","UNBALANCED_CONDITIONAL"],["1","ELSE ENDIF","P2SH,STRICTENC","UNBALANCED_CONDITIONAL"],["1","ENDIF ELSE","P2SH,STRICTENC","UNBALANCED_CONDITIONAL"],["1","ENDIF ELSE IF","P2SH,STRICTENC","UNBALANCED_CONDITIONAL"],["1","IF ELSE ENDIF ELSE","P2SH,STRICTENC","UNBALANCED_CONDITIONAL"],["1","IF ELSE ENDIF ELSE ENDIF","P2SH,STRICTENC","UNBALANCED_CONDITIONAL"],["1","IF ENDIF ENDIF","P2SH,STRICTENC","UNBALANCED_CONDITIONAL"],["1","IF ELSE ELSE ENDIF ENDIF","P2SH,STRICTENC","UNBALANCED_CONDITIONAL"],["1","RETURN","P2SH,STRICTENC","OP_RETURN"],["1","DUP IF RETURN ENDIF","P2SH,STRICTENC","OP_RETURN"],["1","RETURN 'data'","P2SH,STRICTENC","OP_RETURN"],["0 IF","RETURN ENDIF 1","P2SH,STRICTENC","UNBALANCED_CONDITIONAL"],["0","VERIFY 1","P2SH,STRICTENC","VERIFY"],["1","VERIFY","P2SH,STRICTENC","EVAL_FALSE"],["1","VERIFY 0","P2SH,STRICTENC","EVAL_FALSE"],["1 TOALTSTACK","FROMALTSTACK 1","P2SH,STRICTENC","INVALID_ALTSTACK_OPERATION"],["IFDUP","DEPTH 0 EQUAL","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["DROP","DEPTH 0 EQUAL","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["DUP","DEPTH 0 EQUAL","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","DUP 1 ADD 2 EQUALVERIFY 0 EQUAL","P2SH,STRICTENC","EVAL_FALSE"],["NOP","NIP","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","1 NIP","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","1 0 NIP","P2SH,STRICTENC","EVAL_FALSE"],["NOP","OVER 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","OVER","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["0 1","OVER DEPTH 3 EQUALVERIFY","P2SH,STRICTENC","EVAL_FALSE"],["19 20 21","PICK 19 EQUALVERIFY DEPTH 2 EQUAL","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","0 PICK","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","-1 PICK","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["19 20 21","0 PICK 20 EQUALVERIFY DEPTH 3 EQUAL","P2SH,STRICTENC","EQUALVERIFY"],["19 20 21","1 PICK 21 EQUALVERIFY DEPTH 3 EQUAL","P2SH,STRICTENC","EQUALVERIFY"],["19 20 21","2 PICK 22 EQUALVERIFY DEPTH 3 EQUAL","P2SH,STRICTENC","EQUALVERIFY"],["NOP","0 ROLL","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","-1 ROLL","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["19 20 21","0 ROLL 20 EQUALVERIFY DEPTH 2 EQUAL","P2SH,STRICTENC","EQUALVERIFY"],["19 20 21","1 ROLL 21 EQUALVERIFY DEPTH 2 EQUAL","P2SH,STRICTENC","EQUALVERIFY"],["19 20 21","2 ROLL 22 EQUALVERIFY DEPTH 2 EQUAL","P2SH,STRICTENC","EQUALVERIFY"],["NOP","ROT 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","1 ROT 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","1 2 ROT 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","0 1 2 ROT","P2SH,STRICTENC","EVAL_FALSE"],["NOP","SWAP 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","SWAP 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["0 1","SWAP 1 EQUALVERIFY","P2SH,STRICTENC","EQUALVERIFY"],["NOP","TUCK 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","TUCK 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1 0","TUCK DEPTH 3 EQUALVERIFY SWAP 2DROP","P2SH,STRICTENC","EVAL_FALSE"],["NOP","2DUP 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","2DUP 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","3DUP 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","3DUP 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1 2","3DUP 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","2OVER 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","2 3 2OVER 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","2SWAP 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","2 3 2SWAP 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","SIZE 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["'a' 'b'","CAT","P2SH,STRICTENC","DISABLED_OPCODE"],["'a' 'b' 0","IF CAT ELSE 1 ENDIF","P2SH,STRICTENC","DISABLED_OPCODE"],["'abc' 1 1","SUBSTR","P2SH,STRICTENC","DISABLED_OPCODE"],["'abc' 1 1 0","IF SUBSTR ELSE 1 ENDIF","P2SH,STRICTENC","DISABLED_OPCODE"],["'abc' 2 0","IF LEFT ELSE 1 ENDIF","P2SH,STRICTENC","DISABLED_OPCODE"],["'abc' 2 0","IF RIGHT ELSE 1 ENDIF","P2SH,STRICTENC","DISABLED_OPCODE"],["'abc'","IF INVERT ELSE 1 ENDIF","P2SH,STRICTENC","DISABLED_OPCODE"],["1 2 0 IF AND ELSE 1 ENDIF","NOP","P2SH,STRICTENC","DISABLED_OPCODE"],["1 2 0 IF OR ELSE 1 ENDIF","NOP","P2SH,STRICTENC","DISABLED_OPCODE"],["1 2 0 IF XOR ELSE 1 ENDIF","NOP","P2SH,STRICTENC","DISABLED_OPCODE"],["2 0 IF 2MUL ELSE 1 ENDIF","NOP","P2SH,STRICTENC","DISABLED_OPCODE"],["2 0 IF 2DIV ELSE 1 ENDIF","NOP","P2SH,STRICTENC","DISABLED_OPCODE"],["2 2 0 IF MUL ELSE 1 ENDIF","NOP","P2SH,STRICTENC","DISABLED_OPCODE"],["2 2 0 IF DIV ELSE 1 ENDIF","NOP","P2SH,STRICTENC","DISABLED_OPCODE"],["2 2 0 IF MOD ELSE 1 ENDIF","NOP","P2SH,STRICTENC","DISABLED_OPCODE"],["2 2 0 IF LSHIFT ELSE 1 ENDIF","NOP","P2SH,STRICTENC","DISABLED_OPCODE"],["2 2 0 IF RSHIFT ELSE 1 ENDIF","NOP","P2SH,STRICTENC","DISABLED_OPCODE"],["","EQUAL NOT","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["0","EQUAL NOT","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["0 1","EQUAL","P2SH,STRICTENC","EVAL_FALSE"],["1 1 ADD","0 EQUAL","P2SH,STRICTENC","EVAL_FALSE"],["11 1 ADD 12 SUB","11 EQUAL","P2SH,STRICTENC","EVAL_FALSE"],["2147483648 0 ADD","NOP","P2SH,STRICTENC","SCRIPTNUM"],["-2147483648 0 ADD","NOP","P2SH,STRICTENC","SCRIPTNUM"],["2147483647 DUP ADD","4294967294 NUMEQUAL","P2SH,STRICTENC","SCRIPTNUM"],["'abcdef' NOT","0 EQUAL","P2SH,STRICTENC","SCRIPTNUM"],["2 DUP MUL","4 EQUAL","P2SH,STRICTENC","DISABLED_OPCODE"],["2 DUP DIV","1 EQUAL","P2SH,STRICTENC","DISABLED_OPCODE"],["2 2MUL","4 EQUAL","P2SH,STRICTENC","DISABLED_OPCODE"],["2 2DIV","1 EQUAL","P2SH,STRICTENC","DISABLED_OPCODE"],["7 3 MOD","1 EQUAL","P2SH,STRICTENC","DISABLED_OPCODE"],["2 2 LSHIFT","8 EQUAL","P2SH,STRICTENC","DISABLED_OPCODE"],["2 1 RSHIFT","1 EQUAL","P2SH,STRICTENC","DISABLED_OPCODE"],["1","NOP1 CHECKLOCKTIMEVERIFY CHECKSEQUENCEVERIFY NOP4 NOP5 NOP6 NOP7 NOP8 NOP9 NOP10 2 EQUAL","P2SH,STRICTENC","EVAL_FALSE"],["'NOP_1_to_10' NOP1 CHECKLOCKTIMEVERIFY CHECKSEQUENCEVERIFY NOP4 NOP5 NOP6 NOP7 NOP8 NOP9 NOP10","'NOP_1_to_11' EQUAL","P2SH,STRICTENC","EVAL_FALSE"],["0x50","1","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xba ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xbb ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xbc ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xbd ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xbe ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xbf ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xc0 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xc1 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xc2 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xc3 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xc4 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xc5 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xc6 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xc7 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xc8 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xc9 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xca ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xcb ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xcc ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xcd ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xce ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xcf ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xd0 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xd1 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xd2 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xd3 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xd4 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xd5 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xd6 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xd7 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xd8 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xd9 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xda ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xdb ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xdc ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xdd ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xde ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xdf ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xe0 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xe1 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xe2 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xe3 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xe4 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xe5 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xe6 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xe7 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xe8 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xe9 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xea ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xeb ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xec ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xed ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xee ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xef ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xf0 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xf1 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xf2 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xf3 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xf4 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xf5 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xf6 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xf7 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xf8 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xf9 ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xfa ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xfb ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xfc ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xfd ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xfe ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1","IF 0xff ELSE 1 ENDIF","P2SH,STRICTENC","BAD_OPCODE"],["1 IF 1 ELSE","0xff ENDIF","P2SH,STRICTENC","UNBALANCED_CONDITIONAL"],["NOP","RIPEMD160","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","SHA1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","SHA256","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","HASH160","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","HASH256","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'","P2SH,STRICTENC","PUSH_SIZE"],["0","IF 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' ENDIF 1","P2SH,STRICTENC","PUSH_SIZE"],["1","0x61616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161","P2SH,STRICTENC","OP_COUNT"],["0","IF 0x6161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161 ENDIF 1","P2SH,STRICTENC","OP_COUNT"],["1 2 3 4 5 0x6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f","1 2 3 4 5 6 0x6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f","P2SH,STRICTENC","STACK_SIZE"],["1 2 3 4 5 0x6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f","1 TOALTSTACK 2 TOALTSTACK 3 4 5 6 0x6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f","P2SH,STRICTENC","STACK_SIZE"],["NOP","0 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 0x6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f6f 2DUP 0x616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161","P2SH,STRICTENC","SCRIPT_SIZE"],["NOP1","NOP10","P2SH,STRICTENC","EVAL_FALSE"],["1","VER","P2SH,STRICTENC","BAD_OPCODE"],["1","VERIF","P2SH,STRICTENC","BAD_OPCODE"],["1","VERNOTIF","P2SH,STRICTENC","BAD_OPCODE"],["1","RESERVED","P2SH,STRICTENC","BAD_OPCODE"],["1","RESERVED1","P2SH,STRICTENC","BAD_OPCODE"],["1","RESERVED2","P2SH,STRICTENC","BAD_OPCODE"],["1","0xba","P2SH,STRICTENC","BAD_OPCODE"],["2147483648","1ADD 1","P2SH,STRICTENC","SCRIPTNUM"],["2147483648","NEGATE 1","P2SH,STRICTENC","SCRIPTNUM"],["-2147483648","1ADD 1","P2SH,STRICTENC","SCRIPTNUM"],["2147483647","1ADD 1SUB 1","P2SH,STRICTENC","SCRIPTNUM"],["2147483648","1SUB 1","P2SH,STRICTENC","SCRIPTNUM"],["2147483648 1","BOOLOR 1","P2SH,STRICTENC","SCRIPTNUM"],["2147483648 1","BOOLAND 1","P2SH,STRICTENC","SCRIPTNUM"],["1","1 ENDIF","P2SH,STRICTENC","UNBALANCED_CONDITIONAL"],["1","IF 1","P2SH,STRICTENC","UNBALANCED_CONDITIONAL"],["1 IF 1","ENDIF","P2SH,STRICTENC","UNBALANCED_CONDITIONAL"],["NOP","IF 1 ENDIF","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","NOTIF 1 ENDIF","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","VERIFY 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","TOALTSTACK 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","FROMALTSTACK","P2SH,STRICTENC","INVALID_ALTSTACK_OPERATION"],["1","2 TOALTSTACK FROMALTSTACK FROMALTSTACK","P2SH,STRICTENC","INVALID_ALTSTACK_OPERATION"],["1","2DROP 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","2DUP","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1 1","3DUP","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1 1 1","2OVER","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1 1 1 1 1","2ROT","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1 1 1","2SWAP","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","IFDUP 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","DROP 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","DUP 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","NIP","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","OVER","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1 1 1 3","PICK","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["0","PICK 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1 1 1 3","ROLL","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["0","ROLL 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1 1","ROT","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","SWAP","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","TUCK","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","SIZE 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","EQUAL 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","EQUALVERIFY 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","1ADD 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","1SUB 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","NEGATE 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","ABS 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","NOT 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","0NOTEQUAL 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","ADD","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","SUB","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","BOOLAND","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","BOOLOR","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","NUMEQUAL","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","NUMEQUALVERIFY 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","NUMNOTEQUAL","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","LESSTHAN","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","GREATERTHAN","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","LESSTHANOREQUAL","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","GREATERTHANOREQUAL","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","MIN","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1","MAX","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["1 1","WITHIN","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","RIPEMD160 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","SHA1 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","SHA256 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","HASH160 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["NOP","HASH256 1","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["","CHECKSIG NOT","STRICTENC","INVALID_STACK_OPERATION"],["0","CHECKSIG NOT","STRICTENC","INVALID_STACK_OPERATION"],["","CHECKMULTISIG NOT","STRICTENC","INVALID_STACK_OPERATION"],["","-1 CHECKMULTISIG NOT","STRICTENC","PUBKEY_COUNT"],["","1 CHECKMULTISIG NOT","STRICTENC","INVALID_STACK_OPERATION"],["","-1 0 CHECKMULTISIG NOT","STRICTENC","SIG_COUNT"],["","1 'pk1' 1 CHECKMULTISIG NOT","STRICTENC","INVALID_STACK_OPERATION"],["","'dummy' 'sig1' 1 'pk1' 1 CHECKMULTISIG IF 1 ENDIF","","EVAL_FALSE"],["","0 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG 0 0 CHECKMULTISIG","P2SH,STRICTENC","OP_COUNT"],["1","0 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY 0 0 CHECKMULTISIGVERIFY","P2SH,STRICTENC","INVALID_STACK_OPERATION"],["","NOP NOP NOP NOP NOP NOP NOP NOP NOP NOP NOP NOP NOP 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIG 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIG 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIG 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIG 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIG 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIG 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIG 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIG 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIG","P2SH,STRICTENC","OP_COUNT"],["1","NOP NOP NOP NOP NOP NOP NOP NOP NOP NOP NOP NOP NOP 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIGVERIFY 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIGVERIFY 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIGVERIFY 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIGVERIFY 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIGVERIFY 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIGVERIFY 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIGVERIFY 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIGVERIFY 0 0 'a' 'b' 'c' 'd' 'e' 'f' 'g' 'h' 'i' 'j' 'k' 'l' 'm' 'n' 'o' 'p' 'q' 'r' 's' 't' 20 CHECKMULTISIGVERIFY","P2SH,STRICTENC","OP_COUNT"],["0 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21","21 CHECKMULTISIG 1","P2SH,STRICTENC","PUBKEY_COUNT"],["0 'sig' 1 0","CHECKMULTISIG 1","P2SH,STRICTENC","SIG_COUNT"],["NOP 0x01 1","HASH160 0x14 0xda1745e9b549bd0bfa1a569971c77eba30cd5a4b EQUAL","P2SH,STRICTENC","SIG_PUSHONLY"],["NOP1 0x01 1","HASH160 0x14 0xda1745e9b549bd0bfa1a569971c77eba30cd5a4b EQUAL","P2SH,STRICTENC","SIG_PUSHONLY"],["0 0x01 0x50","HASH160 0x14 0xece424a6bb6ddf4db592c0faed60685047a361b1 EQUAL","P2SH,STRICTENC","BAD_OPCODE"],["0 0x01 VER","HASH160 0x14 0x0f4d7845db968f2a81b530b6f3c1d6246d4c7e01 EQUAL","P2SH,STRICTENC","BAD_OPCODE"],["0x00","'00' EQUAL","P2SH,STRICTENC","EVAL_FALSE"],["0 0x47 0x3044022044dc17b0887c161bb67ba9635bf758735bdde503e4b0a0987f587f14a4e1143d022009a215772d49a85dae40d8ca03955af26ad3978a0ff965faa12915e9586249a501 0x47 0x3044022044dc17b0887c161bb67ba9635bf758735bdde503e4b0a0987f587f14a4e1143d022009a215772d49a85dae40d8ca03955af26ad3978a0ff965faa12915e9586249a501","2 0x21 0x02865c40293a680cb9c020e7b1e106d8c1916d3cef99aa431a56d253e69256dac0 0 2 CHECKMULTISIG NOT","STRICTENC","PUBKEYTYPE"],["0 0x47 0x3044022044dc17b0887c161bb67ba9635bf758735bdde503e4b0a0987f587f14a4e1143d022009a215772d49a85dae40d8ca03955af26ad3978a0ff965faa12915e9586249a501 1","2 0x21 0x02865c40293a680cb9c020e7b1e106d8c1916d3cef99aa431a56d253e69256dac0 0x21 0x02865c40293a680cb9c020e7b1e106d8c1916d3cef99aa431a56d253e69256dac0 2 CHECKMULTISIG NOT","STRICTENC","SIG_DER"],["0 0x47 0x304402205451ce65ad844dbb978b8bdedf5082e33b43cae8279c30f2c74d9e9ee49a94f802203fe95a7ccf74da7a232ee523ef4a53cb4d14bdd16289680cdb97a63819b8f42f01 0x46 0x304402205451ce65ad844dbb978b8bdedf5082e33b43cae8279c30f2c74d9e9ee49a94f802203fe95a7ccf74da7a232ee523ef4a53cb4d14bdd16289680cdb97a63819b8f42f","2 0x21 0x02a673638cb9587cb68ea08dbef685c6f2d2a751a8b3c6f2a7e9a4999e6e4bfaf5 0x21 0x02a673638cb9587cb68ea08dbef685c6f2d2a751a8b3c6f2a7e9a4999e6e4bfaf5 0x21 0x02a673638cb9587cb68ea08dbef685c6f2d2a751a8b3c6f2a7e9a4999e6e4bfaf5 3 CHECKMULTISIG","P2SH,STRICTENC","SIG_DER"],["0","0x21 0x06865c40293a680cb9c020e7b1e106d8c1916d3cef99aa431a56d253e69256dac0 CHECKSIG NOT","","OK"],["0","0x21 0x06865c40293a680cb9c020e7b1e106d8c1916d3cef99aa431a56d253e69256dac0 CHECKSIG NOT","STRICTENC","PUBKEYTYPE"],["0x47 0x304402200a5c6163f07b8d3b013c4d1d6dba25e780b39658d79ba37af7057a3b7f15ffa102201fd9b4eaa9943f734928b99a83592c2e7bf342ea2680f6a2bb705167966b742001","0x41 0x0479be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8 CHECKSIG","","OK"],["0x47 0x304402200a5c6163f07b8c3b013c4d1d6dba25e780b39658d79ba37af7057a3b7f15ffa102201fd9b4eaa9943f734928b99a83592c2e7bf342ea2680f6a2bb705167966b742001","0x41 0x0479be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8 CHECKSIG","","EVAL_FALSE"],["0x47 0x304402206e05a6fe23c59196ffe176c9ddc31e73a9885638f9d1328d47c0c703863b8876022076feb53811aa5b04e0e79f938eb19906cc5e67548bc555a8e8b8b0fc603d840c01 0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508","DUP HASH160 0x14 0x1018853670f9f3b0582c5b9ee8ce93764ac32b93 EQUALVERIFY CHECKSIG","","OK"],["0x47 0x3044022034bb0494b50b8ef130e2185bb220265b9284ef5b4b8a8da4d8415df489c83b5102206259a26d9cc0a125ac26af6153b17c02956855ebe1467412f066e402f5f05d1201 0x21 0x03363d90d446b00c9c99ceac05b6262ee053441c7e55552ffe526bad8f83ff4640","DUP HASH160 0x14 0xc0834c0c158f53be706d234c38fd52de7eece656 EQUALVERIFY CHECKSIG","","EQUALVERIFY"],["0x47 0x304402204710a85181663b32d25c70ec2bbd14adff5ddfff6cb50d09e155ef5f541fc86c0220056b0cc949be9386ecc5f6c2ac0493269031dbb185781db90171b54ac127790281","0x41 0x048282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f5150811f8a8098557dfe45e8256e830b60ace62d613ac2f7b17bed31b6eaff6e26caf CHECKSIG","","OK"],["0x47 0x304402204710a85181663b32d25c70ec2bbd14adff5ddfff6cb50d09e155ef5f541fc86c0220056b0cc949be9386ecc5f6c2ac0493269031dbb185781db90171b54ac127790201","0x41 0x048282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f5150811f8a8098557dfe45e8256e830b60ace62d613ac2f7b17bed31b6eaff6e26caf CHECKSIG","","EVAL_FALSE"],["0x47 0x3044022003fef42ed6c7be8917441218f525a60e2431be978e28b7aca4d7a532cc413ae8022067a1f82c74e8d69291b90d148778405c6257bbcfc2353cc38a3e1f22bf44254601 0x23 0x210279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798ac","HASH160 0x14 0x23b0ad3477f2178bc0b3eed26e4e6316f4e83aa1 EQUAL","P2SH","OK"],["0x47 0x3044022003fef42ed6c7be8917441218f525a60e2431be978e28b7aca4d7a532cc413ae8022067a1f82c74e8d69291b90d148778405c6257bbcfc2353cc38a3e1f22bf44254601 0x23 0x210279be667ef9dcbbac54a06295ce870b07029bfcdb2dce28d959f2815b16f81798ac","HASH160 0x14 0x23b0ad3477f2178bc0b3eed26e4e6316f4e83aa1 EQUAL","P2SH","EVAL_FALSE"],["0x47 0x30440220781ba4f59a7b207a10db87628bc2168df4d59b844b397d2dbc9a5835fb2f2b7602206ed8fbcc1072fe2dfc5bb25909269e5dc42ffcae7ec2bc81d59692210ff30c2b01 0x41 0x0479be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8 0x19 0x76a91491b24bf9f5288532960ac687abb035127b1d28a588ac","HASH160 0x14 0x7f67f0521934a57d3039f77f9f32cf313f3ac74b EQUAL","P2SH","OK"],["0x47 0x304402204e2eb034be7b089534ac9e798cf6a2c79f38bcb34d1b179efd6f2de0841735db022071461beb056b5a7be1819da6a3e3ce3662831ecc298419ca101eb6887b5dd6a401 0x19 0x76a9147cf9c846cd4882efec4bf07e44ebdad495c94f4b88ac","HASH160 0x14 0x2df519943d5acc0ef5222091f9dfe3543f489a82 EQUAL","","OK"],["0x47 0x304402204e2eb034be7b089534ac9e798cf6a2c79f38bcb34d1b179efd6f2de0841735db022071461beb056b5a7be1819da6a3e3ce3662831ecc298419ca101eb6887b5dd6a401 0x19 0x76a9147cf9c846cd4882efec4bf07e44ebdad495c94f4b88ac","HASH160 0x14 0x2df519943d5acc0ef5222091f9dfe3543f489a82 EQUAL","P2SH","EQUALVERIFY"],["0 0x47 0x3044022051254b9fb476a52d85530792b578f86fea70ec1ffb4393e661bcccb23d8d63d3022076505f94a403c86097841944e044c70c2045ce90e36de51f7e9d3828db98a07501 0x47 0x304402200a358f750934b3feb822f1966bfcd8bbec9eeaa3a8ca941e11ee5960e181fa01022050bf6b5a8e7750f70354ae041cb68a7bade67ec6c3ab19eb359638974410626e01 0x47 0x304402200955d031fff71d8653221e85e36c3c85533d2312fc3045314b19650b7ae2f81002202a6bb8505e36201909d0921f01abff390ae6b7ff97bbf959f98aedeb0a56730901","3 0x21 0x0279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798 0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 0x21 0x03363d90d447b00c9c99ceac05b6262ee053441c7e55552ffe526bad8f83ff4640 3 CHECKMULTISIG","","OK"],["0 0x47 0x3044022051254b9fb476a52d85530792b578f86fea70ec1ffb4393e661bcccb23d8d63d3022076505f94a403c86097841944e044c70c2045ce90e36de51f7e9d3828db98a07501 0x47 0x304402200a358f750934b3feb822f1966bfcd8bbec9eeaa3a8ca941e11ee5960e181fa01022050bf6b5a8e7750f70354ae041cb68a7bade67ec6c3ab19eb359638974410626e01 0","3 0x21 0x0279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798 0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 0x21 0x03363d90d447b00c9c99ceac05b6262ee053441c7e55552ffe526bad8f83ff4640 3 CHECKMULTISIG","","EVAL_FALSE"],["0 0x47 0x304402205b7d2c2f177ae76cfbbf14d589c113b0b35db753d305d5562dd0b61cbf366cfb02202e56f93c4f08a27f986cd424ffc48a462c3202c4902104d4d0ff98ed28f4bf8001 0x47 0x30440220563e5b3b1fc11662a84bc5ea2a32cc3819703254060ba30d639a1aaf2d5068ad0220601c1f47ddc76d93284dd9ed68f7c9974c4a0ea7cbe8a247d6bc3878567a5fca01 0x4c69 0x52210279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f8179821038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f515082103363d90d447b00c9c99ceac05b6262ee053441c7e55552ffe526bad8f83ff464053ae","HASH160 0x14 0xc9e4a896d149702d0d1695434feddd52e24ad78d EQUAL","P2SH","OK"],["0 0x47 0x304402205b7d2c2f177ae76cfbbf14d589c113b0b35db753d305d5562dd0b61cbf366cfb02202e56f93c4f08a27f986cd424ffc48a462c3202c4902104d4d0ff98ed28f4bf8001 0 0x4c69 0x52210279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f8179821038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f515082103363d90d447b00c9c99ceac05b6262ee053441c7e55552ffe526bad8f83ff464053ae","HASH160 0x14 0xc9e4a896d149702d0d1695434feddd52e24ad78d EQUAL","P2SH","EVAL_FALSE"],["0x47 0x304402200060558477337b9022e70534f1fea71a318caf836812465a2509931c5e7c4987022078ec32bd50ac9e03a349ba953dfd9fe1c8d2dd8bdb1d38ddca844d3d5c78c11801","0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 CHECKSIG","","OK"],["0x48 0x304502202de8c03fc525285c9c535631019a5f2af7c6454fa9eb392a3756a4917c420edd02210046130bf2baf7cfc065067c8b9e33a066d9c15edcea9feb0ca2d233e3597925b401","0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 CHECKSIG","","OK"],["0x47 0x30440220d7a0417c3f6d1a15094d1cf2a3378ca0503eb8a57630953a9e2987e21ddd0a6502207a6266d686c99090920249991d3d42065b6d43eb70187b219c0db82e4f94d1a201","0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 CHECKSIG","","OK"],["0x47 0x30440220005ece1335e7f757a1a1f476a7fb5bd90964e8a022489f890614a04acfb734c002206c12b8294a6513c7710e8c82d3c23d75cdbfe83200eb7efb495701958501a5d601","0x21 0x03363d90d447b00c9c99ceac05b6262ee053441c7e55552ffe526bad8f83ff4640 CHECKSIG NOT","","OK"],["0x47 0x30440220005ece1335e7f657a1a1f476a7fb5bd90964e8a022489f890614a04acfb734c002206c12b8294a6513c7710e8c82d3c23d75cdbfe83200eb7efb495701958501a5d601","0x21 0x03363d90d447b00c9c99ceac05b6262ee053441c7e55552ffe526bad8f83ff4640 CHECKSIG NOT","","EVAL_FALSE"],["0x47 0x30440220d7a0417c3f6d1a15094d1cf2a3378ca0503eb8a57630953a9e2987e21ddd0a6502207a6266d686c99090920249991d3d42065b6d43eb70187b219c0db82e4f94d1a201","0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 CHECKSIG","","OK"],["0x47 0x304402208e43c0b91f7c1e5bc58e41c8185f8a6086e111b0090187968a86f2822462d3c902200a58f4076b1133b18ff1dc83ee51676e44c60cc608d9534e0df5ace0424fc0be01","0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 CHECKSIG NOT","","EVAL_FALSE"],["0","0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 CHECKSIG","","EVAL_FALSE"],["0","0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 CHECKSIG NOT","","OK"],["1","0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 CHECKSIG","","EVAL_FALSE"],["1","0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 CHECKSIG NOT","","OK"],["0 0x47 0x30440220cae00b1444babfbf6071b0ba8707f6bd373da3df494d6e74119b0430c5db810502205d5231b8c5939c8ff0c82242656d6e06edb073d42af336c99fe8837c36ea39d501 0x47 0x3044022027c2714269ca5aeecc4d70edc88ba5ee0e3da4986e9216028f489ab4f1b8efce022022bd545b4951215267e4c5ceabd4c5350331b2e4a0b6494c56f361fa5a57a1a201","2 0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 0x21 0x03363d90d447b00c9c99ceac05b6262ee053441c7e55552ffe526bad8f83ff4640 2 CHECKMULTISIG","","OK"],["0 0x47 0x30440220b119d67d389315308d1745f734a51ff3ec72e06081e84e236fdf9dc2f5d2a64802204b04e3bc38674c4422ea317231d642b56dc09d214a1ecbbf16ecca01ed996e2201 0x47 0x3044022079ea80afd538d9ada421b5101febeb6bc874e01dde5bca108c1d0479aec339a4022004576db8f66130d1df686ccf00935703689d69cf539438da1edab208b0d63c4801","2 0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 0x21 0x03363d90d447b00c9c99ceac05b6262ee053441c7e55552ffe526bad8f83ff4640 2 CHECKMULTISIG NOT","","EVAL_FALSE"],["0 0 0x47 0x3044022081aa9d436f2154e8b6d600516db03d78de71df685b585a9807ead4210bd883490220534bb6bdf318a419ac0749660b60e78d17d515558ef369bf872eff405b676b2e01","2 0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 0x21 0x03363d90d447b00c9c99ceac05b6262ee053441c7e55552ffe526bad8f83ff4640 2 CHECKMULTISIG","","EVAL_FALSE"],["0 0 0x47 0x30440220da6f441dc3b4b2c84cfa8db0cd5b34ed92c9e01686de5a800d40498b70c0dcac02207c2cf91b0c32b860c4cd4994be36cfb84caf8bb7c3a8e4d96a31b2022c5299c501","2 0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 0x21 0x03363d90d447b00c9c99ceac05b6262ee053441c7e55552ffe526bad8f83ff4640 2 CHECKMULTISIG NOT","","OK"],["0 0x47 0x30440220cae00b1444babfbf6071b0ba8707f6bd373da3df494d6e74119b0430c5db810502205d5231b8c5939c8ff0c82242656d6e06edb073d42af336c99fe8837c36ea39d501 0","2 0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 0x21 0x03363d90d447b00c9c99ceac05b6262ee053441c7e55552ffe526bad8f83ff4640 2 CHECKMULTISIG","","EVAL_FALSE"],["0 0x47 0x30440220b119d67d389315308d1745f734a51ff3ec72e06081e84e236fdf9dc2f5d2a64802204b04e3bc38674c4422ea317231d642b56dc09d214a1ecbbf16ecca01ed996e2201 0","2 0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 0x21 0x03363d90d447b00c9c99ceac05b6262ee053441c7e55552ffe526bad8f83ff4640 2 CHECKMULTISIG NOT","","OK"],["0x48 0x304402203e4516da7253cf068effec6b95c41221c0cf3a8e6ccb8cbf1725b562e9afde2c022054e1c258c2981cdfba5df1f46661fb6541c44f77ca0092f3600331abfffb12510101","0x21 0x03363d90d447b00c9c99ceac05b6262ee053441c7e55552ffe526bad8f83ff4640 CHECKSIG","","OK"],["0x48 0x304502203e4516da7253cf068effec6b95c41221c0cf3a8e6ccb8cbf1725b562e9afde2c022100ab1e3da73d67e32045a20e0b999e049978ea8d6ee5480d485fcf2ce0d03b2ef001","0x21 0x03363d90d447b00c9c99ceac05b6262ee053441c7e55552ffe526bad8f83ff4640 CHECKSIG","","OK"],["0x47 0x3044022057292e2d4dfe775becdd0a9e6547997c728cdf35390f6a017da56d654d374e4902206b643be2fc53763b4e284845bfea2c597d2dc7759941dce937636c9d341b71ed01","0x41 0x0679be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8 CHECKSIG","","OK"],["0x47 0x3044022057292e2d4dfe775becdd0a9e6547997c728cdf35390f6a017da56d654d374e4902206b643be2fc53763b4e284845bfea2c597d2dc7759941dce937636c9d341b71ed01","0x41 0x0679be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8 CHECKSIG","STRICTENC","PUBKEYTYPE"],["0x00","0x21 0x0479be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798 CHECKSIG","STRICTENC","PUBKEYTYPE"],["0x00","0x41 0x0279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8 CHECKSIG","STRICTENC","PUBKEYTYPE"],["0x47 0x30440220035d554e3153c14950c9993f41c496607a8e24093db0595be7bf875cf64fcf1f02204731c8c4e5daf15e706cec19cdd8f2c5b1d05490e11dab8465ed426569b6e92101","0x41 0x0679be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8 CHECKSIG NOT","","EVAL_FALSE"],["0x47 0x30440220035d554e3153c14950c9993f41c496607a8e24093db0595be7bf875cf64fcf1f02204731c8c4e5daf15e706cec19cdd8f2c5b1d05490e11dab8465ed426569b6e92101","0x41 0x0679be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8 CHECKSIG NOT","STRICTENC","PUBKEYTYPE"],["0x47 0x30440220035d554e3153c04950c9993f41c496607a8e24093db0595be7bf875cf64fcf1f02204731c8c4e5daf15e706cec19cdd8f2c5b1d05490e11dab8465ed426569b6e92101","0x41 0x0679be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8 CHECKSIG NOT","","OK"],["0x47 0x30440220035d554e3153c04950c9993f41c496607a8e24093db0595be7bf875cf64fcf1f02204731c8c4e5daf15e706cec19cdd8f2c5b1d05490e11dab8465ed426569b6e92101","0x41 0x0679be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8 CHECKSIG NOT","STRICTENC","PUBKEYTYPE"],["0 0x47 0x304402202e79441ad1baf5a07fb86bae3753184f6717d9692680947ea8b6e8b777c69af1022079a262e13d868bb5a0964fefe3ba26942e1b0669af1afb55ef3344bc9d4fc4c401","1 0x41 0x0679be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8 0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 2 CHECKMULTISIG","","OK"],["0 0x47 0x304402202e79441ad1baf5a07fb86bae3753184f6717d9692680947ea8b6e8b777c69af1022079a262e13d868bb5a0964fefe3ba26942e1b0669af1afb55ef3344bc9d4fc4c401","1 0x41 0x0679be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8 0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 2 CHECKMULTISIG","STRICTENC","OK"],["0 0x47 0x3044022079c7824d6c868e0e1a273484e28c2654a27d043c8a27f49f52cb72efed0759090220452bbbf7089574fa082095a4fc1b3a16bafcf97a3a34d745fafc922cce66b27201","1 0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 0x41 0x0679be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8 2 CHECKMULTISIG","STRICTENC","PUBKEYTYPE"],["0x47 0x304402206177d513ec2cda444c021a1f4f656fc4c72ba108ae063e157eb86dc3575784940220666fc66702815d0e5413bb9b1df22aed44f5f1efb8b99d41dd5dc9a5be6d205205","0x41 0x048282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f5150811f8a8098557dfe45e8256e830b60ace62d613ac2f7b17bed31b6eaff6e26caf CHECKSIG","","OK"],["0x47 0x304402206177d513ec2cda444c021a1f4f656fc4c72ba108ae063e157eb86dc3575784940220666fc66702815d0e5413bb9b1df22aed44f5f1efb8b99d41dd5dc9a5be6d205205","0x41 0x048282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f5150811f8a8098557dfe45e8256e830b60ace62d613ac2f7b17bed31b6eaff6e26caf CHECKSIG","STRICTENC","SIG_HASHTYPE"],["0x47 0x304402207409b5b320296e5e2136a7b281a7f803028ca4ca44e2b83eebd46932677725de02202d4eea1c8d3c98e6f42614f54764e6e5e6542e213eb4d079737e9a8b6e9812ec05","0x41 0x048282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f5150811f8a8098557dfe45e8256e830b60ace62d613ac2f7b17bed31b6eaff6e26caf CHECKSIG NOT","","OK"],["0x47 0x304402207409b5b320296e5e2136a7b281a7f803028ca4ca44e2b83eebd46932677725de02202d4eea1c8d3c98e6f42614f54764e6e5e6542e213eb4d079737e9a8b6e9812ec05","0x41 0x048282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f5150811f8a8098557dfe45e8256e830b60ace62d613ac2f7b17bed31b6eaff6e26caf CHECKSIG NOT","STRICTENC","SIG_HASHTYPE"],["1 0x47 0x3044022051254b9fb476a52d85530792b578f86fea70ec1ffb4393e661bcccb23d8d63d3022076505f94a403c86097841944e044c70c2045ce90e36de51f7e9d3828db98a07501 0x47 0x304402200a358f750934b3feb822f1966bfcd8bbec9eeaa3a8ca941e11ee5960e181fa01022050bf6b5a8e7750f70354ae041cb68a7bade67ec6c3ab19eb359638974410626e01 0x47 0x304402200955d031fff71d8653221e85e36c3c85533d2312fc3045314b19650b7ae2f81002202a6bb8505e36201909d0921f01abff390ae6b7ff97bbf959f98aedeb0a56730901","3 0x21 0x0279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798 0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 0x21 0x03363d90d447b00c9c99ceac05b6262ee053441c7e55552ffe526bad8f83ff4640 3 CHECKMULTISIG","","OK"],["1 0x47 0x304402201bb2edab700a5d020236df174fefed78087697143731f659bea59642c759c16d022061f42cdbae5bcd3e8790f20bf76687443436e94a634321c16a72aa54cbc7c2ea01 0x47 0x304402204bb4a64f2a6e5c7fb2f07fef85ee56fde5e6da234c6a984262307a20e99842d702206f8303aaba5e625d223897e2ffd3f88ef1bcffef55f38dc3768e5f2e94c923f901 0x47 0x3044022040c2809b71fffb155ec8b82fe7a27f666bd97f941207be4e14ade85a1249dd4d02204d56c85ec525dd18e29a0533d5ddf61b6b1bb32980c2f63edf951aebf7a27bfe01","3 0x21 0x0279be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798 0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 0x21 0x03363d90d447b00c9c99ceac05b6262ee053441c7e55552ffe526bad8f83ff4640 3 CHECKMULTISIG NOT","","OK"],["0 0x47 0x304402200abeb4bd07f84222f474aed558cfbdfc0b4e96cde3c2935ba7098b1ff0bd74c302204a04c1ca67b2a20abee210cf9a21023edccbbf8024b988812634233115c6b73901 DUP","2 0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 2 CHECKMULTISIG","","OK"],["0x47 0x3044022018a2a81a93add5cb5f5da76305718e4ea66045ec4888b28d84cb22fae7f4645b02201e6daa5ed5d2e4b2b2027cf7ffd43d8d9844dd49f74ef86899ec8e669dfd39aa01 NOP8 0x23 0x2103363d90d447b00c9c99ceac05b6262ee053441c7e55552ffe526bad8f83ff4640ac","HASH160 0x14 0x215640c2f72f0d16b4eced26762035a42ffed39a EQUAL","","OK"],["0x47 0x304402203e4516da7253cf068effec6b95c41221c0cf3a8e6ccb8cbf1725b562e9afde2c022054e1c258c2981cdfba5df1f46661fb6541c44f77ca0092f3600331abfffb125101 NOP8","0x21 0x03363d90d447b00c9c99ceac05b6262ee053441c7e55552ffe526bad8f83ff4640 CHECKSIG","P2SH","OK"],["0x47 0x3044022018a2a81a93add5cb5f5da76305718e4ea66045ec4888b28d84cb22fae7f4645b02201e6daa5ed5d2e4b2b2027cf7ffd43d8d9844dd49f74ef86899ec8e669dfd39aa01 NOP8 0x23 0x2103363d90d447b00c9c99ceac05b6262ee053441c7e55552ffe526bad8f83ff4640ac","HASH160 0x14 0x215640c2f72f0d16b4eced26762035a42ffed39a EQUAL","P2SH","SIG_PUSHONLY"],["11 0x47 0x304402200a5c6163f07b8d3b013c4d1d6dba25e780b39658d79ba37af7057a3b7f15ffa102201fd9b4eaa9943f734928b99a83592c2e7bf342ea2680f6a2bb705167966b742001","0x41 0x0479be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8 CHECKSIG","P2SH","OK"],["11 0x47 0x304402202f7505132be14872581f35d74b759212d9da40482653f1ffa3116c3294a4a51702206adbf347a2240ca41c66522b1a22a41693610b76a8e7770645dc721d1635854f01 0x43 0x410479be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b8ac","HASH160 0x14 0x31edc23bdafda4639e669f89ad6b2318dd79d032 EQUAL","P2SH","OK"],["0","0x21 0x02865c40293a680cb9c020e7b1e106d8c1916d3cef99aa431a56d253e69256dac0 CHECKSIGVERIFY 1","P2SH,STRICTENC","CHECKSIGVERIFY"],["0 0","1 0x21 0x02865c40293a680cb9c020e7b1e106d8c1916d3cef99aa431a56d253e69256dac0 1 CHECKMULTISIGVERIFY 1","P2SH,STRICTENC","CHECKMULTISIGVERIFY"],["0","IF CODESEPARATOR ENDIF 1","","OK"],["0x02 0x0001","0x02 0x0001 DROP 0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508 CHECKSIG NOT","","OK"]]''';

class _Case {
  const _Case(this.asm, this.stack, [this.sigs = const <String>{}]);

  final String asm;
  final List<String> stack;
  final Set<String> sigs;
}

ScriptMachine _machine(
  String asm, {
  int? lockTime,
  int? inputSequence,
  int? txVersion,
  Set<String> sigs = const <String>{},
}) {
  return ScriptMachine(
    parseScriptAsm(asm),
    lockTime: lockTime,
    inputSequence: inputSequence,
    txVersion: txVersion,
    validSignatures: sigs,
  );
}

List<String> _finalStack(String asm, {Set<String> sigs = const <String>{}}) {
  final machine = _machine(asm, sigs: sigs);
  final results = machine.runAll();
  expect(machine.error, isNull, reason: asm);

  return results.isEmpty
      ? <String>[]
      : results.last.stack.map(hexEncode).toList();
}

String _hexOf(int value) => value.toRadixString(16).padLeft(2, '0');

final _stackCases = <_Case>[
  const _Case('OP_0', ['']),
  const _Case('OP_FALSE', ['']),
  const _Case('OP_1NEGATE', ['81']),
  const _Case('OP_TRUE', ['01']),
  // OP_2 to OP_16 are generated below.
  const _Case('5 NOP NOP1 NOP4 NOP5 NOP6 NOP7 NOP8 NOP9 NOP10', ['05']),
  const _Case('2 CODESEPARATOR', ['02']),
  const _Case('1 IF 2 ELSE 3 ENDIF', ['02']),
  const _Case('0 IF 2 ELSE 3 ENDIF', ['03']),
  const _Case('0 NOTIF 2 ENDIF', ['02']),
  const _Case('1 NOTIF 2 ELSE 3 ENDIF', ['03']),
  const _Case('1 1 VERIFY', ['01']),
  const _Case('5 TOALTSTACK 6 FROMALTSTACK', ['06', '05']),
  const _Case('1 IFDUP', ['01', '01']),
  const _Case('0 IFDUP', ['']),
  const _Case('1 2 DEPTH', ['01', '02', '02']),
  const _Case('1 2 DROP', ['01']),
  const _Case('7 DUP', ['07', '07']),
  const _Case('1 2 NIP', ['02']),
  const _Case('1 2 OVER', ['01', '02', '01']),
  const _Case('1 2 3 2 PICK', ['01', '02', '03', '01']),
  const _Case('1 2 3 2 ROLL', ['02', '03', '01']),
  const _Case('1 2 3 ROT', ['02', '03', '01']),
  const _Case('1 2 SWAP', ['02', '01']),
  const _Case('1 2 TUCK', ['02', '01', '02']),
  const _Case('1 2 3 2DROP', ['01']),
  const _Case('1 2 2DUP', ['01', '02', '01', '02']),
  const _Case('1 2 3 3DUP', ['01', '02', '03', '01', '02', '03']),
  const _Case('1 2 3 4 2OVER', ['01', '02', '03', '04', '01', '02']),
  const _Case('1 2 3 4 5 6 2ROT', ['03', '04', '05', '06', '01', '02']),
  const _Case('1 2 3 4 2SWAP', ['03', '04', '01', '02']),
  const _Case("'abc' SIZE", ['616263', '03']),
  const _Case('1 1 EQUAL', ['01']),
  const _Case('1 2 EQUAL', ['']),
  const _Case('1 1 EQUALVERIFY 2', ['02']),
  const _Case('5 1ADD', ['06']),
  const _Case('5 1SUB', ['04']),
  const _Case('5 NEGATE', ['85']),
  const _Case('#-5 ABS', ['05']),
  const _Case('0 NOT', ['01']),
  const _Case('5 NOT', ['']),
  const _Case('5 0NOTEQUAL', ['01']),
  const _Case('0 0NOTEQUAL', ['']),
  const _Case('2 3 ADD', ['05']),
  const _Case('5 3 SUB', ['02']),
  const _Case('1 0 BOOLAND', ['']),
  const _Case('1 2 BOOLAND', ['01']),
  const _Case('0 1 BOOLOR', ['01']),
  const _Case('0 0 BOOLOR', ['']),
  const _Case('2 2 NUMEQUAL', ['01']),
  const _Case('2 2 NUMEQUALVERIFY 7', ['07']),
  const _Case('2 3 NUMNOTEQUAL', ['01']),
  const _Case('2 3 LESSTHAN', ['01']),
  const _Case('2 3 GREATERTHAN', ['']),
  const _Case('3 3 LESSTHANOREQUAL', ['01']),
  const _Case('2 3 GREATERTHANOREQUAL', ['']),
  const _Case('2 3 MIN', ['02']),
  const _Case('2 3 MAX', ['03']),
  const _Case('2 1 3 WITHIN', ['01']),
  // Digests of the empty string, from the published test vectors of each
  // algorithm.
  const _Case("'' RIPEMD160", ['9c1185a5c5e9fc54612808977ee8f548b2258d31']),
  const _Case("'' SHA256", [
    'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
  ]),
  const _Case("'' SHA1", ['da39a3ee5e6b4b0d3255bfef95601890afd80709']),
  const _Case("'' HASH256", [
    '5df6e0e2761359d30a8275058e299fcc0381534545f55cf43e41983f5d4c9456',
  ]),
  const _Case("'' HASH160", ['b472a266d0bd89c13706a4132ccfb16f7c3b9fcb']),
  const _Case('<aa> <bb> CHECKSIG', ['01'], {'aa:bb'}),
  const _Case('<aa> <bb> CHECKSIG', ['']),
  const _Case('<aa> <bb> CHECKSIGVERIFY 1', ['01'], {'aa:bb'}),
  const _Case(
    '0 <aa> <bb> 2 <cc> <dd> <ee> 3 CHECKMULTISIG',
    ['01'],
    {'aa:cc', 'bb:dd'},
  ),
  const _Case(
    '0 <aa> <bb> 2 <cc> <dd> <ee> 3 CHECKMULTISIGVERIFY 1',
    ['01'],
    {'aa:cc', 'bb:dd'},
  ),
];

/// Opcodes covered by the timelock and error tests further down.
const _otherCoveredAsm = [
  'CHECKLOCKTIMEVERIFY',
  'CHECKSEQUENCEVERIFY',
  'RETURN',
  'CAT',
  'CHECKSIGADD',
  'RESERVED',
  'IF',
  'ENDIF',
  'ELSE',
];

Set<String> _opcodeNamesIn(String asm) {
  final names = <String>{};
  for (final token in asm.split(RegExp(r'\s+'))) {
    if (token.isEmpty) {
      continue;
    }
    final number = int.tryParse(token);
    if (number != null && number >= -1 && number <= 16) {
      names.add(
        scriptOpcodeByName(number == -1 ? 'OP_1NEGATE' : 'OP_$number')!.name,
      );
      continue;
    }
    final opcode = scriptOpcodeByName(token);
    if (opcode != null) {
      names.add(opcode.name);
    }
  }

  return names;
}

final _errorCases = <(String, ScriptError)>[
  ('DUP', ScriptError.stackUnderflow),
  ('FROMALTSTACK', ScriptError.altStackUnderflow),
  ('0 VERIFY', ScriptError.verifyFailed),
  ('1 2 EQUALVERIFY', ScriptError.equalVerifyFailed),
  ('1 2 NUMEQUALVERIFY', ScriptError.numEqualVerifyFailed),
  ('1 RETURN', ScriptError.opReturn),
  ('1 1 CAT', ScriptError.disabledOpcode),
  ('1 CHECKSIGADD', ScriptError.unsupportedOpcode),
  ('1 RESERVED', ScriptError.unsupportedOpcode),
  ('1 IF', ScriptError.unbalancedConditional),
  ('1 ENDIF', ScriptError.unbalancedConditional),
  ('1 ELSE', ScriptError.unbalancedConditional),
  ('IF 1 ENDIF', ScriptError.stackUnderflow),
  ('#2147483648 1ADD', ScriptError.numberOverflow),
  ('1 5 PICK', ScriptError.badPickIndex),
  ('1 #-1 PICK', ScriptError.badPickIndex),
  ('#21 CHECKMULTISIG', ScriptError.keyCountOutOfRange),
  ('0 <aa> <bb> 2 <cc> 1 CHECKMULTISIG', ScriptError.sigCountOutOfRange),
  ('#-1 CHECKLOCKTIMEVERIFY', ScriptError.negativeLockTime),
];

/// The script elements for Core's notation of [text].
///
/// Core splices raw bytes (`0x..`) and the minimal encoding of each other
/// token into one byte stream, and a raw push can take its data from the
/// next token. The adapter does the same: it builds the bytes, then parses
/// them once.
List<ScriptElement> _coreElements(String text) {
  final bytes = <int>[];
  for (final token in text.split(RegExp(r'\s+'))) {
    if (token.isEmpty) {
      continue;
    }
    if (token.startsWith('0x')) {
      bytes.addAll(
        hexDecode(token.substring(2).isEmpty ? '' : token.substring(2)),
      );
      continue;
    }
    final number = int.tryParse(token);
    final asm = number != null && (number < -1 || number > 16)
        ? '#$token'
        : token;
    bytes.addAll(serializeScript(parseScriptAsm(asm)));
  }

  return parseScriptHex(hexEncode(bytes));
}

/// Errors that Core reports for each expected outcome, where the mapping is
/// clear. A null entry means Core's EVAL_FALSE: no error, false top item.
final _coreErrors = <String, Set<ScriptError?>>{
  'EVAL_FALSE': {null},
  'VERIFY': {ScriptError.verifyFailed},
  'EQUALVERIFY': {ScriptError.equalVerifyFailed},
  'UNBALANCED_CONDITIONAL': {ScriptError.unbalancedConditional},
  'DISABLED_OPCODE': {ScriptError.disabledOpcode},
  'OP_COUNT': {ScriptError.opCountExceeded},
  'STACK_SIZE': {ScriptError.stackTooLarge},
  'PUSH_SIZE': {ScriptError.pushTooLarge},
  'OP_RETURN': {ScriptError.opReturn},
  'INVALID_STACK_OPERATION': {
    ScriptError.stackUnderflow,
    ScriptError.badPickIndex,
  },
  'INVALID_ALTSTACK_OPERATION': {ScriptError.altStackUnderflow},
  'SCRIPTNUM': {ScriptError.numberOverflow, ScriptError.nonMinimalNumber},
  'BAD_OPCODE': {ScriptError.unsupportedOpcode},
  'SCRIPT_SIZE': {ScriptError.scriptTooLarge},
};

void main() {
  group('stack, arithmetic, hash and signature opcodes', () {
    for (final entry in _stackCases) {
      test('${entry.asm} leaves ${entry.stack}', () {
        final machine = _machine(entry.asm, sigs: entry.sigs);
        final results = machine.runAll();

        expect(machine.error, isNull);
        expect(results.last.stack.map(hexEncode).toList(), entry.stack);
      });
    }

    for (var n = 2; n <= 16; n++) {
      test('OP_$n pushes $n', () {
        expect(_finalStack('$n'), [_hexOf(n)]);
      });
    }

    test('every supported opcode has a test case', () {
      final covered = <String>{
        ..._opcodeNamesIn(_otherCoveredAsm.join(' ')),
        ..._opcodeNamesIn('2 3 4 5 6 7 8 9 10 11 12 13 14 15 16'),
        for (final entry in _stackCases) ..._opcodeNamesIn(entry.asm),
        for (final error in _errorCases) ..._opcodeNamesIn(error.$1),
      };
      final required = scriptOpcodeTable
          .where(
            (op) =>
                (op.support == ScriptOpcodeSupport.supported ||
                    op.support == ScriptOpcodeSupport.simulated) &&
                !op.name.startsWith('OP_PUSHDATA'),
          )
          .map((op) => op.name)
          .toSet();

      expect(required.difference(covered), isEmpty);
    });
  });

  group('step results', () {
    test('step reports the element, the stacks and the index', () {
      final machine = _machine('2 3 ADD');

      final first = machine.step();
      expect(first.index, 0);
      expect(hexEncode(first.stack.single), '02');
      expect(first.executed, isTrue);
      expect(machine.succeeded, isNull);

      machine.step();
      final last = machine.step();
      expect(hexEncode(last.stack.single), '05');
      expect(machine.isFinished, isTrue);
      expect(machine.succeeded, isTrue);
    });

    test('an empty script is finished and fails', () {
      final machine = _machine('');

      expect(machine.isFinished, isTrue);
      expect(machine.succeeded, isFalse);
      expect(() => machine.step(), throwsA(isA<StateError>()));
    });

    test('a script whose top item is true succeeds', () {
      final machine = _machine('1');
      final results = machine.runAll();
      expect(results.last.stack.single, [1]);
      expect(machine.succeeded, isTrue);
    });

    test('a false top item fails without an error', () {
      final machine = _machine('0');
      machine.runAll();

      expect(machine.error, isNull);
      expect(machine.succeeded, isFalse);
    });

    test('reset starts the script again', () {
      final machine = _machine('1 2 ADD');
      final first = machine
          .runAll()
          .map((r) => hexEncode(r.stack.last))
          .toList();

      machine.reset();
      final second = machine
          .runAll()
          .map((r) => hexEncode(r.stack.last))
          .toList();

      expect(second, first);
      expect(machine.succeeded, isTrue);
    });

    test('a simulated signature step carries the simulated note', () {
      final machine = _machine('<aa> <bb> CHECKSIG', sigs: {'aa:bb'});
      final results = machine.runAll();

      expect(results.last.note, ScriptStepNote.signatureSimulated);
      expect(machine.succeeded, isTrue);
    });

    test('a non-executed branch reports executed false', () {
      final results = _machine('0 IF 2 ENDIF 1').runAll();

      expect(results[2].executed, isFalse);
      expect(results.last.executed, isTrue);
    });

    test('the element stacks are copies, not live lists', () {
      final machine = _machine('1 2 3');
      final first = machine.step();
      machine.step();

      expect(first.stack.length, 1);
    });

    test('a push of 520 bytes is allowed and 521 bytes fails', () {
      final ok = ScriptMachine([ScriptPush(Uint8List(520))]);
      ok.runAll();
      expect(ok.error, isNull);

      final tooLarge = ScriptMachine([ScriptPush(Uint8List(521))]);
      tooLarge.runAll();
      expect(tooLarge.error, ScriptError.pushTooLarge);
    });

    test('OP_PUSHDATA opcodes are not accepted as ScriptOp elements', () {
      expect(
        () => ScriptMachine([ScriptOp(scriptOpcodeByName('OP_PUSHDATA1')!)]),
        throwsArgumentError,
      );
    });
  });

  group('error values', () {
    for (final entry in _errorCases) {
      test('${entry.$1} fails with ${entry.$2.name}', () {
        final machine = _machine(entry.$1);
        machine.runAll();

        expect(machine.error, entry.$2);
        expect(machine.succeeded, isFalse);
        expect(machine.isFinished, isTrue);
      });
    }

    test('a non-minimal number operand fails', () {
      final machine = ScriptMachine([
        ScriptPush(Uint8List.fromList([0x01, 0x00])),
        ScriptOp(scriptOpcodeByName('OP_1ADD')!),
      ]);
      machine.runAll();

      expect(machine.error, ScriptError.nonMinimalNumber);
    });

    test('a stack of 1000 items is allowed and 1001 fails', () {
      final one = ScriptOp(scriptOpcodeByName('OP_1')!);
      final ok = ScriptMachine(List.filled(1000, one));
      ok.runAll();
      expect(ok.error, isNull);

      final tooLarge = ScriptMachine(List.filled(1001, one));
      tooLarge.runAll();
      expect(tooLarge.error, ScriptError.stackTooLarge);
    });

    test('the alt stack counts toward the 1000-item limit', () {
      final one = ScriptOp(scriptOpcodeByName('OP_1')!);
      final toAlt = ScriptOp(scriptOpcodeByName('OP_TOALTSTACK')!);
      final elements = [...List.filled(1000, one), toAlt, one];
      final machine = ScriptMachine(elements);
      machine.runAll();

      expect(machine.error, ScriptError.stackTooLarge);

      final withinLimit = ScriptMachine([...List.filled(999, one), toAlt]);
      withinLimit.runAll();
      expect(withinLimit.error, isNull);
    });

    test('201 non-push opcodes are allowed and 202 fail', () {
      final nop = ScriptOp(scriptOpcodeByName('OP_NOP')!);
      final ok = ScriptMachine([
        ScriptPush(Uint8List.fromList([1])),
        ...List.filled(201, nop),
      ]);
      ok.runAll();
      expect(ok.error, isNull);

      final tooMany = ScriptMachine([
        ScriptPush(Uint8List.fromList([1])),
        ...List.filled(202, nop),
      ]);
      tooMany.runAll();
      expect(tooMany.error, ScriptError.opCountExceeded);
    });

    test('pushes do not count toward the 201-opcode limit', () {
      final elements = [
        for (var i = 0; i < 300; i++) ScriptPush(Uint8List.fromList([1])),
      ];
      final machine = ScriptMachine(elements);
      machine.runAll();

      expect(machine.error, isNull);
    });
  });

  group('conditionals', () {
    test('nested IF, ELSE and ENDIF pick the right branch', () {
      expect(_finalStack('1 IF 1 IF 2 ELSE 3 ENDIF ELSE 4 ENDIF'), ['02']);
      expect(_finalStack('1 IF 0 IF 2 ELSE 3 ENDIF ELSE 4 ENDIF'), ['03']);
      expect(_finalStack('0 IF 1 IF 2 ELSE 3 ENDIF ELSE 4 ENDIF'), ['04']);
    });

    test('skipped branches leave the stack alone and report not executed', () {
      final results = _machine('0 IF 2 3 ADD ELSE 4 ENDIF').runAll();

      expect(results.map((r) => r.executed).toList(), [
        true, // 0
        true, // IF
        false, // 2
        false, // 3
        false, // ADD
        true, // ELSE
        true, // 4
        true, // ENDIF
      ]);
      expect(hexEncode(results.last.stack.single), '04');
    });

    test('a disabled opcode fails even in a branch that is not executed', () {
      final machine = _machine('0 IF 1 1 CAT ENDIF');
      machine.runAll();

      expect(machine.error, ScriptError.disabledOpcode);
    });

    test(
      'an unsupported opcode in a branch that is not executed is skipped',
      () {
        final elements = parseScriptHex('0063bb6851');
        final machine = ScriptMachine(elements);
        machine.runAll();

        expect(machine.error, isNull);
        expect(machine.succeeded, isTrue);
      },
    );

    test('an unknown byte fails when it is executed', () {
      final machine = ScriptMachine(parseScriptHex('bb'));
      machine.runAll();

      expect(machine.error, ScriptError.unsupportedOpcode);
    });

    test('NOTIF runs the branch when the value is false', () {
      expect(_finalStack('0 NOTIF 7 ENDIF'), ['07']);
    });
  });

  group('timelocks', () {
    test('CHECKLOCKTIMEVERIFY passes when the lock time is reached', () {
      final machine = _machine(
        '#100 CHECKLOCKTIMEVERIFY DROP 1',
        lockTime: 150,
        inputSequence: 0,
        txVersion: 2,
      );
      final results = machine.runAll();

      expect(machine.succeeded, isTrue);
      expect(results[1].note, ScriptStepNote.timelockSatisfied);
      expect(hexEncode(results[1].stack.single), '64');
    });

    test('CHECKLOCKTIMEVERIFY fails when the lock time is not reached', () {
      final machine = _machine(
        '#100 CHECKLOCKTIMEVERIFY',
        lockTime: 50,
        inputSequence: 0,
      );
      final results = machine.runAll();

      expect(machine.error, ScriptError.lockTimeNotReached);
      expect(results.last.note, ScriptStepNote.timelockNotSatisfied);
    });

    test('CHECKLOCKTIMEVERIFY fails when height and time are mixed', () {
      expect(
        (_machine(
          '#100 CHECKLOCKTIMEVERIFY',
          lockTime: 600000000,
          inputSequence: 0,
        )..runAll()).error,
        ScriptError.lockTimeTypeMismatch,
      );
      expect(
        (_machine(
          '#600000000 CHECKLOCKTIMEVERIFY',
          lockTime: 100,
          inputSequence: 0,
        )..runAll()).error,
        ScriptError.lockTimeTypeMismatch,
      );
    });

    test('CHECKLOCKTIMEVERIFY fails with a final input sequence', () {
      final machine = _machine(
        '#100 CHECKLOCKTIMEVERIFY',
        lockTime: 150,
        inputSequence: 0xffffffff,
      );
      machine.runAll();

      expect(machine.error, ScriptError.inputSequenceFinal);
    });

    test('CHECKLOCKTIMEVERIFY fails for a negative operand', () {
      final machine = _machine(
        '-1 CHECKLOCKTIMEVERIFY',
        lockTime: 1,
        inputSequence: 0,
      );
      machine.runAll();

      expect(machine.error, ScriptError.negativeLockTime);
    });

    test('CHECKLOCKTIMEVERIFY reports missing context', () {
      final machine = _machine('#100 CHECKLOCKTIMEVERIFY');
      final results = machine.runAll();

      expect(machine.error, ScriptError.missingContext);
      expect(results.last.note, ScriptStepNote.needsContext);
    });

    test('CHECKSEQUENCEVERIFY passes when the relative lock is reached', () {
      final machine = _machine(
        '#10 CHECKSEQUENCEVERIFY DROP 1',
        inputSequence: 12,
        txVersion: 2,
      );
      final results = machine.runAll();

      expect(machine.succeeded, isTrue);
      expect(results[1].note, ScriptStepNote.timelockSatisfied);
    });

    test('CHECKSEQUENCEVERIFY fails when the relative lock is not reached', () {
      final machine = _machine(
        '#10 CHECKSEQUENCEVERIFY',
        inputSequence: 5,
        txVersion: 2,
      );
      machine.runAll();

      expect(machine.error, ScriptError.lockTimeNotReached);
    });

    test('CHECKSEQUENCEVERIFY fails when height and time are mixed', () {
      final machine = _machine(
        '#4194314 CHECKSEQUENCEVERIFY',
        inputSequence: 10,
        txVersion: 2,
      );
      machine.runAll();

      expect(machine.error, ScriptError.lockTimeTypeMismatch);
    });

    test('CHECKSEQUENCEVERIFY fails for transaction version 1', () {
      final machine = _machine(
        '#10 CHECKSEQUENCEVERIFY',
        inputSequence: 12,
        txVersion: 1,
      );
      machine.runAll();

      expect(machine.error, ScriptError.txVersionTooLow);
    });

    test(
      'CHECKSEQUENCEVERIFY fails when the input disables relative locks',
      () {
        final machine = _machine(
          '#10 CHECKSEQUENCEVERIFY',
          inputSequence: 0x80000000 | 12,
          txVersion: 2,
        );
        machine.runAll();

        expect(machine.error, ScriptError.inputSequenceDisabled);
      },
    );

    test('CHECKSEQUENCEVERIFY does nothing when its disable flag is set', () {
      final machine = _machine('#2147483658 CHECKSEQUENCEVERIFY DROP 1');
      final results = machine.runAll();

      expect(machine.succeeded, isTrue);
      expect(results[0].note, isNull);
      expect(results[1].note, ScriptStepNote.timelockDisabled);
    });

    test('CHECKSEQUENCEVERIFY reports missing context', () {
      final machine = _machine('#10 CHECKSEQUENCEVERIFY');
      machine.runAll();

      expect(machine.error, ScriptError.missingContext);
    });
  });

  group('simulated signatures', () {
    test('CHECKSIG is true for a listed signature and key', () {
      final machine = _machine('<aa> <bb> CHECKSIG', sigs: {'aa:bb'});
      final results = machine.runAll();

      expect(machine.succeeded, isTrue);
      expect(results.last.note, ScriptStepNote.signatureSimulated);
    });

    test('CHECKSIG is false for an unlisted signature', () {
      final machine = _machine('<aa> <cc> CHECKSIG', sigs: {'aa:bb'});
      final results = machine.runAll();

      expect(machine.error, isNull);
      expect(machine.succeeded, isFalse);
      expect(results.last.note, ScriptStepNote.signatureSimulated);
    });

    test('CHECKSIGVERIFY fails for an unlisted signature', () {
      final machine = _machine('<aa> <cc> CHECKSIGVERIFY', sigs: {'aa:bb'});
      machine.runAll();

      expect(machine.error, ScriptError.verifyFailed);
    });

    test('CHECKMULTISIG 2-of-3 passes with signatures in key order', () {
      final machine = _machine(
        '0 <aa> <bb> 2 <cc> <dd> <ee> 3 CHECKMULTISIG',
        sigs: {'aa:cc', 'bb:dd'},
      );
      final results = machine.runAll();

      expect(machine.succeeded, isTrue);
      expect(results.last.note, ScriptStepNote.signatureSimulated);
      expect(results.last.stack.map(hexEncode).toList(), ['01']);
    });

    test('CHECKMULTISIG 2-of-3 fails with signatures out of order', () {
      final machine = _machine(
        '0 <bb> <aa> 2 <cc> <dd> <ee> 3 CHECKMULTISIG',
        sigs: {'aa:cc', 'bb:dd'},
      );
      final results = machine.runAll();

      expect(machine.error, isNull);
      expect(machine.succeeded, isFalse);
      expect(results.last.stack.map(hexEncode).toList(), ['']);
    });

    test('CHECKMULTISIG consumes the dummy element', () {
      final results = _machine(
        '0 <aa> <bb> 2 <cc> <dd> <ee> 3 CHECKMULTISIG',
        sigs: {'aa:cc', 'bb:dd'},
      ).runAll();

      expect(results.last.stack.length, 1);
    });

    test('CHECKMULTISIGVERIFY fails when the signatures are out of order', () {
      final machine = _machine(
        '0 <bb> <aa> 2 <cc> <dd> <ee> 3 CHECKMULTISIGVERIFY 1',
        sigs: {'aa:cc', 'bb:dd'},
      );
      machine.runAll();

      expect(machine.error, ScriptError.verifyFailed);
    });
  });

  group('Bitcoin Core script test vectors', () {
    test('the vectors that use only supported opcodes pass', () {
      final vectors = (jsonDecode(_coreVectorsJson) as List<dynamic>)
          .cast<List<dynamic>>();
      final excluded = <String, int>{};
      final failures = <String>[];
      var ran = 0;

      void exclude(String reason) {
        excluded[reason] = (excluded[reason] ?? 0) + 1;
      }

      for (final vector in vectors) {
        final scriptSig = vector[0] as String;
        final scriptPubKey = vector[1] as String;
        final flags = vector[2] as String;
        final expected = vector[3] as String;
        final flagSet = flags.split(',').where((f) => f.isNotEmpty).toSet();

        final List<ScriptElement> sigElements;
        final List<ScriptElement> pubElements;
        try {
          sigElements = _coreElements(scriptSig);
          pubElements = _coreElements(scriptPubKey);
        } on ScriptParseException {
          exclude('not parseable after adapting Core notation');
          continue;
        }
        final all = [...sigElements, ...pubElements];

        if (all.any(
          (e) =>
              e is ScriptOp &&
              e.opcode.support != ScriptOpcodeSupport.supported,
        )) {
          exclude('uses an opcode that is not supported');
          continue;
        }
        if (all.any(
          (e) =>
              e is ScriptOp &&
              (e.opcode.name == 'OP_CHECKLOCKTIMEVERIFY' ||
                  e.opcode.name == 'OP_CHECKSEQUENCEVERIFY'),
        )) {
          // Core runs these as NOPs unless the CLTV or CSV flag is set, and
          // this machine always enforces BIP 65 and BIP 112.
          exclude('CLTV or CSV, which Core treats as NOP without its flag');
          continue;
        }
        if (flagSet.contains('P2SH') &&
            pubElements.length == 3 &&
            pubElements[0] is ScriptOp &&
            (pubElements[0] as ScriptOp).opcode.name == 'OP_HASH160' &&
            pubElements[1] is ScriptPush &&
            pubElements[2] is ScriptOp &&
            (pubElements[2] as ScriptOp).opcode.name == 'OP_EQUAL') {
          exclude('P2SH template, which this machine does not evaluate');
          continue;
        }

        // Bitcoin runs the two scripts separately, each with its own opcode
        // count and alt stack, and the locking script starts from the stack
        // the unlocking script left. Do the same here.
        final sigMachine = ScriptMachine(sigElements);
        final sigResults = sigMachine.runAll();
        ScriptError? error = sigMachine.error;
        var succeeded = false;
        if (error == null) {
          final carried = sigResults.isEmpty
              ? const <Uint8List>[]
              : sigResults.last.stack;
          final pubMachine = ScriptMachine(pubElements, initialStack: carried);
          pubMachine.runAll();
          error = pubMachine.error;
          succeeded = pubMachine.succeeded == true;
        }

        if (error == ScriptError.nonMinimalNumber) {
          // Core only requires minimal numbers with the MINIMALDATA flag.
          exclude('non-minimal number, accepted by Core without MINIMALDATA');
          continue;
        }

        ran++;
        bool passed;
        if (expected == 'OK') {
          passed = succeeded;
        } else {
          passed = !succeeded;
          final allowed = _coreErrors[expected];
          if (allowed != null) {
            passed = passed && allowed.contains(error);
          }
        }
        if (!passed) {
          failures.add(
            '$expected | "$scriptSig" | "$scriptPubKey" | "$flags" | '
            'error=${error?.name} succeeded=$succeeded',
          );
        }
      }

      expect(failures, isEmpty, reason: failures.join('\n'));
      expect(ran, 507);
      expect(excluded, {
        'uses an opcode that is not supported': 323,
        'non-minimal number, accepted by Core without MINIMALDATA': 61,
        'P2SH template, which this machine does not evaluate': 15,
        'CLTV or CSV, which Core treats as NOP without its flag': 6,
        'not parseable after adapting Core notation': 3,
      });
    });
  });
}

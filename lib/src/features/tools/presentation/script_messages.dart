import '../../../generated/l10n/app_localizations.dart';
import '../domain/script_examples.dart';
import '../domain/script_machine.dart';
import '../domain/script_parser.dart';

/// Reader-facing text for the script demo: failure reasons, step notes, parse
/// errors and the names of the examples.

/// Why a script failed, as a phrase that follows "Script fails: ".
String scriptErrorMessage(AppLocalizations l10n, ScriptError error) {
  return switch (error) {
    ScriptError.stackUnderflow => l10n.labScriptErrStackUnderflow,
    ScriptError.altStackUnderflow => l10n.labScriptErrAltStackUnderflow,
    ScriptError.verifyFailed => l10n.labScriptErrVerifyFailed,
    ScriptError.equalVerifyFailed => l10n.labScriptErrEqualVerifyFailed,
    ScriptError.numEqualVerifyFailed => l10n.labScriptErrNumEqualVerifyFailed,
    ScriptError.opReturn => l10n.labScriptErrOpReturn,
    ScriptError.disabledOpcode => l10n.labScriptErrDisabledOpcode,
    ScriptError.unsupportedOpcode => l10n.labScriptErrUnsupportedOpcode,
    ScriptError.unbalancedConditional => l10n.labScriptErrUnbalancedConditional,
    ScriptError.numberOverflow => l10n.labScriptErrNumberOverflow,
    ScriptError.nonMinimalNumber => l10n.labScriptErrNonMinimalNumber,
    ScriptError.pushTooLarge => l10n.labScriptErrPushTooLarge,
    ScriptError.stackTooLarge => l10n.labScriptErrStackTooLarge,
    ScriptError.opCountExceeded => l10n.labScriptErrOpCountExceeded,
    ScriptError.badPickIndex => l10n.labScriptErrBadPickIndex,
    ScriptError.keyCountOutOfRange => l10n.labScriptErrKeyCountOutOfRange,
    ScriptError.sigCountOutOfRange => l10n.labScriptErrSigCountOutOfRange,
    ScriptError.negativeLockTime => l10n.labScriptErrNegativeLockTime,
    ScriptError.lockTimeNotReached => l10n.labScriptErrLockTimeNotReached,
    ScriptError.lockTimeTypeMismatch => l10n.labScriptErrLockTimeTypeMismatch,
    ScriptError.inputSequenceFinal => l10n.labScriptErrInputSequenceFinal,
    ScriptError.inputSequenceDisabled => l10n.labScriptErrInputSequenceDisabled,
    ScriptError.txVersionTooLow => l10n.labScriptErrTxVersionTooLow,
    ScriptError.missingContext => l10n.labScriptErrMissingContext,
    ScriptError.scriptTooLarge => l10n.labScriptErrScriptTooLarge,
  };
}

/// Note about one step, such as a simulated signature check.
String scriptNoteMessage(AppLocalizations l10n, ScriptStepNote note) {
  return switch (note) {
    ScriptStepNote.signatureSimulated => l10n.labScriptNoteSignature,
    ScriptStepNote.timelockSatisfied => l10n.labScriptNoteTimelockOk,
    ScriptStepNote.timelockNotSatisfied => l10n.labScriptNoteTimelockNo,
    ScriptStepNote.timelockDisabled => l10n.labScriptNoteTimelockOff,
    ScriptStepNote.needsContext => l10n.labScriptNoteContext,
  };
}

/// Why a typed script could not be read, as a phrase.
String scriptParseReasonMessage(
  AppLocalizations l10n,
  ScriptParseReason reason,
) {
  return switch (reason) {
    ScriptParseReason.unknownToken => l10n.labScriptParseUnknown,
    ScriptParseReason.invalidHex => l10n.labScriptParseInvalidHex,
    ScriptParseReason.invalidNumber => l10n.labScriptParseInvalidNumber,
    ScriptParseReason.unterminatedText => l10n.labScriptParseUnterminated,
    ScriptParseReason.truncatedPush => l10n.labScriptParseTruncated,
  };
}

/// Name of an example from [scriptExamples].
String scriptExampleName(AppLocalizations l10n, ScriptExample example) {
  return switch (example.id) {
    'arithmetic' => l10n.labScriptExArithmeticName,
    'p2pkh' => l10n.labScriptExP2pkhName,
    'multisig-2-of-3' => l10n.labScriptExMultisigName,
    'hashlock' => l10n.labScriptExHashlockName,
    'cltv' => l10n.labScriptExCltvName,
    'csv' => l10n.labScriptExCsvName,
    'htlc' => l10n.labScriptExHtlcName,
    _ => l10n.labScriptExHtlcRefundName,
  };
}

/// One-line description of an example from [scriptExamples].
String scriptExampleDescription(AppLocalizations l10n, ScriptExample example) {
  return switch (example.id) {
    'arithmetic' => l10n.labScriptExArithmeticDesc,
    'p2pkh' => l10n.labScriptExP2pkhDesc,
    'multisig-2-of-3' => l10n.labScriptExMultisigDesc,
    'hashlock' => l10n.labScriptExHashlockDesc,
    'cltv' => l10n.labScriptExCltvDesc,
    'csv' => l10n.labScriptExCsvDesc,
    'htlc' => l10n.labScriptExHtlcDesc,
    _ => l10n.labScriptExHtlcRefundDesc,
  };
}

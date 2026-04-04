import 'items/function_call_item.dart';
import 'items/function_call_output_item.dart';

/// Pairs a function_call with its matching function_call_output.
/// output is null when no matching output was found in the response.
class CorrelatedCall {
  final FunctionCallItem call;
  final FunctionCallOutputItem? output;

  const CorrelatedCall({required this.call, this.output});

  /// True if both call and output are present.
  bool get isComplete => output != null;

  @override
  String toString() =>
      'CorrelatedCall(callId: ${call.callId}, complete: $isComplete)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CorrelatedCall &&
          call == other.call &&
          output == other.output;

  @override
  int get hashCode => Object.hash(call, output);
}

const Map<String, dynamic> kMissingOutput = {
  'id': 'resp_002',
  'status': 'completed',
  'model': 'gpt-4o',
};

const Map<String, dynamic> kNullOutput = {
  'id': 'resp_003',
  'status': 'completed',
  'model': 'gpt-4o',
  'output': null,
};

const Map<String, dynamic> kWrongTypeOutput = {
  'id': 'resp_004',
  'output': 'this is wrong',
};

const Map<String, dynamic> kItemMissingType = {
  'id': 'resp_005',
  'output': [
    {'id': 'x_001', 'some_field': 'some_value'},
  ],
};

const Map<String, dynamic> kFunctionCallMissingCallId = {
  'id': 'resp_006',
  'output': [
    {
      'type': 'function_call',
      'id': 'fc_001',
      'name': 'some_function',
      'arguments': '{}',
      'status': 'completed',
    },
  ],
};

const Map<String, dynamic> kFunctionCallInvalidArgs = {
  'id': 'resp_007',
  'output': [
    {
      'type': 'function_call',
      'id': 'fc_001',
      'call_id': 'call_001',
      'name': 'some_function',
      'arguments': 'this is not json {{{',
      'status': 'completed',
    },
  ],
};

const Map<String, dynamic> kEmptyMap = {};

const Map<String, dynamic> kOutputWithNonMapItems = {
  'id': 'resp_008',
  'output': ['string_item', 42, null],
};

const Map<String, dynamic> kOrphanFunctionCall = {
  'id': 'resp_009',
  'status': 'completed',
  'model': 'gpt-4o',
  'output': [
    {
      'type': 'function_call',
      'id': 'fc_001',
      'call_id': 'call_orphan',
      'name': 'some_function',
      'arguments': '{"key": "value"}',
      'status': 'completed',
    },
  ],
};

const Map<String, dynamic> kOrphanFunctionCallOutput = {
  'id': 'resp_010',
  'output': [
    {
      'type': 'function_call_output',
      'id': 'fco_001',
      'call_id': 'call_nobody',
      'output': '{"result": "ok"}',
    },
  ],
};

const Map<String, dynamic> kDuplicateCallId = {
  'id': 'resp_011',
  'output': [
    {
      'type': 'function_call',
      'id': 'fc_001',
      'call_id': 'call_dup',
      'name': 'first_call',
      'arguments': '{}',
      'status': 'completed',
    },
    {
      'type': 'function_call',
      'id': 'fc_002',
      'call_id': 'call_dup',
      'name': 'second_call',
      'arguments': '{}',
      'status': 'completed',
    },
    {
      'type': 'function_call_output',
      'id': 'fco_001',
      'call_id': 'call_dup',
      'output': '{"result": "ok"}',
    },
  ],
};

const Map<String, dynamic> kNoUsage = {
  'id': 'resp_012',
  'status': 'completed',
  'model': 'gpt-4o',
  'output': [],
};

const Map<String, dynamic> kMixedWithUnknown = {
  'id': 'resp_013',
  'status': 'completed',
  'model': 'gpt-4o',
  'output': [
    {
      'type': 'reasoning',
      'id': 'rs_001',
      'summary': [
        {'type': 'summary_text', 'text': 'Thinking...'},
      ],
    },
    {
      'type': 'computer_use',
      'id': 'cu_001',
      'action': 'click',
      'coordinate': [100, 200],
    },
    {
      'type': 'message',
      'id': 'msg_001',
      'role': 'assistant',
      'content': [
        {'type': 'output_text', 'text': 'Done.'},
      ],
    },
  ],
};

const Map<String, dynamic> kEmptySummary = {
  'id': 'resp_014',
  'output': [
    {
      'type': 'reasoning',
      'id': 'rs_001',
      'summary': [],
    },
  ],
};

const Map<String, dynamic> kWeatherResponse = {
  'id': 'resp_demo_001',
  'object': 'response',
  'status': 'completed',
  'model': 'gpt-4o',
  'output': [
    {
      'type': 'reasoning',
      'id': 'rs_001',
      'summary': [
        {
          'type': 'summary_text',
          'text':
              'The user wants weather info for two cities. I will call the weather tool for each city, then compare and summarize.',
        },
      ],
    },
    {
      'type': 'function_call',
      'id': 'fc_001',
      'call_id': 'call_weather_tokyo',
      'name': 'get_current_weather',
      'arguments': '{"city": "Tokyo", "units": "celsius"}',
      'status': 'completed',
    },
    {
      'type': 'function_call_output',
      'id': 'fco_001',
      'call_id': 'call_weather_tokyo',
      'output':
          '{"temperature": 22, "condition": "Partly cloudy", "humidity": 65}',
    },
    {
      'type': 'function_call',
      'id': 'fc_002',
      'call_id': 'call_weather_london',
      'name': 'get_current_weather',
      'arguments': '{"city": "London", "units": "celsius"}',
      'status': 'completed',
    },
    {
      'type': 'function_call_output',
      'id': 'fco_002',
      'call_id': 'call_weather_london',
      'output':
          '{"temperature": 14, "condition": "Overcast", "humidity": 78}',
    },
    {
      'type': 'message',
      'id': 'msg_001',
      'role': 'assistant',
      'content': [
        {
          'type': 'output_text',
          'text':
              'Tokyo is 22C and partly cloudy. London is 14C and overcast.',
        },
      ],
    },
  ],
  'usage': {
    'input_tokens': 120,
    'output_tokens': 85,
  },
};

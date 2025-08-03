enum ApiModel {
  cohere('Command', 'Cohere', true, 'Very generous free tier, easy setup'),
  gemini('Gemini Pro', 'Google', true, 'Free tier with good limits'),
  openai('GPT-3.5 Turbo', 'OpenAI', false, 'Requires billing setup'),
  claude('Claude 3 Sonnet', 'Anthropic', false, 'Requires billing setup'),
  mock('Demo Mode', 'Local', true, 'Mock responses for testing');

  const ApiModel(this.displayName, this.provider, this.isFree, this.description);

  final String displayName;
  final String provider;
  final bool isFree;
  final String description;

  String get iconPath {
    switch (this) {
      case ApiModel.cohere:
        return 'assets/icons/cohere.png';
      case ApiModel.gemini:
        return 'assets/icons/gemini.png';
      case ApiModel.openai:
        return 'assets/icons/openai.png';
      case ApiModel.claude:
        return 'assets/icons/claude.png';
      case ApiModel.mock:
        return 'assets/icons/demo.png';
    }
  }

  String get apiKeyLabel {
    switch (this) {
      case ApiModel.cohere:
        return 'Cohere API Key';
      case ApiModel.gemini:
        return 'Gemini API Key';
      case ApiModel.openai:
        return 'OpenAI API Key';
      case ApiModel.claude:
        return 'Claude API Key';
      case ApiModel.mock:
        return 'No API Key Required';
    }
  }

  String get getKeyUrl {
    switch (this) {
      case ApiModel.cohere:
        return 'https://dashboard.cohere.ai/';
      case ApiModel.gemini:
        return 'https://ai.google.dev/';
      case ApiModel.openai:
        return 'https://platform.openai.com/';
      case ApiModel.claude:
        return 'https://console.anthropic.com/';
      case ApiModel.mock:
        return '';
    }
  }
}

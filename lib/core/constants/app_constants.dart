// API base URLs and app-wide config

class AppConstants {

  // ===================================
  // OPENROUTER
  // ===================================

  static const String openRouterBaseUrl = "https://openrouter.ai/api/v1";

  // ===================================
  // OTHER APIs
  // ===================================

  static const String todoistBaseUrl = "https://api.todoist.com/rest/v2";

  static const String arxivBaseUrl = "https://export.arxiv.org/api";

  // ===================================
  // DEFAULT AI MODEL
  // ===================================

  static const String defaultModel = "openai/gpt-oss-20b:free";

  // ===================================
  // APP CONFIG
  // ===================================

  static const int heartbeatMins = 5;

  static const int staleTaskDays = 5;

  static const int briefWindowMins = 30;
}

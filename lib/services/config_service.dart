import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ConfigService {
  Map<String, dynamic> _authConfig = {};
  Map<String, dynamic> _uiConfig = {};

  // Load authentication configuration from a local JSON file
  Future<void> loadAuthConfig() async {
    try {
      final jsonString = await rootBundle.loadString('assets/auth_config.json');
      _authConfig = json.decode(jsonString);
    } catch (e) {
      // Use default configuration if loading fails
      _authConfig = {
        "enabledAuthMethods": {
          "email": true,
          "google": true,
          "apple": true,
          "phone": true
        }
      };
    }
  }

  // Load UI configuration for a specific screen from a local JSON file
  Future<Map<String, dynamic>> loadUIConfig(String screen) async {
    try {
      final jsonString = await rootBundle.loadString('assets/$screen.json');
      _uiConfig = json.decode(jsonString);
    } catch (e) {
      // If loading fails, return an empty config
      _uiConfig = {};
    }

    return _uiConfig;
  }

  // Check if an authentication method is enabled
  bool isAuthMethodEnabled(String method) {
    return _authConfig['enabledAuthMethods']?[method] ?? false;
  }

  // Get UI configuration
  Map<String, dynamic> getUIConfig() {
    return _uiConfig;
  }
}

import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../providers/auth_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/ai_suggestions_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/ai_chat_provider.dart';
import '../providers/chat_provider.dart';

class AppProviders {
  static List<SingleChildWidget> get providers {
    return [
      ChangeNotifierProvider(create: (_) => AuthProvider()..loadUser()),
      ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ChangeNotifierProvider(create: (_) => AiSuggestionsProvider()),
      ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
      ChangeNotifierProvider(create: (_) => AiChatProvider()),
      ChangeNotifierProvider(create: (_) => ChatProvider()),
    ];
  }
}
